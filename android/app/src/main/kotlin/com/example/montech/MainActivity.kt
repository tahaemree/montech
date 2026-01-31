package com.example.montech

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.telephony.SmsManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.montech/emergency"
    private val TAG = "MonTech"
    private val SMS_PERMISSION_REQUEST_CODE = 101

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phone = call.argument<String>("phone") ?: ""
                    val message = call.argument<String>("message") ?: "Acil durum! Lütfen yardım edin!"
                    
                    if (phone.isEmpty()) {
                        result.error("INVALID_PHONE", "Telefon numarası bulunamadı", null)
                        return@setMethodCallHandler
                    }
                    
                    // Check SMS permission
                    if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.SEND_SMS) 
                        == PackageManager.PERMISSION_GRANTED) {
                        // Direct SMS sending - critical for emergency
                        try {
                            val smsManager = SmsManager.getDefault()
                            
                            // Format phone number
                            var formattedPhone = phone
                            if (formattedPhone.startsWith("0")) {
                                formattedPhone = "+90" + formattedPhone.substring(1)
                            } else if (!formattedPhone.startsWith("+")) {
                                formattedPhone = "+90$formattedPhone"
                            }
                            
                            // Split long messages
                            val parts = smsManager.divideMessage(message)
                            if (parts.size > 1) {
                                smsManager.sendMultipartTextMessage(formattedPhone, null, parts, null, null)
                            } else {
                                smsManager.sendTextMessage(formattedPhone, null, message, null, null)
                            }
                            
                            Log.d(TAG, "SMS sent successfully to $formattedPhone")
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e(TAG, "SMS sending error: ${e.message}")
                            // Fallback to Intent method
                            val uri = Uri.parse("smsto:$phone")
                            val intent = Intent(Intent.ACTION_SENDTO, uri)
                            intent.putExtra("sms_body", message)
                            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            startActivity(intent)
                            result.success(true)
                        }
                    } else {
                        // Request permission and fallback to Intent
                        ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.SEND_SMS), SMS_PERMISSION_REQUEST_CODE)
                        
                        val uri = Uri.parse("smsto:$phone")
                        val intent = Intent(Intent.ACTION_SENDTO, uri)
                        intent.putExtra("sms_body", message)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                        result.success(true)
                    }
                }
                "sendWhatsApp" -> {
                    val phone = call.argument<String>("phone") ?: ""
                    val message = call.argument<String>("message") ?: ""
                    
                    if (phone.isEmpty()) {
                        result.error("INVALID_PHONE", "Telefon numarası bulunamadı", null)
                        return@setMethodCallHandler
                    }
                    
                    // Format the phone number for WhatsApp (remove + and leading 0, ensure it starts with country code)
                    var formattedPhone = phone
                    if (formattedPhone.startsWith("+")) {
                        formattedPhone = formattedPhone.substring(1)
                    } else if (formattedPhone.startsWith("0")) {
                        formattedPhone = "90" + formattedPhone.substring(1)  // Assuming Turkish number
                    } else if (!formattedPhone.startsWith("90")) {
                        formattedPhone = "90$formattedPhone"  // Assuming Turkish number
                    }
                    
                    val intent = Intent(Intent.ACTION_VIEW)
                    intent.data = Uri.parse("https://api.whatsapp.com/send?phone=$formattedPhone&text=${Uri.encode(message)}")
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
