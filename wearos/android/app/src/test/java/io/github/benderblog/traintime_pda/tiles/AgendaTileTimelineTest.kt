// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.tiles

import com.google.common.truth.Truth.assertThat
import io.github.benderblog.traintime_pda.domain.WearAgendaItem
import io.github.benderblog.traintime_pda.domain.WearAgendaKind
import org.junit.Test
import java.time.LocalDateTime

class AgendaTileTimelineTest {
    private val morning = LocalDateTime.of(2026, 10, 5, 8, 0)
    private val until = morning.toLocalDate().plusDays(2).atStartOfDay()

    @Test
    fun systemTimelineCoversUpcomingOngoingAndFinishedStatesWithoutPolling() {
        val course = course("编译原理", morning.plusMinutes(30), morning.plusHours(2))
        val entries = AgendaTileTimeline.build(listOf(course), morning, until)
        assertThat(entries).containsExactly(
            AgendaTileEntry(morning, course.start, course, false),
            AgendaTileEntry(course.start, course.end, course, true),
            AgendaTileEntry(course.end, until, null, false),
        ).inOrder()
    }

    @Test
    fun openingDuringClassShowsCurrentCourseUntilItsEnd() {
        val course = course("高等数学", morning.minusMinutes(30), morning.plusHours(1))
        val entries = AgendaTileTimeline.build(listOf(course), morning, until)
        assertThat(entries.first()).isEqualTo(AgendaTileEntry(morning, course.end, course, true))
    }

    @Test
    fun backToBackClassesSwitchAtExactBoundaryWithoutShowingFinishedCourse() {
        val first = course("第一节", morning, morning.plusHours(1))
        val second = course("第二节", first.end, first.end.plusHours(1))
        val entries = AgendaTileTimeline.build(listOf(second, first), morning, until)
        assertThat(entries[0]).isEqualTo(AgendaTileEntry(morning, first.end, first, true))
        assertThat(entries[1]).isEqualTo(AgendaTileEntry(first.end, second.end, second, true))
    }

    @Test
    fun overlappingExperimentAppearsAfterEarlierCourseEnds() {
        val course = course("课程", morning, morning.plusHours(2))
        val experiment = course("实验", morning.plusHours(1), morning.plusHours(3))
            .copy(kind = WearAgendaKind.OTHER_EXPERIMENT)
        val entries = AgendaTileTimeline.build(listOf(experiment, course), morning, until)
        assertThat(entries[0]).isEqualTo(AgendaTileEntry(morning, course.end, course, true))
        assertThat(entries[1]).isEqualTo(AgendaTileEntry(course.end, experiment.end, experiment, true))
    }

    @Test
    fun tomorrowRemainsAvailableWhileApplicationIsClosedOvernight() {
        val tomorrow = course("明天课程", morning.plusDays(1), morning.plusDays(1).plusHours(1))
        val entries = AgendaTileTimeline.build(listOf(tomorrow), morning, until)
        assertThat(entries.first()).isEqualTo(AgendaTileEntry(morning, tomorrow.start, tomorrow, false))
        assertThat(entries[1]).isEqualTo(AgendaTileEntry(tomorrow.start, tomorrow.end, tomorrow, true))
        assertThat(entries.last().end).isEqualTo(until)
    }

    @Test
    fun expiredInvalidAndOutOfHorizonEventsCannotRemainOnTile() {
        val items = listOf(
            course("已结束", morning.minusHours(1), morning),
            course("无效", morning.plusHours(1), morning),
            course("范围外", until, until.plusHours(1)),
        )
        assertThat(AgendaTileTimeline.build(items, morning, until))
            .containsExactly(AgendaTileEntry(morning, until, null, false))
    }

    @Test
    fun emptyCacheAgendaHasOneContinuousEmptyState() {
        assertThat(AgendaTileTimeline.build(emptyList(), morning, until))
            .containsExactly(AgendaTileEntry(morning, until, null, false))
        assertThat(AgendaTileTimeline.build(emptyList(), morning, morning)).isEmpty()
    }

    private fun course(name: String, start: LocalDateTime, end: LocalDateTime) = WearAgendaItem(
        kind = WearAgendaKind.COURSE,
        title = name,
        location = "A-301",
        start = start,
        end = end,
    )
}
