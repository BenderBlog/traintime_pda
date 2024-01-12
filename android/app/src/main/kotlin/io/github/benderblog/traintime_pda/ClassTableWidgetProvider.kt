package io.github.benderblog.traintime_pda

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

private object ClassTableWidgetKeys {
    const val SWITCHER_NEXT = "class_table_switcher_next"
    const val DATE = "class_table_date"
    const val CLASS_TABLE_JSON = "class_table_json"
}

class ClassTableWidgetProvider : HomeWidgetProvider() {
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, arrayOf(appWidgetId).toIntArray())
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        //cache context
        //when ClassTableItemsService loads data, the context is needed for SharePreference.
        widgetData.registerOnSharedPreferenceChangeListener { sharedPreferences, key ->
            if (ClassTableWidgetKeys.CLASS_TABLE_JSON == key) {
                ClassTableItemsFactory.json = sharedPreferences.getString(key, "[]")!!
            }
        }
        appWidgetIds.forEach { widgetID ->
            val views = RemoteViews(
                context.packageName,
                R.layout.widget_class_table_layout
            ).apply {
                /*
                // Not for the moment...
                setImageViewResource(
                    R.id.widget_classtable_switcher,
                    if (widgetData.getBoolean(ClassTableWidgetKeys.SWITCHER_NEXT, true)) {
                        R.drawable.icon_next
                    } else {
                        R.drawable.icon_previous
                    }
                )
                setOnClickPendingIntent(
                    R.id.widget_classtable_switcher,
                    HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("widget://switcherClicked?widgetName=ClassTable")
                    )
                )
                 */
                setTextViewText(
                    R.id.widget_classtable_date,
                    widgetData.getString(ClassTableWidgetKeys.DATE, "Date Loading...")
                )
                //load class items
                val intent = Intent(context, ClassTableItemsService::class.java)
                intent.data = Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME));
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetID)
                intent.putExtra(
                    "json",
                    widgetData.getString(ClassTableWidgetKeys.CLASS_TABLE_JSON, "[]")
                )
                intent.putExtra("packageName", context.packageName)
                setRemoteAdapter(R.id.widget_classtable_list, intent)
            }
            appWidgetManager.updateAppWidget(widgetID, views)
        }
        appWidgetManager.notifyAppWidgetViewDataChanged(
            appWidgetIds,
            R.id.widget_classtable_list
        )
    }
}