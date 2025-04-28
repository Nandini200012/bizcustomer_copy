package com.example.bizcustomer_copy

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val PHONE_DIALER_CHANNEL = "phone_dialer"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine) 
        configurePhoneDialerChannel(flutterEngine)
    }

    private fun configurePhoneDialerChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PHONE_DIALER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "makeCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    if (!phoneNumber.isNullOrEmpty()) {
                        val intent = Intent(Intent.ACTION_DIAL).apply {
                            data = Uri.parse("tel:$phoneNumber")
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK  // Added for safety
                        }
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(null)
                        } else {
                            result.error("NO_DIALER", "No dialer app found", null)
                        }
                    } else {
                        result.error("INVALID_NUMBER", "Phone number is empty", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}