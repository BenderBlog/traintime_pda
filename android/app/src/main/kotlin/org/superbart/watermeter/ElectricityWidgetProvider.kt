package org.superbart.watermeter

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

private object Keys {
    const val TITLE = "electricity_title"
    const val INFO = "electricity_info"
}

class ElectricityWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->

            Log.i("ElectricitySession", widgetData.all.toString())
            val views = RemoteViews(context.packageName, R.layout.widget_electricity_layout).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                // Swap Title Text by calling Dart Code in the Background
                setTextViewText(
                    R.id.widget_electricity_title, widgetData.getString(Keys.TITLE, null)
                        ?: "Title Loading"
                )
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("widget://titleClicked?widgetName=electricityWidget")
                )
                setOnClickPendingIntent(R.id.widget_electricity_title, backgroundIntent)

                val message = widgetData.getString(Keys.INFO, null)
                setTextViewText(
                    R.id.widget_electricity_info, message
                        ?: "Info Loading"
                )
                // Detect App opened via Click inside Flutter
                val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("widget://message?message=$message?widgetName=electricityWidget")
                )
                setOnClickPendingIntent(R.id.widget_electricity_info, pendingIntentWithData)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}