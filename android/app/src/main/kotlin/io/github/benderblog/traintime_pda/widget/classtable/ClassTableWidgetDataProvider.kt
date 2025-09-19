// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.widget.classtable

import android.content.Context
import android.util.Log
import io.github.benderblog.traintime_pda.R
import io.github.benderblog.traintime_pda.model.ClassTableConstants
import io.github.benderblog.traintime_pda.model.ClassTableData
import io.github.benderblog.traintime_pda.model.ExamData
import io.github.benderblog.traintime_pda.model.ExperimentData
import io.github.benderblog.traintime_pda.model.Source
import io.github.benderblog.traintime_pda.model.TimeLineItem
import io.github.benderblog.traintime_pda.model.UserDefinedClassData
import io.github.benderblog.traintime_pda.model.endTime
import io.github.benderblog.traintime_pda.model.startTime
import io.github.benderblog.traintime_pda.model.timeRange
import kotlinx.serialization.json.Json
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
    private var tomorrowWeekIndex: Int = 0

    private lateinit var classTableData: ClassTableData
    private lateinit var examData: ExamData
    private var experimentData: List<ExperimentData> = emptyList()

    private var errorMessage: String? = null

    private val tag = "[PDA ClassTableWidget][ClassTableWidgetDataProvider]"

    fun reloadData(currentTime: LocalDateTime, context: Context) {
        Log.i(tag, "reloadData() called.")
        todayArrangements.clear()
        tomorrowArrangements.clear()
        errorMessage = null
        todayIndex = -1
        curWeekIndex = -1
        tomorrowWeekIndex = -1

        try {
            loadBasicConfig(currentTime, context)

            if (curWeekIndex >= 0 && todayIndex >= 0) {
                Log.i(tag, "Loading data for today (Week: $curWeekIndex, Day: $todayIndex)")
                loadOneDayClass(curWeekIndex, todayIndex, todayArrangements)
                loadOneDayExam(LocalDateTime.now(), todayArrangements)
                loadOneDayExperiment(LocalDateTime.now(), todayArrangements)

                var tomorrowDayIndex = todayIndex + 1
                tomorrowWeekIndex = curWeekIndex
                if (tomorrowDayIndex > 7) {
                    tomorrowDayIndex = 1
                    tomorrowWeekIndex += 1
                }
                Log.i(tag, "Loading data for tomorrow (Week: $tomorrowWeekIndex, Day: $tomorrowDayIndex)")

                loadOneDayClass(tomorrowWeekIndex, tomorrowDayIndex, tomorrowArrangements)
                loadOneDayExam(LocalDateTime.now().plusDays(1), tomorrowArrangements)
                loadOneDayExperiment(LocalDateTime.now().plusDays(1), tomorrowArrangements)

                sortArrangements()
            }
        } catch (e: Exception) {
            Log.e(tag, "Error during reloadData", e)
            val specificError = e.message ?: context.getString(R.string.widget_classtable_unknown_error)
            errorMessage = context.getString(
                R.string.widget_classtable_on_error,
                "reloadData",
                specificError
            )
            todayArrangements.clear()
            tomorrowArrangements.clear()
        }

        Log.i(tag, "reloadData() finished. Error: $errorMessage")
    }

    fun getTomorrowItems(): List<TimeLineItem> = tomorrowArrangements
    fun getTodayItems(): List<TimeLineItem> = todayArrangements
    fun getCurrentWeekIndex(): Int = curWeekIndex
    fun getTomorrowWeekIndex(): Int = tomorrowWeekIndex
    fun getErrorMessage(): String? = errorMessage

    private fun loadBasicConfig(currentTime: LocalDateTime, context: Context) {
        val lenientJson = Json { ignoreUnknownKeys = true }
        try {
            Log.i(tag, "loadBasicConfig() triggered")

            val schoolClassTableData = ClassTableDataHolder.schoolClassJsonData.getOrElse {
                Log.e(tag, "Failed to load schoolClassJsonData", it)
                errorMessage = context.getString(
                    R.string.widget_classtable_on_error,
                    "loading SchoolJsonData",
                    it.localizedMessage ?: context.getString(R.string.widget_classtable_unknown_error)
                )
                return
            }?.takeIf {
                Log.i(tag, "schoolClassJsonData is not blank: ${it.isNotBlank()}")
                it.isNotBlank()
            }?.let {
                try {
                    lenientJson.decodeFromString<ClassTableData>(it)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse schoolClassJsonData", e)
                    errorMessage = context.getString(
                        R.string.widget_classtable_on_error,
                        "parsing SchoolJsonData",
                        e.message ?: context.getString(R.string.widget_classtable_unknown_error)
                    )
                    return
                }
            } ?: ClassTableData.EMPTY
            Log.i(
                tag,
                "schoolClassTableData loaded, " +
                        "semester code: ${schoolClassTableData.semesterCode}, " +
                        "begin time: ${schoolClassTableData.termStartDay}, " +
                        "semester length: ${schoolClassTableData.semesterLength}, " +
                        "class detail length: ${schoolClassTableData.classDetail.size}, " +
                        "time arrangement length: ${schoolClassTableData.timeArrangement.size}"
            )

            val userDefinedClassData = ClassTableDataHolder.userDefinedClassJsonData.getOrElse {
                Log.e(tag, "Failed to load userDefinedClassJsonData", it)
                errorMessage = context.getString(
                    R.string.widget_classtable_on_error,
                    "loading UserDefinedClassJsonData",
                    it.message ?: context.getString(R.string.widget_classtable_unknown_error)
                )
                return
            }?.takeIf {
                Log.i(tag, "userDefinedClassJsonData is not blank: ${it.isNotBlank()}")
                it.isNotBlank()
            }?.let {
                try {
                    lenientJson.decodeFromString<UserDefinedClassData>(it)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse userDefinedClassJsonData", e)
                    errorMessage = context.getString(
                        R.string.widget_classtable_on_error,
                        "parsing UserDefinedClassJsonData",
                        e.message ?: context.getString(R.string.widget_classtable_unknown_error)
                    )
                    return
                }
            } ?: UserDefinedClassData.EMPTY
            Log.i(
                tag,
                "userDefinedClassJsonData loaded, " +
                        "userDefinedDetail length: ${userDefinedClassData.userDefinedDetail.size}, " +
                        "time arrangement length: ${userDefinedClassData.timeArrangement.size}"
            )

            examData = ClassTableDataHolder.examJsonData.getOrElse {
                Log.e(tag, "Failed to load examJsonData", it)
                errorMessage = context.getString(
                    R.string.widget_classtable_on_error,
                    "loading ExamJsonData",
                    it.message ?: context.getString(R.string.widget_classtable_unknown_error)
                )
                return
            }?.takeIf {
                Log.i(tag, "examJsonData is not blank: ${it.isNotBlank()}")
                it.isNotBlank()
            }?.let {
                try {
                    lenientJson.decodeFromString<ExamData>(it)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse examJsonData", e)
                    errorMessage = context.getString(
                        R.string.widget_classtable_on_error,
                        "parsing ExamJsonData",
                        e.message ?: context.getString(R.string.widget_classtable_unknown_error)
                    )
                    return
                }
            } ?: ExamData.EMPTY
            Log.i(tag, "examJsonData loaded, subject length: ${examData.subject.size}")

            experimentData = ClassTableDataHolder.experimentJsonData.getOrElse {
                Log.e(tag, "Failed to load ExperimentData", it)
                errorMessage = context.getString(
                    R.string.widget_classtable_on_error,
                    "loading ExperimentData",
                    it.message ?: context.getString(R.string.widget_classtable_unknown_error)
                )
                return
            }?.takeIf {
                Log.i(tag, "experimentJsonData is not blank: ${it.isNotBlank()}")
                it.isNotBlank()
            }?.let {
                try {
                    lenientJson.decodeFromString<List<ExperimentData>>(it)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse ExperimentData", e)
                    errorMessage = context.getString(
                        R.string.widget_classtable_on_error,
                        "parsing ExperimentData",
                        e.message ?: context.getString(R.string.widget_classtable_unknown_error)
                    )
                    return
                }
            } ?: emptyList()
            Log.i(tag, "experimentJsonData loaded, data length: ${experimentData.size}")

            // merge class table with user added class
            classTableData = schoolClassTableData.copy(
                userDefinedDetail = userDefinedClassData.userDefinedDetail,
                timeArrangement = schoolClassTableData.timeArrangement + userDefinedClassData.timeArrangement,
            )
            Log.i(tag, "Class table merged.")

            // calculate day index of today
            val termStartDayStr = classTableData.termStartDay
            if (termStartDayStr.isBlank()) {
                if (classTableData == ClassTableData.EMPTY && userDefinedClassData == UserDefinedClassData.EMPTY) {
                    Log.w(tag, "Term start day is blank and no class data loaded.")
                } else {
                    Log.e(tag, "Term start day is blank, cannot calculate week/day index!")
                    errorMessage = context.getString(R.string.widget_classtable_parse_term_start_time_error)
                }
                return
            }
            Log.i(tag, "Term start day: $termStartDayStr")

            try {
                val weekOffset = ClassTableDataHolder.weekSwift
                val dateFormat = DateTimeFormatter.ofPattern(ClassTableConstants.DATE_FORMAT_STR, Locale.getDefault())
                val startDay = LocalDateTime.parse(termStartDayStr, dateFormat).plusWeeks(weekOffset)
                Log.i(tag, "Effective start day (after weekSwift $weekOffset): $startDay")

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
                Log.i(tag, "Calculation finished. curWeekIndex: $curWeekIndex, todayIndex: $todayIndex")
            } catch (e: Exception) {
                Log.e(tag, "Error calculating date indices", e)
                errorMessage = context.getString(
                    R.string.widget_classtable_calculate_index_error,
                    e.message ?: context.getString(R.string.widget_classtable_unknown_error)
                )
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
            errorMessage = context.getString(
                R.string.widget_classtable_parse_term_start_time_error,
            )
        } catch (e: Exception) {
            Log.e(tag, "Error calculating date indices (outer catch)", e)
            errorMessage = context.getString(
                R.string.widget_classtable_calculate_index_error,
                e.message ?: context.getString(R.string.widget_classtable_unknown_error)
            )
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
    ) : Result<Unit> {
        val curYear: Int = date.year
        val curMonth: Int = date.monthValue
        val curDay: Int = date.dayOfMonth
        for (subject in examData.subject) {
            val startTime = subject.startTime.getOrElse {
                return Result.failure(it)
            }
            val endTime = subject.endTime.getOrElse {
                return Result.failure(it)
            }
            if (startTime.year == curYear
                && startTime.monthValue == curMonth
                && startTime.dayOfMonth == curDay
            ) {
                arrangements.add(
                    TimeLineItem(
                        type = Source.EXAM,
                        name = subject.subject,
                        teacher = subject.seat ?: "未知",
                        place = subject.place,
                        startTime = startTime,
                        endTime = endTime,
                        colorIndex = examData.subject.indexOf(subject)
                    )
                )
            }
        }
        return Result.success(Unit)
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
        todayArrangements.sortBy { it.startTime }
        tomorrowArrangements.sortBy { it.startTime }
    }
}