import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:findeals/models/transaction_data.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tranlog.db');
    print("SQLite DB Path: $path");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        return db.execute('''
          CREATE TABLE tranlog (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            bankName TEXT,
            productId TEXT,
            amount REAL,
            merchant TEXT,
            timestamp INT,
            productType TEXT,
            transactionType TEXT,
            merchantName TEXT,
            category TEXT  -- ✅ Adding category field (NULL by default)
          )
        ''');
      },
    );
  }

  // Insert transaction (without category initially)
  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    await db.insert(
      'tranlog',
      {
        'bankName': transaction.bankName,
        'productId': transaction.productId,
        'amount': transaction.amount,
        'merchant': transaction.merchant,
        'timestamp': transaction.timestamp.millisecondsSinceEpoch,
        'productType': transaction.productType,
        'transactionType': transaction.transactionType,
        'merchantName': transaction.merchantName,
        'category': null,  // ✅ Initially NULL
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUncategorizedTransactions() async {
    final db = await database;
    return await db.query('tranlog', where: 'category IS NULL');
  }

  // Update transaction category
  Future<void> updateCategory(String merchant, String category) async {
    final db = await database;
    await db.update(
      'tranlog',
      {'category': category},
      where: 'merchant = ?',
      whereArgs: [merchant],
    );
  }
// Inside DatabaseHelper class
Future<List<Map<String, dynamic>>> getCategoryWiseSummary() async {
  final db = await database;
  return await db.rawQuery('''
    SELECT category, SUM(amount) AS totalSpend
    FROM tranlog
    WHERE category IS NOT NULL
    GROUP BY category
    ORDER BY totalSpend DESC
  ''');
}

Future<List<Map<String, dynamic>>> getTransactionsByCategory(String category) async {
  final db = await database;
  return await db.query(
    'tranlog',
    where: 'category = ?',
    whereArgs: [category],
    orderBy: 'timestamp DESC',
  );
}

Future<List<Map<String, dynamic>>> getCategoryWiseSummaryByDate(int startTimestamp, int endTimestamp) async {
  final db = await database;
  return await db.rawQuery('''
    SELECT category, SUM(amount) as totalSpend
    FROM tranlog
    WHERE timestamp >= ? AND timestamp <= ?
    and transactionType ='Debited'
    GROUP BY category
    ORDER BY totalSpend DESC
  ''', [startTimestamp, endTimestamp]);
}

Future<List<Map<String, dynamic>>> getTransactionsByCategoryAndDate(String category, int startTimestamp, int endTimestamp) async {
  final db = await database;
  return await db.query(
    'tranlog',
    where: 'category = ? AND timestamp >= ? AND timestamp <= ? and transactionType =?',
    whereArgs: [category, startTimestamp, endTimestamp, 'Debited'],
    orderBy: 'timestamp DESC',
  );
}


}
