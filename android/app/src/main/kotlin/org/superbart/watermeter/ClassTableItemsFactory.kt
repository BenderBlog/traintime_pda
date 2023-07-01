package org.superbart.watermeter

import android.widget.RemoteViews
import android.widget.RemoteViewsService.RemoteViewsFactory

data class ClassItem(
    val name: String,
    val teacher: String,
    val start: Int,
    val end: Int,
    val classroom: String,
    val startTime: String,
    val endTime: String,
)

class ClassTableItemsFactory(private val packageName: String, private val json: String) :
    RemoteViewsFactory {
    private val classItems = ArrayList<ClassItem>()

    init {
        //TODO parse json
        classItems.add(
            ClassItem(
                "Test1", "Teacher1", 1, 2, "A-101", "08:30", "10:05"
            )
        )
        classItems.add(
            ClassItem(
                "Test2", "Teacher2", 4, 5, "B-323", "14:00", "15:35"
            )
        )
    }

    override fun onCreate() {
    }

    override fun onDataSetChanged() {
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