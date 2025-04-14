import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './transaction_data.dart';

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
        'timestamp': transaction.timestamp,
        'productType': transaction.productType,
        'transactionType': transaction.transactionType,
        'merchantName': transaction.merchantName,
        'category': null,  // ✅ Initially NULL
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
}
