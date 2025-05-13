package io.github.benderblog.traintime_pda.widget.classtable

import android.util.Log
import io.github.benderblog.traintime_pda.model.ClassTableConstants
import io.github.benderblog.traintime_pda.model.ClassTableData
import io.github.benderblog.traintime_pda.model.ExamData
import io.github.benderblog.traintime_pda.model.ExperimentData
import io.github.benderblog.traintime_pda.model.ExperimentDataListToken
import io.github.benderblog.traintime_pda.model.Source
import io.github.benderblog.traintime_pda.model.TimeLineItem
import io.github.benderblog.traintime_pda.model.UserDefinedClassData
import io.github.benderblog.traintime_pda.model.endTime
import io.github.benderblog.traintime_pda.model.startTime
import io.github.benderblog.traintime_pda.model.timeRange
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException
import java.time.temporal.ChronoUnit
import java.util.Locale

class ClassTableWidgetDataProvider {
    private val todayArrangements = mutableListOf<TimeLineItem>()
    private val tomorrowArrangements = mutableListOf<TimeLineItem>()

    private var todayIndex: Int = 0
    private var curWeekIndex: Int = 0

    private lateinit var classTableData: ClassTableData
    private lateinit var examData: ExamData
    private var experimentData: List<ExperimentData> = emptyList()

    private var errorMessage: String? = null

    private val tag = "[PDA ClassTableWidget][ClassTableWidgetDataProvider]"

    fun reloadData(currentTime: LocalDateTime) {
        Log.d(tag, "reloadData() called.")
        todayArrangements.clear()
        tomorrowArrangements.clear()
        errorMessage = null
        todayIndex = -1
        curWeekIndex = -1

        try {
            loadBasicConfig(currentTime)

            if (curWeekIndex >= 0 && todayIndex >= 0) {
                Log.d(tag, "Loading data for today (Week: $curWeekIndex, Day: $todayIndex)")
                loadOneDayClass(curWeekIndex, todayIndex, todayArrangements)
                loadOneDayExam(LocalDateTime.now(), todayArrangements)
                loadOneDayExperiment(LocalDateTime.now(), todayArrangements)

                var tomorrowDayIndex = todayIndex + 1
                var weekForTomorrowIndex = curWeekIndex
                if (tomorrowDayIndex > 7) {
                    tomorrowDayIndex = 1
                    weekForTomorrowIndex += 1
                }
                Log.d(tag, "Loading data for tomorrow (Week: $weekForTomorrowIndex, Day: $tomorrowDayIndex)")

                loadOneDayClass(weekForTomorrowIndex, tomorrowDayIndex, tomorrowArrangements)
                loadOneDayExam(LocalDateTime.now().plusDays(1), tomorrowArrangements)
                loadOneDayExperiment(LocalDateTime.now().plusDays(1), tomorrowArrangements)

                sortArrangements()
            } else {
                Log.w(tag, "Week index or day index is invalid. Skipping data loading.")
                if (errorMessage == null) {
                    errorMessage = "无法计算当前周/天，请检查学期配置。"
                }
            }
        } catch (e: Exception) {
            Log.e("ClassDataProvider", "Error during reloadData", e)
            errorMessage = "加载数据时出错: ${e.message ?: "未知错误"}"
            todayArrangements.clear()
            tomorrowArrangements.clear()
        }

        Log.d("ClassDataProvider", "reloadData() finished. Error: $errorMessage")
    }

    fun getTomorrowItems(): List<TimeLineItem> = tomorrowArrangements
    fun getTodayItems(): List<TimeLineItem> = todayArrangements
    fun getCurrentWeekIndex(): Int = curWeekIndex
    fun getErrorMessage(): String? = errorMessage

