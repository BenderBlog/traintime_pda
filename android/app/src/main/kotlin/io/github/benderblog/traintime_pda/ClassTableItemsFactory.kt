package io.github.benderblog.traintime_pda

import android.widget.RemoteViews
import android.widget.RemoteViewsService.RemoteViewsFactory
import org.json.JSONObject

private val CLASS_INDEX_TIME = arrayOf(
    "08:30",
    "09:15",
    "09:20",
    "10:05",
    "10:25",
    "11:10",
    "11:15",
    "12:00",
    "14:00",
    "14:45",
    "14:50",
    "15:35",
    "15:55",
    "16:40",
    "16:45",
    "17:30",
    "19:00",
    "19:45",
    "19:55",
    "20:30",
)

data class ClassItem(
    val name: String,
    val teacher: String,
    val start: Int,
    val end: Int,
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
        var json = "{\"list\":[]}"
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
            val jsonObject = JSONObject(ClassTableItemsFactory.json)
            val classList = jsonObject.getJSONArray("list")
            for (i in 0 until classList.length()) {
                classList.getJSONObject(i).run {
                    val start = getInt("start_time")
                    val end = getInt("end_time")
                    classItems.add(
                        ClassItem(
                            getString("name"),
                            getString("teacher"),
                            start,
                            end,
                            getString("place"),
                            CLASS_INDEX_TIME[start - 1],
                            CLASS_INDEX_TIME[end - 1]
                        )
                    )
                }
            }
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
            setTextViewText(R.id.widget_classtable_item_start, classItem.start.toString())
            setTextViewText(R.id.widget_classtable_item_end, classItem.end.toString())
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