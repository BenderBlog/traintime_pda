package io.github.benderblog.traintime_pda

import android.widget.RemoteViews
import android.widget.RemoteViewsService.RemoteViewsFactory
import org.json.JSONObject

data class ClassItem(
    val name: String,
    val teacher: String,
    val classroom: String,
    val startTime: String,
    val endTime: String,
)

class ClassTableItemsFactory(private val packageName: String) :
    RemoteViewsFactory {
    private val classItems = ArrayList<ClassItem>()

    companion object {
        // It is difficult for RemoteViewsFactory to get access to SharedPreference.
        // However we need SharedPreference to act as data bridge between Native and Dart,
        // this json variable is used to store the latest data of class table.
        // Also see ClassTableWidgetProvider.onUpdate(...), in which the json is updated.
        var json = "[]"
            @Synchronized
            set(value) {
                field = value
            }
    }

    init {
        reloadData()
    }

    private fun reloadData() {
        try {
            val classItems = JSONObject(ClassTableItemsFactory.json)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onCreate() {
    }

    override fun onDataSetChanged() {
        classItems.clear()
        reloadData()
    }

    override fun onDestroy() {
    }

    override fun getCount(): Int = classItems.size

    override fun getViewAt(position: Int): RemoteViews? {
        if (position < 0 || position >= classItems.size) {
            return null
        }
        val classItem = classItems[position]
        return RemoteViews(packageName, R.layout.widget_classtable_item).apply {
            setTextViewText(R.id.widget_classtable_item_start_time, classItem.startTime)
            setTextViewText(R.id.widget_classtable_item_end_time, classItem.endTime)
            setTextViewText(R.id.widget_classtable_item_name, classItem.name)
            setTextViewText(R.id.widget_classtable_item_classroom, classItem.classroom)
            setTextViewText(R.id.widget_classtable_item_teacher, classItem.teacher)
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = false
}