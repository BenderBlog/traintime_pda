// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.domain

import org.json.JSONArray
import org.json.JSONObject

enum class Source {
    EMPTY,
    SCHOOL,
    USER,
    ;

    companion object {
        fun fromJson(value: String?): Source = when (value) {
            "school" -> SCHOOL
            "user" -> USER
            "empty" -> EMPTY
            else -> EMPTY
        }
    }

    fun toJson(): String = when (this) {
        EMPTY -> "empty"
        SCHOOL -> "school"
        USER -> "user"
    }
}

data class ClassDetail(
    val name: String,
    val code: String? = null,
    val number: String? = null,
) {
    companion object {
        fun fromJson(json: JSONObject): ClassDetail = ClassDetail(
            name = json.getString("name"),
            code = json.optStringOrNull("code"),
            number = json.optStringOrNull("number"),
        )
    }
}

data class NotArrangementClassDetail(
    val name: String,
    val code: String? = null,
    val number: String? = null,
    val teacher: String? = null,
) {
    companion object {
        fun fromJson(json: JSONObject): NotArrangementClassDetail =
            NotArrangementClassDetail(
                name = json.getString("name"),
                code = json.optStringOrNull("code"),
                number = json.optStringOrNull("number"),
                teacher = json.optStringOrNull("teacher"),
            )
    }
}

data class TimeArrangement(
    val index: Int,
    val weekList: List<Boolean>,
    val teacher: String? = null,
    val day: Int,
    val start: Int,
    val stop: Int,
    val source: Source,
    val classroom: String? = null,
) {
    companion object {
        fun fromJson(json: JSONObject): TimeArrangement {
            val weekArray = json.getJSONArray("week_list")
            val weekList = buildList(weekArray.length()) {
                for (i in 0 until weekArray.length()) {
                    add(weekArray.getBoolean(i))
                }
            }
            return TimeArrangement(
                index = json.getInt("index"),
                weekList = weekList,
                teacher = json.optStringOrNull("teacher"),
                day = json.getInt("day"),
                start = json.getInt("start"),
                stop = json.getInt("stop"),
                source = Source.fromJson(json.optString("source")),
                classroom = json.optStringOrNull("classroom"),
            )
        }
    }
}

enum class ChangeType {
    CHANGE,
    STOP,
    PATCH,
    ;

    companion object {
        fun fromJson(value: String?): ChangeType = when (value) {
            "stop" -> STOP
            "patch" -> PATCH
            else -> CHANGE
        }
    }
}

data class ClassChange(
    val type: ChangeType,
    val classCode: String,
    val classNumber: String,
    val className: String,
    val originalAffectedWeeks: List<Boolean>?,
    val newAffectedWeeks: List<Boolean>?,
    val originalTeacherData: String?,
    val newTeacherData: String?,
    val originalClassRange: List<Int>,
    val newClassRange: List<Int>,
    val originalWeek: Int?,
    val newWeek: Int?,
    val originalClassroom: String?,
    val newClassroom: String?,
) {
    companion object {
        fun fromJson(json: JSONObject): ClassChange = ClassChange(
            type = ChangeType.fromJson(json.optString("type")),
            classCode = json.getString("classCode"),
            classNumber = json.getString("classNumber"),
            className = json.getString("className"),
            originalAffectedWeeks = json.optBooleanList("originalAffectedWeeks"),
            newAffectedWeeks = json.optBooleanList("newAffectedWeeks"),
            originalTeacherData = json.optStringOrNull("originalTeacherData"),
            newTeacherData = json.optStringOrNull("newTeacherData"),
            originalClassRange = json.optIntList("originalClassRange"),
            newClassRange = json.optIntList("newClassRange"),
            originalWeek = json.optIntOrNull("originalWeek"),
            newWeek = json.optIntOrNull("newWeek"),
            originalClassroom = json.optStringOrNull("originalClassroom"),
            newClassroom = json.optStringOrNull("newClassroom"),
        )
    }
}

