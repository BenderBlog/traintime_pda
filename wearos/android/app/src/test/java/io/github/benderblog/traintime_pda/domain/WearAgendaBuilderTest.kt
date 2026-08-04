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
