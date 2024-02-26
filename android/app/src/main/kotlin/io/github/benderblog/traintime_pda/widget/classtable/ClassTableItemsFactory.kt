package io.github.benderblog.traintime_pda.widget.classtable

import android.content.Context
import android.util.Log
import android.widget.RemoteViews
import android.widget.RemoteViewsService.RemoteViewsFactory
import com.google.gson.Gson
import io.github.benderblog.traintime_pda.R
import io.github.benderblog.traintime_pda.model.ClassTableConstants
import io.github.benderblog.traintime_pda.model.ClassTableData
import io.github.benderblog.traintime_pda.model.ExamData
import io.github.benderblog.traintime_pda.model.Source
import io.github.benderblog.traintime_pda.model.TimeLineItem
import io.github.benderblog.traintime_pda.model.UserDefinedClassData
import io.github.benderblog.traintime_pda.model.endTime
import io.github.benderblog.traintime_pda.model.startTime
import io.github.benderblog.traintime_pda.utils.day
import io.github.benderblog.traintime_pda.utils.month
import io.github.benderblog.traintime_pda.utils.toCalendar
import io.github.benderblog.traintime_pda.utils.year
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale


class ClassTableItemsFactory(private val packageName: String, private val context: Context) :
    RemoteViewsFactory {

    private val todayArrangements = mutableListOf<TimeLineItem>()

    //TODO show tomorrow arrangements
    private val tomorrowArrangements = mutableListOf<TimeLineItem>()
    private val arrangements: List<TimeLineItem>
        get() = if (showTodayArrangements) todayArrangements else tomorrowArrangements
    private var todayIndex: Int = 0
    private var curWeekIndex: Int = 0
    private lateinit var classTableData: ClassTableData
    private lateinit var examData: ExamData

    private var errorMessage: String? = null

    companion object {
        @JvmStatic
        var schoolClassJsonData: String? = null
            @Synchronized
            set

        @JvmStatic
        var userDefinedClassJsonData: String? = null
            @Synchronized
            set

        @JvmStatic
        var examJsonData: String? = null
            @Synchronized
            set

        @JvmStatic
        @set:Synchronized
        var showTodayArrangements = true

        @JvmStatic
        private val gson = Gson()

        @JvmStatic
        @set:Synchronized
        var weekSwift: Long = 0
    }

    private fun reloadData() {
        Log.d("ClassTableWidget", "reloadData()")
        todayArrangements.clear()
        tomorrowArrangements.clear()
        try {
            // load week swift config (shared_prefs: flutter.swift) and so on.
            loadBasicConfig()
            // decode json data and add them to arrangements(today and tomorrow)
            loadClassTableData()
            loadExamData()
            sortArrangements()
        } catch (e: Exception) {
            errorMessage = e.message
            e.printStackTrace()
        }
    }

    private fun loadBasicConfig() {
        // initialize data
        val schoolClassTableData = schoolClassJsonData?.let {
            gson.fromJson(it, ClassTableData::class.java)
        } ?: ClassTableData.EMPTY
        val userDefinedClassData = userDefinedClassJsonData ?.let {
            gson.fromJson(it, UserDefinedClassData::class.java)
        } ?: UserDefinedClassData.EMPTY
        examJsonData?.let {
            examData = gson.fromJson(it, ExamData::class.java)
        } ?: { examData = ExamData.EMPTY }
        // get week swift (week offset)
        val prefs = context.getSharedPreferences(
            ClassTableConstants.CONFIG_SHARED_PREFS_NAME,
            Context.MODE_PRIVATE
        )
        weekSwift = prefs.getLong(ClassTableConstants.CONFIG_WEEK_SWIFT_KEY, 0)
        // merge classtable with user added class
        classTableData = schoolClassTableData.copy(
            userDefinedDetail = userDefinedClassData.userDefinedDetail,
            timeArrangement = schoolClassTableData.timeArrangement + userDefinedClassData.timeArrangement,
        )
        // calculate day index of today
        var startDay: Date =
            SimpleDateFormat(ClassTableConstants.DATE_FORMAT_STR, Locale.getDefault())
                .parse(classTableData.termStartDay)
                ?: throw StartDayFetchError(classTableData.termStartDay)
        val calendar = Calendar.getInstance()
        calendar.time = startDay
        calendar.add(Calendar.DAY_OF_YEAR, (7 * weekSwift).toInt())
        startDay = calendar.time
        var delta = (System.currentTimeMillis() - startDay.time) / 86400000
        if (delta < 0) {
            delta = -7
        }
        curWeekIndex = (delta / 7).toInt()
        todayIndex = calendar.apply {
            time = Date()
        }.get(Calendar.DAY_OF_WEEK)
        if (todayIndex == 1) {
            todayIndex = 7
        } else {
            todayIndex -= 1
        }
    }

    private fun loadClassTableData() {
        // today classes
        loadOneDayClass(curWeekIndex, todayIndex, todayArrangements)
        // tomorrow classes
        var tomorrowIndex = todayIndex + 1
        var weekTomorrowIndex = curWeekIndex
        if (tomorrowIndex > 7) {
            tomorrowIndex = 1
            weekTomorrowIndex += 1
        }
        loadOneDayClass(weekTomorrowIndex, tomorrowIndex, tomorrowArrangements)
    }

    private fun loadOneDayClass(
        weekIndex: Int,
        dayIndex: Int,
        arrangements: MutableList<TimeLineItem>
    ) {
        if (weekIndex >= 0 && weekIndex < classTableData.semesterLength) {
            for (arrangement in classTableData.timeArrangement) {
                if (arrangement.weekList.size > weekIndex
                    && arrangement.weekList[weekIndex]
                    && arrangement.day == dayIndex
                ) {
                    arrangements.add(
                        TimeLineItem(
                            name = classTableData.getClassName(arrangement),
                            teacher = arrangement.teacher ?: "未知教师",
                            place = arrangement.classroom ?: "未安排教室",
                            startTime = Calendar.getInstance().apply {
                                time = Date()
                                val startTimePoints =
                                    ClassTableConstants.CLASS_TIME_POINTS_PAIR[(arrangement.start - 1) * 2]
                                set(Calendar.HOUR_OF_DAY, startTimePoints[0])
                                set(Calendar.MINUTE, startTimePoints[1])
                            }.time,
                            endTime = Calendar.getInstance().apply {
                                time = Date()
                                val endTimePoints =
                                    ClassTableConstants.CLASS_TIME_POINTS_PAIR[(arrangement.stop - 1) * 2 + 1]
                                set(Calendar.HOUR_OF_DAY, endTimePoints[0])
                                set(Calendar.MINUTE, endTimePoints[1])
                            }.time,
                            start = arrangement.start,
                            end = arrangement.stop,
                            type = Source.SCHOOL
                        )
                    )
                }
            }
        }
    }

    private fun loadExamData() {
        val curCalendar = Date().toCalendar()
        loadOneDayExam(curCalendar, todayArrangements)
        loadOneDayExam(
            curCalendar.apply {
                add(Calendar.DAY_OF_YEAR, 1)
            },
            tomorrowArrangements
        )
    }

    private fun loadOneDayExam(curCalendar: Calendar, arrangements: MutableList<TimeLineItem>) {
        val curYear: Int = curCalendar.year
        val curMonth: Int = curCalendar.month
        val curDay: Int = curCalendar.day
        for (subject in examData.subject) {
            val targetCalendar = subject.startTime.toCalendar()
            if (targetCalendar.year == curYear
                && targetCalendar.month == curMonth
                && targetCalendar.day == curDay
            ) {
                arrangements.add(
                    TimeLineItem(
                        name = subject.subject,
                        teacher = subject.seat.toString(),
                        place = subject.place,
                        startTime = subject.startTime,
                        endTime = subject.endTime,
                        start = 0,
                        end = 0,
                        type = Source.EXAM
                    )
                )
            }
        }
    }

    private fun sortArrangements() {
        fun MutableList<TimeLineItem>.sortByStartTime() {
            this.sortBy {
                it.startTime.time
            }
        }
        todayArrangements.sortByStartTime()
        tomorrowArrangements.sortByStartTime()
    }

    private fun loadPhysicsExpData() {
        //TODO show physics experiment arrangements
    }

    override fun onCreate() {
        reloadData()
    }

    override fun onDataSetChanged() {
        reloadData()
    }

    override fun onDestroy() {
        todayArrangements.clear()
        tomorrowArrangements.clear()
    }

    override fun getCount(): Int =
        if (arrangements.isEmpty()) 1 else arrangements.size // in order to invoke getViewAt() and show no_course_tip layout

    override fun getViewAt(position: Int): RemoteViews {
        if (position == 0 && !errorMessage.isNullOrBlank()) {
            return RemoteViews(packageName, R.layout.widget_class_table_tip_layout).apply {
                setTextViewText(R.id.widget_class_table_tip_text, "遇到错误了:\n${errorMessage}")
            }
        }
        if (position == 0 && arrangements.isEmpty()) {
            return RemoteViews(packageName, R.layout.widget_class_table_tip_layout)
        }
        val arrangementItem = arrangements[position]
        return RemoteViews(packageName, R.layout.widget_classtable_item).apply {
            setTextViewText(R.id.widget_classtable_item_start, arrangementItem.startTimeStr)
            setTextViewText(R.id.widget_classtable_item_end, arrangementItem.endTimeStr)
            setTextViewText(
                R.id.widget_classtable_item_start_time,
                SimpleDateFormat("HH:mm", Locale.getDefault())
                    .format(arrangementItem.startTime)
            )
            setTextViewText(
                R.id.widget_classtable_item_end_time,
                SimpleDateFormat("HH:mm", Locale.getDefault())
                    .format(arrangementItem.endTime)
            )
            setTextViewText(R.id.widget_classtable_item_name, arrangementItem.name)
            setTextViewText(R.id.widget_classtable_item_place, arrangementItem.place)
            setTextViewText(R.id.widget_classtable_item_teacher, arrangementItem.teacher)
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = false
}

class StartDayFetchError(private val startDay: String) :
    Exception("Can not get start day from str:${startDay}")
