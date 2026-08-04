// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.domain

import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

enum class WearAgendaKind {
    COURSE,
    OTHER_EXPERIMENT,
}

data class WearAgendaItem(
    val kind: WearAgendaKind,
    val title: String,
    val subtitle: String? = null,
    val location: String? = null,
    val start: LocalDateTime,
    val end: LocalDateTime,
)

data class WearHomeData(
    val todayItems: List<WearAgendaItem>,
    val tomorrowItems: List<WearAgendaItem>,
)

object WearAgendaBuilder {
    private val termStartFormatter: DateTimeFormatter =
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")

    fun courseItemsForDay(table: ClassTableData, day: LocalDate): List<WearAgendaItem> {
        val weekIndex = weekIndexForDay(table, day)
        if (weekIndex < 0 || weekIndex >= table.semesterLength) {
            return emptyList()
        }

        val items = mutableListOf<WearAgendaItem>()
        for (arrangement in table.timeArrangement) {
            if (arrangement.source == Source.EMPTY) continue
            // Dart DateTime.weekday: Monday=1 ... Sunday=7
            if (arrangement.day != day.dayOfWeek.value) continue
            if (arrangement.weekList.size <= weekIndex || !arrangement.weekList[weekIndex]) continue

            val startIndex = (arrangement.start - 1) * 2
            val endIndex = (arrangement.stop - 1) * 2 + 1
            if (startIndex < 0 || endIndex >= TimeList.values.size) continue

            val detail = try {
                table.getClassDetail(arrangement)
            } catch (_: Exception) {
                continue
            }

            items += WearAgendaItem(
                kind = WearAgendaKind.COURSE,
                title = detail.name,
                subtitle = blankToNull(arrangement.teacher),
                location = blankToNull(arrangement.classroom),
                start = day.atClassTime(TimeList.values[startIndex]),
                end = day.atClassTime(TimeList.values[endIndex]),
            )
        }
        return items.sortedWith(agendaComparator)
    }

    fun experimentItemsForDay(
        experiments: List<ExperimentData>,
        day: LocalDate,
        zone: ZoneId = ZoneId.systemDefault(),
    ): List<WearAgendaItem> {
        val items = mutableListOf<WearAgendaItem>()
        for (experiment in experiments) {
            for ((startMs, endMs) in experiment.timeRanges) {
                val start = LocalDateTime.ofInstant(Instant.ofEpochMilli(startMs), zone)
                val end = LocalDateTime.ofInstant(Instant.ofEpochMilli(endMs), zone)
                if (start.toLocalDate() != day) continue
                items += WearAgendaItem(
                    kind = WearAgendaKind.OTHER_EXPERIMENT,
                    title = experiment.name,
                    subtitle = blankToNull(experiment.teacher),
                    location = blankToNull(experiment.classroom),
                    start = start,
                    end = end,
                )
            }
        }
        return items.sortedWith(agendaComparator)
    }

    fun weekIndexForDay(table: ClassTableData, day: LocalDate): Int {
        if (table.termStartDay.isEmpty()) return -1
        val start = parseTermStart(table.termStartDay) ?: return -1
        val delta = ChronoUnit.DAYS.between(start, day)
        return if (delta < 0) -1 else (delta / 7).toInt()
    }

    fun loadHomeData(
        semesterCode: String,
        classTable: ClassTableData?,
        experiments: List<ExperimentData>?,
        now: LocalDateTime = LocalDateTime.now(),
        zone: ZoneId = ZoneId.systemDefault(),
    ): WearHomeData {
        val today = now.toLocalDate()
        val tomorrow = today.plusDays(1)
        val todayItems = mutableListOf<WearAgendaItem>()
        val tomorrowItems = mutableListOf<WearAgendaItem>()

        val table = classTable?.takeIf {
            it.semesterCode.isEmpty() || it.semesterCode == semesterCode || semesterCode.isEmpty()
        }
        if (table != null && (semesterCode.isEmpty() || table.semesterCode == semesterCode)) {
            todayItems += courseItemsForDay(table, today)
            tomorrowItems += courseItemsForDay(table, tomorrow)
        }
        if (experiments != null) {
            todayItems += experimentItemsForDay(experiments, today, zone)
            tomorrowItems += experimentItemsForDay(experiments, tomorrow, zone)
        }
        todayItems.sortWith(agendaComparator)
        tomorrowItems.sortWith(agendaComparator)
        return WearHomeData(
            todayItems = todayItems.toList(),
            tomorrowItems = tomorrowItems.toList(),
        )
    }

    private fun parseTermStart(raw: String): LocalDate? = try {
        LocalDateTime.parse(raw, termStartFormatter).toLocalDate()
    } catch (_: Exception) {
        try {
            LocalDate.parse(raw.take(10))
        } catch (_: Exception) {
            null
        }
    }

    private fun LocalDate.atClassTime(hhmm: String): LocalDateTime {
        val hour = (hhmm[0] - '0') * 10 + (hhmm[1] - '0')
        val minute = (hhmm[3] - '0') * 10 + (hhmm[4] - '0')
        return LocalDateTime.of(this, LocalTime.of(hour, minute))
    }

    private fun blankToNull(value: String?): String? =
        value?.takeIf { it.isNotEmpty() }

    private val agendaComparator =
        compareBy<WearAgendaItem>({ it.start }, { it.end })
}