data class ClassTableData(
    val semesterLength: Int = 1,
    val semesterCode: String = "",
    val termStartDay: String = "",
    val classDetail: List<ClassDetail> = emptyList(),
    val userDefinedDetail: List<ClassDetail> = emptyList(),
    val notArranged: List<NotArrangementClassDetail> = emptyList(),
    val timeArrangement: List<TimeArrangement> = emptyList(),
    val classChanges: List<ClassChange> = emptyList(),
) {
    fun getClassDetail(arrangement: TimeArrangement): ClassDetail = when (arrangement.source) {
        Source.SCHOOL -> classDetail[arrangement.index]
        Source.USER -> userDefinedDetail[arrangement.index]
        Source.EMPTY -> error("empty source has no class detail")
    }

    companion object {
        fun fromJson(json: JSONObject): ClassTableData = ClassTableData(
            semesterLength = json.optInt("semesterLength", 1),
            semesterCode = json.optString("semesterCode", ""),
            termStartDay = json.optString("termStartDay", ""),
            classDetail = json.optObjectList("classDetail") { ClassDetail.fromJson(it) },
            userDefinedDetail = json.optObjectList("userDefinedDetail") { ClassDetail.fromJson(it) },
            notArranged = json.optObjectList("notArranged") {
                NotArrangementClassDetail.fromJson(it)
            },
            timeArrangement = json.optObjectList("timeArrangement") {
                TimeArrangement.fromJson(it)
            },
            classChanges = json.optObjectList("classChanges") { ClassChange.fromJson(it) },
        )

        fun fromJsonString(raw: String): ClassTableData = fromJson(JSONObject(raw))
    }
}

data class ExperimentData(
    val type: String = "others",
    val name: String,
    val classroom: String,
    val timeRanges: List<Pair<Long, Long>>,
    val teacher: String,
    val reference: String? = null,
) {
    companion object {
        fun fromJson(json: JSONObject): ExperimentData {
            val ranges = json.getJSONArray("timeRanges")
            val parsed = buildList(ranges.length()) {
                for (i in 0 until ranges.length()) {
                    val item = ranges.getJSONObject(i)
                    // Dart record serialization uses $1 / $2 keys.
                    val start = parseIsoMillis(item.getString("\$1"))
                    val end = parseIsoMillis(item.getString("\$2"))
                    add(start to end)
                }
            }
            return ExperimentData(
                type = json.optString("type", "others"),
                name = json.getString("name"),
                classroom = json.getString("classroom"),
                timeRanges = parsed,
                teacher = json.getString("teacher"),
                reference = json.optStringOrNull("reference"),
            )
        }

        fun listFromJsonArray(array: JSONArray): List<ExperimentData> =
            buildList(array.length()) {
                for (i in 0 until array.length()) {
                    add(fromJson(array.getJSONObject(i)))
                }
            }

        private fun parseIsoMillis(value: String): Long {
            // Accept both local and Z-suffixed ISO-8601 timestamps from Dart.
            val normalized = value
                .replace(' ', 'T')
                .let { if (it.endsWith('Z')) it else it }
            return java.time.OffsetDateTime.parse(
                if (normalized.endsWith('Z') || normalized.contains('+') ||
                    normalized.matches(Regex(".*[+-]\\d{2}:\\d{2}$"))
                ) {
                    normalized
                } else {
                    // Local datetime without offset: treat as system-local wall clock.
                    return java.time.LocalDateTime.parse(normalized.take(19))
                        .atZone(java.time.ZoneId.systemDefault())
                        .toInstant()
                        .toEpochMilli()
                },
            ).toInstant().toEpochMilli()
        }
    }
}

internal fun JSONObject.optStringOrNull(key: String): String? {
    if (!has(key) || isNull(key)) return null
    val value = optString(key, "")
    return value.ifEmpty { null }
}

internal fun JSONObject.optIntOrNull(key: String): Int? {
    if (!has(key) || isNull(key)) return null
    return getInt(key)
}

internal fun JSONObject.optBooleanList(key: String): List<Boolean>? {
    if (!has(key) || isNull(key)) return null
    val array = getJSONArray(key)
    return buildList(array.length()) {
        for (i in 0 until array.length()) add(array.getBoolean(i))
    }
}

internal fun JSONObject.optIntList(key: String): List<Int> {
    if (!has(key) || isNull(key)) return emptyList()
    val array = getJSONArray(key)
    return buildList(array.length()) {
        for (i in 0 until array.length()) add(array.getInt(i))
    }
}

internal fun <T> JSONObject.optObjectList(key: String, map: (JSONObject) -> T): List<T> {
    if (!has(key) || isNull(key)) return emptyList()
    val array = getJSONArray(key)
    return buildList(array.length()) {
        for (i in 0 until array.length()) add(map(array.getJSONObject(i)))
    }
}
