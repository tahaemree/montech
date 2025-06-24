package com.example.montech

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.montech/emergency"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val uri = Uri.parse("smsto:05072520211")
                    val intent = Intent(Intent.ACTION_SENDTO, uri)
                    intent.putExtra("sms_body", "Acil durum! Lütfen yardım edin!")
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    startActivity(intent)
                    result.success(true)
                }
                "sendWhatsApp" -> {
                    val message = call.argument<String>("message") ?: ""
                    val intent = Intent(Intent.ACTION_VIEW)
                    intent.data = Uri.parse("https://api.whatsapp.com/send?phone=905072520211&text=${Uri.encode(message)}")
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.error("UNAVAILABLE", "WhatsApp yüklü değil", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
