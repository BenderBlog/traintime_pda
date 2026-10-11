// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.domain

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId

class WearAgendaBuilderTest {
    @Test
    fun courseItemsUseTargetDateWeekAndClassPeriodTimes() {
        val table = ClassTableData(
            semesterLength = 2,
            semesterCode = "2026-1",
            termStartDay = "2026-05-18 00:00:00",
            classDetail = listOf(ClassDetail(name = "编译原理", code = "CS301", number = "01")),
            timeArrangement = listOf(
                TimeArrangement(
                    index = 0,
                    weekList = listOf(true, false),
                    teacher = "张老师",
                    day = 2, // Tuesday
                    start = 1,
                    stop = 2,
                    source = Source.SCHOOL,
                    classroom = "B-101",
                ),
            ),
        )

        val firstWeek = WearAgendaBuilder.courseItemsForDay(table, LocalDate.of(2026, 5, 19))
        val secondWeek = WearAgendaBuilder.courseItemsForDay(table, LocalDate.of(2026, 5, 26))

        assertThat(firstWeek).hasSize(1)
        assertThat(firstWeek.single().kind).isEqualTo(WearAgendaKind.COURSE)
        assertThat(firstWeek.single().title).isEqualTo("编译原理")
        assertThat(firstWeek.single().subtitle).isEqualTo("张老师")
        assertThat(firstWeek.single().location).isEqualTo("B-101")
        assertThat(firstWeek.single().start).isEqualTo(LocalDateTime.of(2026, 5, 19, 8, 30))
        assertThat(firstWeek.single().end).isEqualTo(LocalDateTime.of(2026, 5, 19, 10, 5))
        assertThat(secondWeek).isEmpty()
    }

    @Test
    fun experimentItemsKeepTargetDayRanges() {
        val zone = ZoneId.of("Asia/Shanghai")
        val experiments = listOf(
            ExperimentData(
                name = "电工实习",
                classroom = "工程坊",
                timeRanges = listOf(
                    LocalDateTime.of(2026, 5, 19, 14, 0)
                        .atZone(zone).toInstant().toEpochMilli() to
                        LocalDateTime.of(2026, 5, 19, 16, 0)
                            .atZone(zone).toInstant().toEpochMilli(),
                ),
                teacher = "王老师",
            ),
            ExperimentData(
                name = "工程训练",
                classroom = "工程坊",
                timeRanges = listOf(
                    LocalDateTime.of(2026, 5, 20, 14, 0)
                        .atZone(zone).toInstant().toEpochMilli() to
                        LocalDateTime.of(2026, 5, 20, 16, 0)
                            .atZone(zone).toInstant().toEpochMilli(),
                ),
                teacher = "刘老师",
            ),
        )

        val items = WearAgendaBuilder.experimentItemsForDay(
            experiments,
            LocalDate.of(2026, 5, 19),
            zone,
        )

        assertThat(items).hasSize(1)
        assertThat(items.single().kind).isEqualTo(WearAgendaKind.OTHER_EXPERIMENT)
        assertThat(items.single().title).isEqualTo("电工实习")
        assertThat(items.single().subtitle).isEqualTo("王老师")
        assertThat(items.single().location).isEqualTo("工程坊")
        assertThat(items.single().start).isEqualTo(LocalDateTime.of(2026, 5, 19, 14, 0))
        assertThat(items.single().end).isEqualTo(LocalDateTime.of(2026, 5, 19, 16, 0))
    }

    @Test
    fun cacheOnlyLoadBuildsAgendaWithoutNetwork() {
        val table = singleCourseTable("离线课程")
        val data = WearAgendaBuilder.loadHomeData(
            semesterCode = "2026-1",
            classTable = table,
            experiments = null,
            now = LocalDateTime.of(2026, 5, 19, 8, 0),
        )
        assertThat(data.todayItems.map { it.title }).containsExactly("离线课程")
    }

    @Test
    fun eveningPeriodMatchesPhoneSoTileDoesNotSwitchFiveMinutesLate() {
        val table = singleCourseTable("晚间课程").let {
            it.copy(timeArrangement = it.timeArrangement.map { item ->
                item.copy(start = 10, stop = 10)
            })
        }
        val item = WearAgendaBuilder.courseItemsForDay(table, LocalDate.of(2026, 5, 19)).single()
        assertThat(item.start).isEqualTo(LocalDateTime.of(2026, 5, 19, 19, 50))
        assertThat(item.end).isEqualTo(LocalDateTime.of(2026, 5, 19, 20, 35))
    }

    @Test
    fun futureWeekIncludesAllSevenDaysAndKeepsSundayClassesAndExperiments() {
        val original = singleCourseTable("周末课程")
        val table = original.copy(
            semesterLength = 2,
            timeArrangement = original.timeArrangement.map {
                it.copy(day = 7, weekList = listOf(false, true))
            },
        )
        val zone = ZoneId.of("Asia/Shanghai")
        val sunday = LocalDate.of(2026, 5, 31)
        val experiment = ExperimentData(
            name = "周末实验",
            classroom = "实验室",
            teacher = "王老师",
            timeRanges = listOf(
                sunday.atTime(14, 0).atZone(zone).toInstant().toEpochMilli() to
                    sunday.atTime(16, 0).atZone(zone).toInstant().toEpochMilli(),
            ),
        )
        val days = WearAgendaBuilder.loadWeekData(
            semesterCode = "2026-1",
            classTable = table,
            experiments = listOf(experiment),
            weekStart = LocalDate.of(2026, 5, 25),
            zone = zone,
        )
        assertThat(days.map { it.date.dayOfWeek.value }).containsExactly(1, 2, 3, 4, 5, 6, 7).inOrder()
        assertThat(days.last().date).isEqualTo(sunday)
        assertThat(days.last().items.map { it.title }).containsExactly("周末课程", "周末实验").inOrder()
        assertThat(days.dropLast(1).flatMap { it.items }).isEmpty()
    }

    companion object {
        fun singleCourseTable(name: String): ClassTableData = ClassTableData(
            semesterLength = 1,
            semesterCode = "2026-1",
            termStartDay = "2026-05-18 00:00:00",
            classDetail = listOf(ClassDetail(name = name)),
            timeArrangement = listOf(
                TimeArrangement(
                    index = 0,
                    weekList = listOf(true),
                    teacher = "赵老师",
                    day = 2,
                    start = 3,
                    stop = 4,
                    source = Source.SCHOOL,
                    classroom = "A-301",
                ),
            ),
        )
    }
}
