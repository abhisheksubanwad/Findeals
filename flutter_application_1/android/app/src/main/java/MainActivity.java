package com.example.flutter_application_1;

import android.Manifest;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import android.content.SharedPreferences;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.sms_reader_app/sms";
    private static final int SMS_PERMISSION_CODE = 123;
    private static final long TWO_MONTHS_MILLIS = 60L * 24 * 60 * 60 * 1000L; // Last 60 days
    private long lastProcessedDate = 0; // Stores last processed SMS time
    private static final String PREFS_NAME = "SmsPrefs";
    private static final String LAST_PROCESSED_KEY = "lastProcessedDate";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getTxnSms")) {
                        System.out.println("🔄 Method Called: getTxnSms");
                        if (checkSmsPermission()) {
                            System.out.println("✅ SMS Permission Granted");
                            List<Map<String, String>> txnSmsList = getTransactionSms();
                            result.success(txnSmsList);
                        } else {
                            System.out.println("❌ SMS Permission Denied, Requesting...");
                            requestSmsPermission();
                            result.error("PERMISSION_DENIED", "SMS permission denied", null);
                        }
                    } else {
                        System.out.println("⚠️ Method Not Implemented: " + call.method);
                        result.notImplemented();
                    }
                });
    }

    private boolean checkSmsPermission() {
        return ContextCompat.checkSelfPermission(this,
                Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED;
    }

    private void requestSmsPermission() {
        ActivityCompat.requestPermissions(this, new String[] { Manifest.permission.READ_SMS }, SMS_PERMISSION_CODE);
    }

    private List<Map<String, String>> getTransactionSms() {
        List<Map<String, String>> smsList = new ArrayList<>();
        Uri uri = Uri.parse("content://sms/inbox");
        Cursor cursor = null;

        long startDate = System.currentTimeMillis() - TWO_MONTHS_MILLIS;
        System.out.println("📩 Fetching SMS from: " + startDate);

        try {
            String[] projection = { "address", "body", "date" };
            String selection = "date >= ?";
            String[] selectionArgs = { String.valueOf(startDate) };
            String sortOrder = "date ASC"; // Oldest first

            cursor = getContentResolver().query(uri, projection, selection, selectionArgs, sortOrder);

            if (cursor != null) {
                while (cursor.moveToNext()) {
                    String sender = cursor.getString(cursor.getColumnIndexOrThrow("address"));
                    String body = cursor.getString(cursor.getColumnIndexOrThrow("body"));
                    long smsDate = cursor.getLong(cursor.getColumnIndexOrThrow("date"));

                    System.out.println("📨 SMS Received: " + sender + " | " + body);

                    if (isTransactionMessage(sender, body)) {
                        Map<String, String> sms = new HashMap<>();
                        sms.put("address", sender);
                        sms.put("body", body);
                        sms.put("date", String.valueOf(smsDate));
                        smsList.add(sms);

                        System.out.println("✅ Transaction SMS Added: " + sender + " | " + body);
                    }

                }
            }
        } catch (Exception e) {
            System.out.println("❌ Error fetching SMS: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        System.out.println("📊 Total Transaction SMS Found: " + smsList.size());
        return smsList;
    }

    private boolean isTransactionMessage(String sender, String body) {
        if (body == null || sender == null)
            return false;

        String lowerBody = body.toLowerCase();
        sender = sender.toLowerCase();

        String[] keywords = { "debited", "txn", "transaction", "spent", "rs", "inr", "balance", "amount", "upi",
                "payment", "purchased", "loan",
                "emi" };
        String[] banks = {
                "hdfc", "icici", "sbi", "axis", "kotak", "bob", "idfc", "rbl", "indusind", "yes", "onecard", "slice",
                "au", "federal", "canara", "pnb", "union", "bandhan", "scb", "hsbc", "citi", "dbs",
                "jupiter", "fi", "navi", "paytm", "amazon", "phonepe", "freecharge", "mobikwik"
        };

        if (sender.length() >= 6) {
            String possibleBankId = sender.substring(0, 6);

            boolean bankMatch = false;
            for (String bank : banks) {
                if (containsPartialMatch(possibleBankId, bank) || containsPartialMatch(sender, bank)) {
                    bankMatch = true;
                    break;
                }
            }

            if (bankMatch) {
                for (String keyword : keywords) {
                    if (lowerBody.contains(keyword)) {
                        if (lowerBody.matches(".*\\bxx[0-9]{3,4}\\b.*")
                                || lowerBody.matches(".*\\bending in [0-9]{4}\\b.*")) {
                            System.out.println("✅ Transaction Identified: " + sender + " | " + body);
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    private boolean containsPartialMatch(String text, String keyword) {
        int matchCount = 0;
        int requiredMatch = Math.max(2, keyword.length() / 2);

        for (int i = 0; i < keyword.length(); i++) {
            if (text.contains(keyword.substring(i, Math.min(i + 2, keyword.length())))) {
                matchCount++;
                if (matchCount >= requiredMatch)
                    return true;
            }
        }
        return false;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
            @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == SMS_PERMISSION_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                System.out.println("✅ SMS Permission Granted via Dialog");
            } else {
                System.out.println("❌ SMS Permission Denied via Dialog");
            }
        }
    }
}
