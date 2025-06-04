
import '../services/background_data_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Future<void> setupBackgroundTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('is_first_time') ?? true;
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);


  if (isFirstTime) {
    // 👇 Runs once on first install
    await Workmanager().registerOneOffTask(
      "first-time-merchant-sync",
      "oneTimeMerchantFetch",
      initialDelay: Duration(seconds: 5),
    );
    await prefs.setBool('is_first_time', false); // Mark setup as done
  }

  // 👇 Schedules the recurring sync every 5 hours
  await Workmanager().registerPeriodicTask(
    "scheduled-merchant-sync",
    "periodicMerchantFetch",
    frequency: const Duration(hours: 5),
    initialDelay: const Duration(seconds: 10),
    backoffPolicy: BackoffPolicy.linear,
  );
}

