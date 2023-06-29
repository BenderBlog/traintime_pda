package org.superbart.watermeter

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ClassTableWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->

            Log.i("ClassTableToShow", widgetData.all.toString())
            val views = RemoteViews(context.packageName, R.layout.widget_class_table_layout).apply {
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}