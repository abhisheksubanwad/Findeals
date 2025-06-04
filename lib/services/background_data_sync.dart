import 'package:workmanager/workmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      // Step 1: Hive init
      try {
        final dir = await getApplicationDocumentsDirectory();
        Hive.init(dir.path);
        print("✅ Hive initialized");
      } catch (e) {
        print("❌ Hive init error: $e");
      }

      Box? categoryBox;
      try {
        categoryBox = await Hive.openBox('merchantCategory');
        print("✅ Hive box opened");
      } catch (e) {
        print("❌ Hive box open error: $e");
      }

      // Step 2: Supabase init
      try {
        await dotenv.load(); // required in background isolate too
        await Supabase.initialize(
          url: dotenv.env['SUPABASE_URL']!,
          anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
        );
        print("✅ Supabase initialized");
      } catch (e) {
        print("❌ Supabase init error: $e");
      }

      List<dynamic> mappings = [];
      try {
        final supabase = Supabase.instance.client;
        mappings = await supabase.from('merchant_category').select();
        print("✅ Fetched ${mappings.length} mappings from Supabase");
      } catch (e) {
        print("❌ Supabase fetch error: $e");
      }

      try {
        if(mappings.isNotEmpty){
        await categoryBox?.clear();
        for (var item in mappings) {
          final merchant = item['merchant'];
          final category = item['category'];
          if (merchant != null && category != null) {
            categoryBox?.put(merchant.toString(), category.toString());
          }
        }
        print("✅ Stored mappings in Hive ($taskName)");
      }} catch (e) {
        print("❌ Hive write error: $e");
      }

      await categoryBox?.close();
    } catch (e) {
      print("❌ Unexpected error in $taskName: $e");
    }

    return Future.value(true);
  });
}