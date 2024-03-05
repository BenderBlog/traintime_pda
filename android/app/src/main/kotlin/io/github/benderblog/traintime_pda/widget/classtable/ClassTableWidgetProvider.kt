package io.github.benderblog.traintime_pda.widget.classtable

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.widget.RemoteViews
import androidx.core.content.edit
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import io.github.benderblog.traintime_pda.R
import io.github.benderblog.traintime_pda.model.ClassTableWidgetKeys
import io.github.benderblog.traintime_pda.utils.toCalendar
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

class ClassTableWidgetProvider : HomeWidgetProvider() {
    companion object {
        private const val CLICK_NEXT_DAY_ACTION =
            "io.github.benderblog.traintime_pda.widget.classtable.CLICK_NEXT_DAY"
        private const val CLICK_PREVIOUS_DAY_ACTION =
            "io.github.benderblog.traintime_pda.widget.classtable.CLICK_PREVIOUS_DAY"
    }

    private lateinit var context: Context
    private var showToday: Boolean
        set(value) {
            context.getSharedPreferences("class_table_widget", Context.MODE_PRIVATE).apply {
                edit(true) {
                    putBoolean("show_today", value)
                }
            }
        }
        get() {
            return context.getSharedPreferences(ClassTableWidgetKeys.SP_FILE_NAME, Context.MODE_PRIVATE)
                .getBoolean(
                    "show_today", true
                )
        }

    fun update() {
        AppWidgetManager.getInstance(context).let { appWidgetManager ->
            onUpdate(
                context, appWidgetManager,
                appWidgetManager.getAppWidgetIds(
                    ComponentName(context, ClassTableWidgetProvider::class.java)
                )
            )
        }
    }

    override fun onReceive(context: Context, intent: Intent?) {
        this.context = context
        super.onReceive(context, intent)
        intent?.let {
            when (intent.action) {
                CLICK_NEXT_DAY_ACTION -> {
                    showToday = false
                    update()
                }

                CLICK_PREVIOUS_DAY_ACTION -> {
                    showToday = true
                    update()
                }
            }
        }
    }

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
        appWidgetIds.forEach { widgetID ->
            val views = RemoteViews(
                context.packageName,
                R.layout.widget_class_table_layout
            ).apply {
                setImageViewResource(
                    R.id.widget_classtable_switcher,
                    if (showToday) {
                        R.drawable.icon_next
                    } else {
                        R.drawable.icon_previous
                    }
                )
                if (showToday) {
                    setTextViewText(
                        R.id.widget_classtable_date,
                        "${
                            SimpleDateFormat(
                                "MM月dd日 EEE",
                                Locale.getDefault()
                            ).format(Date())
                        }（今日）"
                    )
                } else {
                    setTextViewText(
                        R.id.widget_classtable_date,
                        "${
                            SimpleDateFormat(
                                "MM月dd日 EEE",
                                Locale.getDefault()
                            ).format(
                                Date().toCalendar().apply { add(Calendar.DAY_OF_YEAR, 1) }.time
                            )
                        }（明日）"
                    )
                }
                setOnClickPendingIntent(
                    R.id.widget_classtable_switcher,
                    PendingIntent.getBroadcast(
                        context,
                        114514,
                        Intent(context, ClassTableWidgetProvider::class.java).apply {
                            action =
                                if (showToday) CLICK_NEXT_DAY_ACTION else CLICK_PREVIOUS_DAY_ACTION
                        },
                        if (Build.VERSION.SDK_INT >= 31) (PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE) else PendingIntent.FLAG_UPDATE_CURRENT
                    )
                )
                //load class items
                val intent = Intent(context, ClassTableItemsService::class.java)
                intent.data = Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME));
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetID)
                intent.putExtra(ClassTableWidgetKeys.PACKAGE_NAME, context.packageName)
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