package com.example.flutter_application_1;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.Telephony;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "sms_reader";
    private static final int SMS_PERMISSION_REQUEST_CODE = 101;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Setup MethodChannel for Flutter communication
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getTransactionSms")) {
                        if (ContextCompat.checkSelfPermission(this,
                                Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED) {
                            result.success(readTransactionSMS());
                        } else {
                            ActivityCompat.requestPermissions(this, new String[] { Manifest.permission.READ_SMS },
                                    SMS_PERMISSION_REQUEST_CODE);
                            result.error("PERMISSION_DENIED", "SMS read permission is required", null);
                        }
                    }
                });
    }

    @SuppressLint("Range")
    private List<HashMap<String, String>> readTransactionSMS() {
        List<HashMap<String, String>> transactions = new ArrayList<>();

        Cursor cursor = getContentResolver().query(
                Telephony.Sms.Inbox.CONTENT_URI,
                new String[] { Telephony.Sms.BODY, Telephony.Sms.DATE },
                null, null, Telephony.Sms.DATE + " DESC");

        if (cursor != null) {
            while (cursor.moveToNext()) {
                String smsBody = cursor.getString(cursor.getColumnIndex(Telephony.Sms.BODY));

                HashMap<String, String> transactionDetails = extractTransactionDetails(smsBody);
                if (transactionDetails != null) {
                    transactions.add(transactionDetails);
                }
            }
            cursor.close();
        }

        return transactions;
    }

    private HashMap<String, String> extractTransactionDetails(String smsBody) {
        HashMap<String, String> transactionData = new HashMap<>();

        // Regex to extract account number (last 4 digits), amount, and recipient
        Pattern pattern = Pattern.compile(
                "(?:A/C|Account|Acct|Card)\\s*\\*?(\\d{4})\\b.*?(?:debited|credited)\\s*Rs\\.?(\\d+[,.]?\\d*)\\s*(?:to|at|for)\\s*(\\w+)");
        Matcher matcher = pattern.matcher(smsBody);

        if (matcher.find()) {
            transactionData.put("accountNumber", matcher.group(1));
            transactionData.put("amount", matcher.group(2));
            transactionData.put("recipient", matcher.group(3));
            return transactionData;
        }
        return null;
    }
}