    private fun loadBasicConfig(currentTime: LocalDateTime) {
        try {
            Log.d(tag, "loadBasicConfig() triggered")
            // initialize data
            val schoolClassTableData = ClassTableDataHolder.schoolClassJsonData?.takeIf {
                it.isNotBlank()
            }?.let {
                try {
                    ClassTableDataHolder.gson.fromJson(it, ClassTableData::class.java)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse schoolClassJsonData", e);
                    null
                }
            } ?: ClassTableData.EMPTY
            Log.d(tag, "schoolClassJsonData loaded.")

            val userDefinedClassData = ClassTableDataHolder.userDefinedClassJsonData?.takeIf {
                it.isNotBlank()
            }?.let {
                try {
                    ClassTableDataHolder.gson.fromJson(it, UserDefinedClassData::class.java)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse userDefinedClassJsonData", e);
                    null
                }
            } ?: UserDefinedClassData.EMPTY
            Log.d(tag, "userDefinedClassJsonData loaded.")

            examData = ClassTableDataHolder.examJsonData?.takeIf {
                it.isNotBlank()
            }?.let {
                try {
                    ClassTableDataHolder.gson.fromJson(it, ExamData::class.java)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse examJsonData", e);
                    null
                }
            } ?: ExamData.EMPTY
            Log.d(tag, "examJsonData loaded.")

            experimentData = ClassTableDataHolder.experimentJsonData?.takeIf {
                it.isNotBlank()
            }?.let {
                try {
                    ClassTableDataHolder.gson.fromJson<List<ExperimentData>>(
                        it,
                        ExperimentDataListToken().type
                    )
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse experimentJsonData", e);
                    null
                }
            } ?: emptyList()
            Log.d(tag, "experimentJsonData loaded.")

            // merge class table with user added class
            classTableData = schoolClassTableData.copy(
                userDefinedDetail = userDefinedClassData.userDefinedDetail,
                timeArrangement = schoolClassTableData.timeArrangement + userDefinedClassData.timeArrangement,
            )
            Log.d(tag, "Class table merged.")

            // calculate day index of today
            val termStartDayStr = classTableData.termStartDay
            if (termStartDayStr.isBlank()) {
                if (classTableData == ClassTableData.EMPTY && userDefinedClassData == UserDefinedClassData.EMPTY) {
                    Log.w(tag, "Term start day is blank and no class data loaded.")
                } else {
                    Log.e(tag, "Term start day is blank, cannot calculate week/day index!")
                    errorMessage = "未设置学期开始日期"
                }
                return
            }
            Log.d(tag, "Term start day: $termStartDayStr")

            try {
                val weekOffset = ClassTableDataHolder.weekSwift
                val dateFormat = DateTimeFormatter.ofPattern(ClassTableConstants.DATE_FORMAT_STR, Locale.getDefault())
                val startDay = LocalDateTime.parse(termStartDayStr, dateFormat).plusWeeks(weekOffset)
                Log.d(tag, "Effective start day (after weekSwift $weekOffset): $startDay")

                var deltaDays = ChronoUnit.DAYS.between(startDay, currentTime)
                if (deltaDays < 0) {
                    Log.w(
                        tag,
                        "Current date is before the effective start date. "+
                            "Delta days: $deltaDays. " +
                            "Applying original logic (delta=-7)."
                    )
                    deltaDays = -7
                }

                curWeekIndex = (deltaDays / 7).toInt()
                todayIndex = currentTime.dayOfWeek.value
                Log.d(tag, "Calculation finished. curWeekIndex: $curWeekIndex, todayIndex: $todayIndex")
            } catch (e: Exception) {
                Log.e(tag, "Error calculating date indices", e)
                errorMessage = "计算周/日索引时出错: ${e.message}"
                curWeekIndex = -1
                todayIndex = -1
            }
        } catch (e: DateTimeParseException) {
            Log.e(
                tag,
                "Error parsing term start date string: '${classTableData.termStartDay}' " +
                "with format '${ClassTableConstants.DATE_FORMAT_STR}'",
                e
            )
            errorMessage = "无法解析学期开始日期格式"
        } catch (e: Exception) {
            Log.e(tag, "Error calculating date indices using java.time", e)
            errorMessage = "计算周/日索引时出错: ${e.message}"
        }
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
                    val now = LocalDateTime.now()
                    val startTimePoints =
                        ClassTableConstants.CLASS_TIME_POINTS_PAIR[(arrangement.start - 1) * 2]
                    val endTimePoints =
                        ClassTableConstants.CLASS_TIME_POINTS_PAIR[(arrangement.stop - 1) * 2 + 1]

                    arrangements.add(
                        TimeLineItem(
                            type = Source.SCHOOL,
                            name = classTableData.getClassName(arrangement),
                            teacher = arrangement.teacher ?: "未知教师",
                            place = arrangement.classroom ?: "未安排教室",
                            startTime = now
                                .withHour(startTimePoints[0])
                                .withMinute(startTimePoints[1])
                                .withSecond(0)
                                .withNano(0),
                            endTime = now
                                .withHour(endTimePoints[0])
                                .withMinute(endTimePoints[1])
                                .withSecond(0)
                                .withNano(0),
                            colorIndex = arrangement.index
                        )
                    )
                }
            }
        }
    }

    private fun loadOneDayExam(
        date: LocalDateTime,
        arrangements: MutableList<TimeLineItem>
    ) {
        val curYear: Int = date.year
        val curMonth: Int = date.monthValue
        val curDay: Int = date.dayOfMonth
        for (subject in examData.subject) {
            val startTime = subject.startTime
            val endTime = subject.endTime
            if (startTime == null || endTime == null) {
                continue
            }
            if (startTime.year == curYear
                && startTime.monthValue == curMonth
                && startTime.dayOfMonth == curDay
            ) {
                arrangements.add(
                    TimeLineItem(
                        type = Source.EXAM,
                        name = subject.subject,
                        teacher = subject.seat,
                        place = subject.place,
                        startTime = startTime,
                        endTime = endTime,
                        colorIndex = examData.subject.indexOf(subject)
                    )
                )
            }
        }
    }

    private fun loadOneDayExperiment(
        date: LocalDateTime,
        arrangements: MutableList<TimeLineItem>
    ) {
        val curYear: Int = date.year
        val curMonth: Int = date.monthValue
        val curDay: Int = date.dayOfMonth
        for (data in experimentData) {
            val targetCalendar = data.timeRange.first
            if (targetCalendar.year == curYear
                && targetCalendar.monthValue == curMonth
                && targetCalendar.dayOfMonth == curDay
            ) {
                arrangements.add(
                    TimeLineItem(
                        type = Source.EXPERIMENT,
                        name = data.name,
                        teacher = data.teacher,
                        place = data.classroom,
                        startTime = data.timeRange.first,
                        endTime = data.timeRange.second,
                        colorIndex = experimentData.indexOf(data)
                    )
                )
            }
        }
    }

    private fun sortArrangements() {
        fun MutableList<TimeLineItem>.sortByStartTime() {
            this.sortBy {
                it.startTime
            }
        }
        todayArrangements.sortByStartTime()
        tomorrowArrangements.sortByStartTime()
    }
}