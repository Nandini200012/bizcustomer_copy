package com.example.biz_cus

import android.content.Intent
import android.net.Uri
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "phone_dialer"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { 
            call, result ->
            when (call.method) {
                "makeCall" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    if (!phoneNumber.isNullOrEmpty()) {
                        openDialer(phoneNumber, result)
                    } else {
                        result.error("INVALID_NUMBER", "Phone number is empty", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openDialer(phoneNumber: String, result: MethodChannel.Result) {
        // First try standard tel: URI
        val telUri = Uri.parse("tel:$phoneNumber")
        val dialIntent = Intent(Intent.ACTION_DIAL, telUri).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }

        // Alternative format for some devices
        val telUri2 = Uri.parse("tel:${Uri.encode(phoneNumber)}")
        val dialIntent2 = Intent(Intent.ACTION_DIAL, telUri2).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }

        try {
            // Check for any dialer app
            val dialerInfo = dialIntent.resolveActivityInfo(packageManager, PackageManager.MATCH_ALL)
            
            if (dialerInfo != null) {
                startActivity(dialIntent)
                result.success(null)
            } else {
                // Try alternative intent
                if (dialIntent2.resolveActivity(packageManager) != null) {
                    startActivity(dialIntent2)
                    result.success(null)
                } else {
                    result.error(
                        "NO_DIALER", 
                        "No app found to handle phone calls. Please install a dialer app.",
                        null
                    )
                }
            }
        } catch (e: Exception) {
            result.error(
                "DIAL_FAILED", 
                "Failed to open dialer: ${e.localizedMessage ?: "Unknown error"}", 
                null
            )
        }
    }
}