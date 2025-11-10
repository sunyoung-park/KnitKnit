package com.example.knitknit

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.knitknit/widget"
    private var methodChannel: MethodChannel? = null
    private var pendingIntent: Intent? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialIntent" -> {
                    val action = intent?.action
                    Log.d("MainActivity", "📱 getInitialIntent: $action")
                    result.success(action)
                }
                "getProductId" -> {
                    val productId = intent?.getStringExtra("product_id")
                    Log.d("MainActivity", "📱 getProductId: $productId")
                    result.success(productId)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // 앱이 이미 실행 중일 때 새 Intent 처리
        pendingIntent?.let { handleNewIntent(it) }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "🔵 onCreate: ${intent?.action}, productId=${intent?.getStringExtra("product_id")}")
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("MainActivity", "🟢 onNewIntent: ${intent.action}, productId=${intent.getStringExtra("product_id")}")
        
        if (methodChannel != null) {
            handleNewIntent(intent)
        } else {
            pendingIntent = intent
        }
    }

    private fun handleNewIntent(intent: Intent) {
        val action = intent.action
        val productId = intent.getStringExtra("product_id")
        
        Log.d("MainActivity", "📨 handleNewIntent: action=$action, productId=$productId")
        
        if (action == "ACTION_OPEN_PRODUCT" && productId != null) {
            methodChannel?.invokeMethod("onNewIntent", mapOf(
                "action" to action,
                "product_id" to productId
            ))
        }
    }
}
