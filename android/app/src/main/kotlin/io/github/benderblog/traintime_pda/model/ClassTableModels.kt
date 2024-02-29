package io.github.benderblog.traintime_pda.model

import com.google.gson.annotations.SerializedName
import com.google.gson.reflect.TypeToken
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale

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
    )
}

object ClassTableWidgetKeys {
    const val PACKAGE_NAME = "io.github.benderblog.traintime_pda"
}

data class TimeLineItem(
    val name: String,
    val teacher: String,
    val place: String,
    val startTime: Date,
    val endTime: Date,
    val start: Int,
    val end: Int,
    val type: Source = Source.SCHOOL
) {
    val startTimeStr: String = when (type) {
        Source.EXAM -> "考"
        Source.EXPERIMENT -> "实"
        else -> start.toString()
    }

    val endTimeStr: String = when (type) {
        Source.EXAM -> "试"
        Source.EXPERIMENT -> "验"
        else -> end.toString()
    }
}

data class UserDefinedClassData (
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
            else -> "Unknown None"
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
    val seat: Int,
)

val Subject.startTime: Date
    get() = SimpleDateFormat(ClassTableConstants.DATE_FORMAT_STR, Locale.getDefault())
        .parse(startTimeStr) ?: throw Exception("Can't parse $startTimeStr to Date")

val Subject.endTime: Date
    get() = SimpleDateFormat(ClassTableConstants.DATE_FORMAT_STR, Locale.getDefault())
        .parse(endTimeStr) ?: throw Exception("Can't parse $endTimeStr to Date")

val Subject.type: String
    get() = typeStr.run {
        if (contains("期末考试")) {
            "期末考试"
        } else if (contains("期中考试")) {
            "期中考试"
        } else if (contains("结课考试")) {
            "结课考试"
        } else {
            typeStr
        }
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

val ExperimentData.timeRange: Pair<Date, Date>
    get() {
        /// Return is month/day/year , hope not change...
        val dateNums: List<Int> = date.split('/').map { it ->
            it.toInt()
        }
        /// And the time arrangement too.
        val cal = Calendar.getInstance()
        cal.set(dateNums[2], dateNums[0] - 1, dateNums[1])
        lateinit var startTime : Date
        lateinit var stopTime : Date

        if (timeStr.contains("15")) {
            cal.set(3,15)
            cal.set(4,55)
            startTime = cal.time
            cal.set(3,18)
            cal.set(4,10)
            stopTime = cal.time
        } else {
            cal.set(3,18)
            cal.set(4,30)
            startTime = cal.time
            cal.set(3,20)
            cal.set(4,45)
            stopTime = cal.time
        }

        return Pair(startTime,stopTime)
    }

