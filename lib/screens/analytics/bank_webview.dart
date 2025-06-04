import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/users_product.dart';

// --- Static Mapping of Bank to Offer Page URLs
const Map<String, String> bankOffersUrls = {
  "ICICI": "https://www.icicibank.com/offers",
  "HDFC": "https://offers.smartbuy.hdfcbank.com/",
  "ONECARD": "https://www.getonecard.app/offers/",
  "AXIS": "https://www.axisbank.com/retail/offers",
  "SBI": "https://www.sbicard.com/en/personal/offers.page",
};

// --- Main Widget to Show Bank List and Navigate to Offers
class BankOffersListPage extends StatelessWidget {
  const BankOffersListPage({super.key});

  // Load and filter bank names from Hive
  Future<List<String>> getConfirmedBanks() async {
    try {
      final box = await Hive.openBox<UserProductModel>('user_products');

      final allBankNames = box.values
          .map((e) => e.bankName.trim().toUpperCase())
          .toList();

      print("All bank names from Hive: $allBankNames");

      final confirmed = allBankNames
          .where((bankName) => bankOffersUrls.containsKey(bankName))
          .toSet()
          .toList();

      print("Confirmed banks with offers: $confirmed");

      return confirmed;
    } catch (e) {
      print("Error loading bank names from Hive: $e");
      throw Exception("Could not load bank data.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getConfirmedBanks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Your Bank Offers')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final confirmedBanks = snapshot.data ?? [];

        return Scaffold(
          appBar: AppBar(title: const Text('Your Bank Offers')),
          body: confirmedBanks.isEmpty
              ? const Center(child: Text('No eligible bank offers found.'))
              : ListView.builder(
                  itemCount: confirmedBanks.length,
                  itemBuilder: (context, index) {
                    final bank = confirmedBanks[index];
                    final url = bankOffersUrls[bank]!;

                    return ListTile(
                      title: Text(bank),
                      trailing: const Icon(Icons.open_in_browser),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BankWebViewPage(
                              title: "$bank Offers",
                              url: url,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

// --- WebView Screen
class BankWebViewPage extends StatelessWidget {
  final String title;
  final String url;

  const BankWebViewPage({required this.title, required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
