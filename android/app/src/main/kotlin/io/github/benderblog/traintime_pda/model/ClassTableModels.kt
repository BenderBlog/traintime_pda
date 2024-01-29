package io.github.benderblog.traintime_pda.model

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object ClassTableConstants {
    const val CLASS_FILE_NAME = "ClassTable.json"
    const val EXAM_FILE_NAME = "exam.json"

    // In SharedPreferencesPlugin, SHARED_PREFERENCES_NAME is private.
    // Be attention to the changes of SharedPreferencesPlugin.SHARED_PREFERENCES_NAME.
    const val CONFIG_SHARED_PREFS_NAME = "FlutterSharedPreferences"
    const val CONFIG_WEEK_SWIFT_KEY = "flutter.swift"

    const val DATE_FORMAT_STR = "yyyy-MM-dd HH:mm:ss"

    val CLASS_TIME_POINTS = listOf(
        "8:30",
        "9:15",
        "9:20",
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
        "20:35"
    )

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
    const val PACKAGE_NAME = "packageName"
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
    @SerializedName("classChanges")
    val classChanges: List<ClassChange>,
) {
    companion object {
        val EMPTY = ClassTableData(
            0, "", "2024-1-1",
            emptyList(), emptyList(), emptyList(), emptyList(), emptyList()
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

//just a stub (It is unuseful for class table.)
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

sealed class ClassChangeType(val rawValue: String) {
    object CHANGE : ClassChangeType("change")
    object STOP : ClassChangeType("stop")
    object PATCH : ClassChangeType("patch")
}

data class ClassChange(
    /// KCH 课程号
    @SerializedName("classCode")
    var classCode: String,
    /// KXH 班级号
    @SerializedName("classNumber")
    var classNumber: String,
    /// KCM 课程名
    @SerializedName("className")
    var className: String,
    /// 来自 SKZC 原周次信息，可能是空
    @SerializedName("originalAffectedWeeks")
    var originalAffectedWeeks: List<Boolean>?,
    /// 来自 XSKZC 新周次信息，可能是空
    @SerializedName("newAffectedWeeks")
    var newAffectedWeeks: List<Boolean>?,
    /// YSKJS 原先的老师
    @SerializedName("originalTeacherData")
    var originalTeacherData: String?,
    /// XSKJS 新换的老师
    @SerializedName("newTeacherData")
    var newTeacherData: String?,
    /// KSJS-JSJC 原先的课次信息
    @SerializedName("originalClassRange")
    var originalClassRange: List<Int>,
    /// XKSJS-XJSJC 新的课次信息
    @SerializedName("newClassRange")
    var newClassRange: List<Int>,
    /// SKXQ 原先的星期
    @SerializedName("originalWeek")
    var originalWeek: Int?,
    /// XSKXQ 现在的星期
    @SerializedName("newWeek")
    var newWeek: Int?,
    /// JASMC 旧教室
    @SerializedName("originalClassroom")
    var originalClassroom: String?,
    /// XJASMC 新教室
    @SerializedName("newClassroom")
    var newClassroom: String?,
) {
    val originalAffectedWeeksList: List<Int>
        get() {
            if (originalAffectedWeeks.isNullOrEmpty()) {
                return emptyList()
            }
            return mutableListOf<Int>().apply {
                for (i in originalAffectedWeeks!!.indices) {
                    if (originalAffectedWeeks!![i]) {
                        add(i)
                    }
                }
            }
        }

    val newAffectedWeeksList: List<Int>
        get() {
            if (newAffectedWeeks.isNullOrEmpty()) {
                return emptyList()
            }
            return mutableListOf<Int>().apply {
                for (i in newAffectedWeeks!!.indices) {
                    if (newAffectedWeeks!![i]) {
                        add(i)
                    }
                }
            }
        }

    val isTeacherChanged: Boolean
        get() {
            val originalTeacherCodeStr =
                originalTeacherData
                    ?.replace(" ", "")?.split(",", "/")
                    ?.toMutableList() ?: mutableListOf()
            val originalTeacherCode: List<Int> = mutableListOf<Int>().apply {
                for (i in originalTeacherCodeStr) {
                    i.toIntOrNull()?.let { value ->
                        add(value)
                    }
                }
            }
            val newTeacherCodeStr =
                newTeacherData
                    ?.replace(" ", "")?.split(",", "/")
                    ?.toMutableList() ?: mutableListOf()
            val newTeacherCode: List<Int> = mutableListOf<Int>().apply {
                for (i in newTeacherCodeStr) {
                    i.toIntOrNull()?.let { value ->
                        add(value)
                    }
                }
            }
            return originalTeacherCode.toSet() == newTeacherCode.toSet()
        }
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
