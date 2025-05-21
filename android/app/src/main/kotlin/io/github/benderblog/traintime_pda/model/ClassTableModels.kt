// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Original author: Xiue233

package io.github.benderblog.traintime_pda.model

import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import java.time.LocalDateTime

object ClassTableConstants {
    const val CLASS_FILE_NAME = "ClassTable.json"
    const val USER_CLASS_FILE_NAME = "UserClass.json"
    const val EXAM_FILE_NAME = "exam.json"
    const val EXPERIMENT_FILE_NAME = "Experiment.json"
    // TODO: Add experiment file

    // In SharedPreferencesPlugin, SHARED_PREFERENCES_NAME is private.
    // Be attention to the changes of SharedPreferencesPlugin.SHARED_PREFERENCES_NAME.
    const val CONFIG_SHARED_PREFS_NAME = "FlutterSharedPreferences"
    const val CONFIG_WEEK_SWIFT_KEY = "flutter.swift"

    const val DATE_FORMAT_STR = "yyyy-MM-dd HH:mm:ss"

    val CLASS_TIME_POINTS_PAIR = listOf(
        listOf(8, 30),
        listOf(9, 15),
        listOf(9, 20),
        listOf(10, 5),
        listOf(10, 25),
        listOf(11, 10),
        listOf(11, 15),
        listOf(12, 0),
        listOf(14, 0),
        listOf(14, 45),
        listOf(14, 50),
        listOf(15, 35),
        listOf(15, 55),
        listOf(16, 40),
        listOf(16, 45),
        listOf(17, 30),
        listOf(19, 0),
        listOf(19, 45),
        listOf(19, 55),
        listOf(20, 35),
        listOf(20, 40),
        listOf(21, 25),
    )
}

object ClassTableWidgetKeys {
    const val SHOW_TODAY = "show_today"
    const val SP_FILE_NAME = "class_table_widget"
}

data class TimeLineItem(
    val type: Source = Source.SCHOOL,
    val name: String,
    val teacher: String,
    val place: String,
    val startTime: LocalDateTime,
    val endTime: LocalDateTime,
    val colorIndex: Int,
) {
    val startTimeStr: String = when (type) {
        Source.EXAM -> "考"
        Source.EXPERIMENT -> "实"
        else -> "课"
    }

    val endTimeStr: String = when (type) {
        Source.EXAM -> "试"
        Source.EXPERIMENT -> "验"
        else -> "程"
    }
}

data class UserDefinedClassData(
    @SerializedName("userDefinedDetail")
    val userDefinedDetail: List<ClassDetail>,
    @SerializedName("timeArrangement")
    val timeArrangement: List<TimeArrangement>,
) {
    companion object {
        val EMPTY = UserDefinedClassData(
            emptyList(), emptyList()
        )
    }
}

data class ClassTableData(
    @SerializedName("semesterLength")
    val semesterLength: Int,
    @SerializedName("semesterCode")
    val semesterCode: String,
    @SerializedName("termStartDay")
    val termStartDay: String,
    @SerializedName("classDetail")
    val classDetail: List<ClassDetail>,
    @SerializedName("userDefinedDetail")
    val userDefinedDetail: List<ClassDetail>,
    @SerializedName("notArranged")
    val notArranged: List<NotArrangedClassDetail>,
    @SerializedName("timeArrangement")
    val timeArrangement: List<TimeArrangement>,
) {
    companion object {
        val EMPTY = ClassTableData(
            0, "", "2024-1-1",
            emptyList(), emptyList(), emptyList(), emptyList(),
        )
    }

    fun getClassName(arrangement: TimeArrangement): String =
        when (arrangement.source) {
            Source.SCHOOL -> classDetail[arrangement.index].name
            Source.USER -> userDefinedDetail[arrangement.index].name
            Source.EXAM -> "Unknown Exam"
            Source.EXPERIMENT -> "Unknown Experiment"
            Source.EMPTY -> "Unknown Empty"
        }
}

data class ClassDetail(
    @SerializedName("name")
    val name: String,
    @SerializedName("code")
    val code: String?,
    @SerializedName("number")
    val number: String?
)

//just a stub (It is useless for class table.)
class NotArrangedClassDetail

enum class Source(val rawValue: String) {
    @SerializedName("empty")
    EMPTY("empty"),

    @SerializedName("school")
    SCHOOL("school"),

    @SerializedName("experiment")
    EXPERIMENT("experiment"),

    @SerializedName("exam")
    EXAM("exam"),

    @SerializedName("user")
    USER("user"),
}

data class TimeArrangement(
    @SerializedName("index")
    val index: Int,
    @SerializedName("week_list")
    val weekList: List<Boolean>,
    @SerializedName("teacher")
    val teacher: String?,
    @SerializedName("day")
    val day: Int,
    @SerializedName("start")
    val start: Int,
    @SerializedName("stop")
    val stop: Int,
    @SerializedName("source")
    val source: Source,
    @SerializedName("classroom")
    val classroom: String?,
) {
    val step: Int = stop - start
}

data class ExamData(
    @SerializedName("subject")
    val subject: List<Subject>
) {
    companion object {
        val EMPTY = ExamData(emptyList())
    }
}

data class Subject(
    @SerializedName("subject")
    val subject: String,
    @SerializedName("typeStr")
    val typeStr: String,
    @SerializedName("startTimeStr")
    val startTimeStr: String,
    @SerializedName("endTimeStr")
    val endTimeStr: String,
    @SerializedName("place")
    val place: String,
    @SerializedName("seat")
    val seat: String,
)

val Subject.startTime: LocalDateTime?
    get() = try {
        LocalDateTime.parse(startTimeStr)
    } catch (e: Exception) {
        null
    }

val Subject.endTime: LocalDateTime?
    get() = try {
        LocalDateTime.parse(endTimeStr)
    } catch (e: Exception) {
        null
    }

data class ExperimentData(
    @SerializedName("name")
    val name: String,
    @SerializedName("classroom")
    val classroom: String,
    @SerializedName("date")
    val date: String,
    @SerializedName("timeStr")
    val timeStr: String,
    @SerializedName("teacher")
    val teacher: String,
)

class ExperimentDataListToken : TypeToken<List<ExperimentData>>()

val ExperimentData.timeRange: Pair<LocalDateTime, LocalDateTime>
    get() {
        /// Return is month/day/year , hope not change...
        val dateNums: List<Int> = date.split('/').map { it ->
            it.toInt()
        }

        /// And the time arrangement too.
        lateinit var startTime: LocalDateTime
        lateinit var stopTime: LocalDateTime

        if (timeStr.contains("15")) {
            startTime = LocalDateTime.of(
                dateNums[2],
                dateNums[0],
                dateNums[1],
                15,55,0,
            )
            stopTime = LocalDateTime.of(
                dateNums[2],
                dateNums[0],
                dateNums[1],
                18,10,0,
            )
        } else {
            startTime = LocalDateTime.of(
                dateNums[2],
                dateNums[0],
                dateNums[1],
                18,30,0,
            )
            stopTime = LocalDateTime.of(
                dateNums[2],
                dateNums[0],
                dateNums[1],
                20,45,0,
            )
        }

        return Pair(startTime, stopTime)
    }

