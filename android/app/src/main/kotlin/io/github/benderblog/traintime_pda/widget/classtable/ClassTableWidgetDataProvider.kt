// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.widget.classtable

import android.content.Context
import android.util.Log
import io.github.benderblog.traintime_pda.R
import io.github.benderblog.traintime_pda.model.ClassTableConstants
import io.github.benderblog.traintime_pda.model.ClassTableData
import io.github.benderblog.traintime_pda.model.ClassTableWidgetLoadState
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
    private val timeLineItem = mutableListOf<TimeLineItem>()
    private var currentTime: LocalDateTime = LocalDateTime.now()
    private var dayIndex: Int = 0
    private var weekIndex: Int = 0

    private lateinit var classTableData: ClassTableData
    private lateinit var examData: ExamData
    private var experimentData: List<ExperimentData> = emptyList()

    private var widgetState = ClassTableWidgetLoadState.LOADING
    private var errorMessage: String? = null

    private val tag = "[PDA ClassTableWidget][ClassTableWidgetDataProvider]"

    fun reloadData(isShowingToday: Boolean, context: Context) {
        Log.i(tag, "reloadData() called.")
        timeLineItem.clear()

        widgetState = ClassTableWidgetLoadState.LOADING
        errorMessage = null

        currentTime = LocalDateTime.now()
        dayIndex = -1
        weekIndex = -1
        Log.i(tag, "currentTime is $currentTime")

        // Loading data
        loadBasicConfig(context)
        if (widgetState != ClassTableWidgetLoadState.LOADING) {
            return
        }

        // Whether get tomorrow's timeline items
        if (!isShowingToday) {
            dayIndex += 1
            if (dayIndex > 7) {
                dayIndex = 1
                weekIndex += 1
            }
        }
        Log.i(
            tag,
            "Loading data for ${if (isShowingToday) "today" else "tomorrow"} (Week: $weekIndex, Day: $dayIndex)"
        )

        try {
            if (weekIndex >= 0 && dayIndex >= 0) {
                loadOneDayClass()
                loadOneDayExam()
                loadOneDayExperiment()
                timeLineItem.sortBy { it.startTime }
            }
        } catch (e: Exception) {
            Log.e(tag, "Error during reloadData", e)
            widgetState = ClassTableWidgetLoadState.ERROR_OTHER
            errorMessage = context.getString(
                R.string.widget_classtable_on_error,
                "reloadData",
                "${e.message ?: context.getString(R.string.widget_classtable_unknown_error)} at ${e.stackTrace.first()}"
            )
            timeLineItem.clear()
            return
        }

        widgetState = ClassTableWidgetLoadState.FINISHED
        Log.i(tag, "reloadData() finished. Error: $errorMessage")
    }

    fun getCurrentTime(): LocalDateTime = currentTime
    fun getTimeLineItems(): List<TimeLineItem> = timeLineItem
    fun getWeekIndex(): Int = weekIndex
    fun getLoadingState(): ClassTableWidgetLoadState = widgetState
    fun getErrorMessage(): String? = errorMessage

    private fun loadBasicConfig(context: Context) {
        val lenientJson = Json { ignoreUnknownKeys = true }
        try {
            Log.i(tag, "loadBasicConfig() triggered")

            val schoolClassTableData = ClassTableDataHolder.schoolClassJsonData.getOrElse {
                Log.e(tag, "Failed to load schoolClassJsonData", it)
                widgetState = ClassTableWidgetLoadState.ERROR_COURSE
                errorMessage = it.localizedMessage ?: it.message
                        ?: context.getString(R.string.widget_classtable_unknown_error)
                return
            }.let {
                try {
                    lenientJson.decodeFromString<ClassTableData>(it)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse schoolClassJsonData", e)
                    widgetState = ClassTableWidgetLoadState.ERROR_COURSE
                    errorMessage = e.localizedMessage ?: e.localizedMessage
                            ?: context.getString(R.string.widget_classtable_unknown_error)
                    return
                }
            }
            Log.i(
                tag,
                "schoolClassTableData loaded, " + "semester code: ${schoolClassTableData.semesterCode}, " + "begin time: ${schoolClassTableData.termStartDay}, " + "semester length: ${schoolClassTableData.semesterLength}, " + "class detail length: ${schoolClassTableData.classDetail.size}, " + "time arrangement length: ${schoolClassTableData.timeArrangement.size}"
            )

            val userDefinedClassData = ClassTableDataHolder.userDefinedClassJsonData.getOrElse {
                Log.e(tag, "Failed to load userDefinedClassJsonData", it)
                widgetState = ClassTableWidgetLoadState.ERROR_COURSE_USER_DEFINED
                errorMessage = it.localizedMessage ?: it.message
                        ?: context.getString(R.string.widget_classtable_unknown_error)
                return
            }?.takeIf {
                Log.i(tag, "userDefinedClassJsonData is not blank: ${it.isNotBlank()}")
                it.isNotBlank()
            }?.let {
                try {
                    lenientJson.decodeFromString<UserDefinedClassData>(it)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse userDefinedClassJsonData", e)
                    widgetState = ClassTableWidgetLoadState.ERROR_COURSE_USER_DEFINED
                    errorMessage = e.localizedMessage ?: e.message
                            ?: context.getString(R.string.widget_classtable_unknown_error)
                    return
                }
            } ?: UserDefinedClassData.EMPTY
            Log.i(
                tag,
                "userDefinedClassJsonData loaded, " + "userDefinedDetail length: ${userDefinedClassData.userDefinedDetail.size}, " + "time arrangement length: ${userDefinedClassData.timeArrangement.size}"
            )

            examData = ClassTableDataHolder.examJsonData.getOrElse {
                Log.e(tag, "Failed to load examJsonData", it)
                widgetState = ClassTableWidgetLoadState.ERROR_EXAM
                errorMessage = it.localizedMessage ?: it.message
                        ?: context.getString(R.string.widget_classtable_unknown_error)
                return
            }.let {
                try {
                    lenientJson.decodeFromString<ExamData>(it)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse examJsonData", e)
                    widgetState = ClassTableWidgetLoadState.ERROR_EXAM
                    errorMessage = e.localizedMessage ?: e.message
                            ?: context.getString(R.string.widget_classtable_unknown_error)
                    return
                }
            }
            Log.i(tag, "examJsonData loaded, subject length: ${examData.subject.size}")

            experimentData = ClassTableDataHolder.experimentJsonData.getOrElse {
                Log.e(tag, "Failed to load ExperimentData", it)
                widgetState = ClassTableWidgetLoadState.ERROR_EXPERIMENT
                errorMessage = it.localizedMessage ?: it.message
                        ?: context.getString(R.string.widget_classtable_unknown_error)
                return
            }?.takeIf {
                Log.i(tag, "experimentJsonData is not blank: ${it.isNotBlank()}")
                it.isNotBlank()
            }?.let {
                try {
                    lenientJson.decodeFromString<List<ExperimentData>>(it)
                } catch (e: Exception) {
                    Log.e(tag, "Failed to parse ExperimentData", e)
                    widgetState = ClassTableWidgetLoadState.ERROR_EXPERIMENT
                    errorMessage = e.localizedMessage ?: e.message
                            ?: context.getString(R.string.widget_classtable_unknown_error)
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
                    errorMessage =
                        context.getString(R.string.widget_classtable_parse_term_start_time_error)
                }
                return
            }
            Log.i(tag, "Term start day: $termStartDayStr")

            try {
                val weekOffset = ClassTableDataHolder.weekSwift
                val dateFormat = DateTimeFormatter.ofPattern(
                    ClassTableConstants.DATE_FORMAT_STR, Locale.getDefault()
                )
                val startDay =
                    LocalDateTime.parse(termStartDayStr, dateFormat).plusWeeks(weekOffset)
                Log.i(tag, "Effective start day (after weekSwift $weekOffset): $startDay")

                var deltaDays = ChronoUnit.DAYS.between(startDay, currentTime)
                if (deltaDays < 0) {
                    Log.w(
                        tag,
                        "Current date is before the effective start date. Delta days: $deltaDays. Applying original logic (delta=-7)."
                    )
                    deltaDays = -7
                }

                weekIndex = (deltaDays / 7).toInt()
                dayIndex = currentTime.dayOfWeek.value
                Log.i(tag, "Calculation finished. curWeekIndex: $weekIndex, todayIndex: $dayIndex")
            } catch (e: Exception) {
                Log.e(tag, "Error calculating date indices", e)
                widgetState = ClassTableWidgetLoadState.ERROR_OTHER
                errorMessage =
                    e.message ?: context.getString(R.string.widget_classtable_unknown_error)
                weekIndex = -1
                dayIndex = -1
            }
        } catch (e: DateTimeParseException) {
            Log.e(
                tag,
                "Error parsing term start date string: '${classTableData.termStartDay}' " + "with format '${ClassTableConstants.DATE_FORMAT_STR}'",
                e
            )
            widgetState = ClassTableWidgetLoadState.ERROR_OTHER
            errorMessage = context.getString(
                R.string.widget_classtable_parse_term_start_time_error,
            )
        } catch (e: Exception) {
            Log.e(tag, "Error calculating date indices (outer catch)", e)
            widgetState = ClassTableWidgetLoadState.ERROR_OTHER
            errorMessage =
                "${e.message ?: context.getString(R.string.widget_classtable_unknown_error)} at ${e.stackTrace.first()}"
        }
    }

    private fun loadOneDayClass() {
        if (weekIndex >= 0 && weekIndex < classTableData.semesterLength) {
            for (arrangement in classTableData.timeArrangement) {
                if (arrangement.weekList.size > weekIndex && arrangement.weekList[weekIndex] && arrangement.day == dayIndex) {
                    val now = LocalDateTime.now()
                    val startTimePoints =
                        ClassTableConstants.CLASS_TIME_POINTS_PAIR[(arrangement.start - 1) * 2]
                    val endTimePoints =
                        ClassTableConstants.CLASS_TIME_POINTS_PAIR[(arrangement.stop - 1) * 2 + 1]

                    timeLineItem.add(
                        TimeLineItem(
                            type = Source.SCHOOL,
                            name = classTableData.getClassName(arrangement),
                            teacher = arrangement.teacher ?: "未知教师",
                            place = arrangement.classroom ?: "未安排教室",
                            startTime = now.withHour(startTimePoints[0])
                                .withMinute(startTimePoints[1]).withSecond(0).withNano(0),
                            endTime = now.withHour(endTimePoints[0]).withMinute(endTimePoints[1])
                                .withSecond(0).withNano(0),
                            colorIndex = arrangement.index
                        )
                    )
                }
            }
        }
    }

    private fun loadOneDayExam() {
        val curYear: Int = currentTime.year
        val curMonth: Int = currentTime.monthValue
        val curDay: Int = currentTime.dayOfMonth
        for (subject in examData.subject) {
            val startTime = subject.startTime.getOrElse {
                Log.e(
                    tag,
                    "Failed to get startTime from subject $subject on loadOneDayExam, this subject will be omitted",
                    it
                )
                continue
            }
            val endTime = subject.endTime.getOrElse {
                Log.e(
                    tag,
                    "Failed to get endTime from subject $subject on loadOneDayExam, this subject will be omitted",
                    it
                )
                continue
            }
            if (startTime.year == curYear && startTime.monthValue == curMonth && startTime.dayOfMonth == curDay) {
                timeLineItem.add(
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
    }

    private fun loadOneDayExperiment() {
        val curYear: Int = currentTime.year
        val curMonth: Int = currentTime.monthValue
        val curDay: Int = currentTime.dayOfMonth
        for (data in experimentData) {
            val targetCalendar = data.timeRange.first
            if (targetCalendar.year == curYear && targetCalendar.monthValue == curMonth && targetCalendar.dayOfMonth == curDay) {
                timeLineItem.add(
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
}