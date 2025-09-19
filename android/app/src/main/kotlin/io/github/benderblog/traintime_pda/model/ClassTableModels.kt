// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Original author: Xiue233

package io.github.benderblog.traintime_pda.model

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonIgnoreUnknownKeys
import java.time.LocalDateTime

object ClassTableConstants {
    const val CLASS_FILE_NAME = "ClassTable.json"
    const val USER_CLASS_FILE_NAME = "UserClass.json"
    const val EXAM_FILE_NAME = "exam.json"
    const val EXPERIMENT_FILE_NAME = "Experiment.json"

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
    //const val SP_FILE_NAME = "class_table_widget"
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

@Serializable
data class UserDefinedClassData(
    val userDefinedDetail: List<ClassDetail>,
    val timeArrangement: List<TimeArrangement>,
) {
    companion object {
        val EMPTY = UserDefinedClassData(
            emptyList(), emptyList()
        )
    }
}

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class ClassTableData(
    val semesterLength: Int,
    val semesterCode: String,
    val termStartDay: String,
    val classDetail: List<ClassDetail>,
    val userDefinedDetail: List<ClassDetail>,
    val timeArrangement: List<TimeArrangement>,
    // ClassChanges has been omitted here since calculated in time main app.
    // NotArrangedClassDetail has been omitted here since useless.
) {
    companion object {
        val EMPTY = ClassTableData(
            0, "", "2024-1-1",
            emptyList(), emptyList(), emptyList(),
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

@Serializable
data class ClassDetail(
    val name: String,
    val code: String?,
    val number: String?
)

@Serializable
enum class Source {
    @SerialName("empty")
    EMPTY,

    @SerialName("school")
    SCHOOL,

    @SerialName("experiment")
    EXPERIMENT,

    @SerialName("exam")
    EXAM,

    @SerialName("user")
    USER,
}

@Serializable
data class TimeArrangement(
    val index: Int,
    @SerialName("week_list")
    val weekList: List<Boolean>,
    val teacher: String?,
    val day: Int,
    val start: Int,
    val stop: Int,
    val source: Source,
    val classroom: String? = null,
)

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class ExamData(
    val subject: List<Subject>
    // ToBeArranged has been omitted here since useless here.
) {
    companion object {
        val EMPTY = ExamData(emptyList())
    }
}

@OptIn(ExperimentalSerializationApi::class)
@Serializable
@JsonIgnoreUnknownKeys
data class Subject(
    val subject: String,
    val typeStr: String,
    // time has been omitted here since calculated by main app.
    val startTimeStr: String,
    val endTimeStr: String,
    val place: String,
    val seat: String?,
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

@Serializable
data class ExperimentData(
    val name: String,
    val classroom: String,
    val date: String,
    val timeStr: String,
    val teacher: String,
)

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

