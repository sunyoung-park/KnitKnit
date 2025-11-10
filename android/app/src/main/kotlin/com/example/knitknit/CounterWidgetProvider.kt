package com.example.knitknit

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.app.PendingIntent
import android.net.Uri
import android.util.Log
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class CounterWidgetProvider : AppWidgetProvider() {
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val productName = widgetData.getString("widget_product_name", "횟수 체크")
        val currentCount = widgetData.getInt("widget_current_count", 0)
        val productId = widgetData.getString("widget_product_id", "")

        val views = RemoteViews(context.packageName, R.layout.counter_widget)
        
        // 데이터 설정
        views.setTextViewText(R.id.widget_title, productName)
        views.setTextViewText(R.id.widget_count, currentCount.toString())

        // 클릭 가능한 영역 (제목 + 카운트) - 앱 열기
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            launchIntent.apply {
                action = "ACTION_OPEN_PRODUCT"
                putExtra("product_id", productId)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            views.setOnClickPendingIntent(
                R.id.widget_clickable_area,
                PendingIntent.getActivity(
                    context,
                    productId.hashCode(),
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )
            Log.d("WidgetProvider", "✅ 클릭 가능한 영역 설정 완료: productId=$productId")
        }

        // + 버튼
        val increaseIntent = Intent(context, CounterWidgetProvider::class.java).apply {
            action = "ACTION_INCREASE"
            putExtra("product_id", productId)
        }
        views.setOnClickPendingIntent(
            R.id.button_increase,
            PendingIntent.getBroadcast(
                context, 
                0, 
                increaseIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )

        // - 버튼
        val decreaseIntent = Intent(context, CounterWidgetProvider::class.java).apply {
            action = "ACTION_DECREASE"
            putExtra("product_id", productId)
        }
        views.setOnClickPendingIntent(
            R.id.button_decrease,
            PendingIntent.getBroadcast(
                context, 
                1, 
                decreaseIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )

        // Reset 버튼
        val resetIntent = Intent(context, CounterWidgetProvider::class.java).apply {
            action = "ACTION_RESET"
            putExtra("product_id", productId)
        }
        views.setOnClickPendingIntent(
            R.id.button_reset,
            PendingIntent.getBroadcast(
                context, 
                2, 
                resetIntent, 
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        )

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        Log.d("WidgetProvider", "🔔 onReceive 호출됨: action=${intent.action}")
        
        val productId = intent.getStringExtra("product_id")
        if (productId == null) {
            Log.e("WidgetProvider", "❌ productId가 null입니다")
            return
        }
        
        Log.d("WidgetProvider", "📦 productId: $productId")
        
        val widgetData = HomeWidgetPlugin.getData(context)
        
        when (intent.action) {
            "ACTION_INCREASE" -> {
                Log.d("WidgetProvider", "➕ 증가 버튼 클릭")
                widgetData.edit().apply {
                    putString("widget_action", "increase")
                    putString("widget_action_product_id", productId)
                    apply()
                }
                Log.d("WidgetProvider", "✅ SharedPreferences에 저장: increase, $productId")
            }
            "ACTION_DECREASE" -> {
                Log.d("WidgetProvider", "➖ 감소 버튼 클릭")
                widgetData.edit().apply {
                    putString("widget_action", "decrease")
                    putString("widget_action_product_id", productId)
                    apply()
                }
                Log.d("WidgetProvider", "✅ SharedPreferences에 저장: decrease, $productId")
            }
            "ACTION_RESET" -> {
                Log.d("WidgetProvider", "🔄 리셋 버튼 클릭")
                widgetData.edit().apply {
                    putString("widget_action", "reset")
                    putString("widget_action_product_id", productId)
                    apply()
                }
                Log.d("WidgetProvider", "✅ SharedPreferences에 저장: reset, $productId")
            }
            else -> {
                Log.d("WidgetProvider", "⚠️ 알 수 없는 action: ${intent.action}")
                return
            }
        }
        
        Log.d("WidgetProvider", "✅ onReceive 완료")
    }
}

