import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import  'package:findeals/providers/transaction_provider.dart';
import '../analytics/transaction_page.dart';
import '../analytics/category_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Transactions & Analytics
      child: Scaffold(
        appBar: AppBar(
          title: Text("Analytics"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Transactions"),
              Tab(text: "Analytics"),
              Tab(text: "Category Analytics"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TransactionsPage(), // Transactions tab
            AnalyticsContent(),
            CategoryAnalyticsScreen()
             // Your analytics code
          ],
        ),
      ),
    );
  }
}

// ---------------- ANALYTICS CONTENT ----------------
class AnalyticsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    // Filter transactions for the current month
    DateTime now = DateTime.now();
    var currentMonthTransactions = provider.transactions.where((txn) =>
        txn.timestamp.year == now.year && txn.timestamp.month == now.month && txn.transactionType == "Debited").toList();

    // Compute total spends by type
    double upiTotal = _calculateTotal(currentMonthTransactions, "UPI");
    double creditTotal = _calculateTotal(currentMonthTransactions, "Credit Card");
    double debitTotal = _calculateTotal(currentMonthTransactions, "Debit Card");

    // Compute transaction count by type
    int upiCount = _calculateCount(currentMonthTransactions, "UPI");
    int creditCount = _calculateCount(currentMonthTransactions, "Credit Card");
    int debitCount = _calculateCount(currentMonthTransactions, "Debit Card");

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Spending Breakdown (Current Month)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildPieChart(upiTotal, creditTotal, debitTotal),
          SizedBox(height: 30),
          Text(
            "Transaction Count Comparison",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildBarChart(upiCount, creditCount, debitCount),
        ],
      ),
    );
  }

  // Pie Chart for Spend Breakdown
  Widget _buildPieChart(double upi, double credit, double debit) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: upi,
              title: "UPI\n₹${upi.toStringAsFixed(0)}",
              color: Colors.blue,
              radius: 60,
            ),
            PieChartSectionData(
              value: credit,
              title: "Credit\n₹${credit.toStringAsFixed(0)}",
              color: Colors.red,
              radius: 60,
            ),
            PieChartSectionData(
              value: debit,
              title: "Debit\n₹${debit.toStringAsFixed(0)}",
              color: Colors.green,
              radius: 60,
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  // Bar Chart for Transaction Count
  Widget _buildBarChart(int upi, int credit, int debit) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(
                toY: upi.toDouble(),
                color: Colors.blue,
                width: 20,
              )
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                toY: credit.toDouble(),
                color: Colors.red,
                width: 20,
              )
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                toY: debit.toDouble(),
                color: Colors.green,
                width: 20,
              )
            ]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text("UPI");
                    case 1:
                      return Text("Credit");
                    case 2:
                      return Text("Debit");
                    default:
                      return Text("");
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to calculate total amount spent
  double _calculateTotal(List transactions, String type) {
    return transactions
        .where((txn) => txn.productType == type)
        .fold(0.0, (sum, txn) => sum + txn.amount);
  }

  // Helper function to count transactions
  int _calculateCount(List transactions, String type) {
    return transactions.where((txn) => txn.productType == type).length;
  }
}
