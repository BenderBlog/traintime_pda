// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.tiles

import io.github.benderblog.traintime_pda.domain.WearAgendaItem
import java.time.LocalDateTime

data class AgendaTileEntry(
    val start: LocalDateTime,
    val end: LocalDateTime,
    val item: WearAgendaItem?,
    val ongoing: Boolean,
)

object AgendaTileTimeline {
    fun build(
        items: List<WearAgendaItem>,
        now: LocalDateTime,
        until: LocalDateTime,
    ): List<AgendaTileEntry> {
        if (until <= now) return emptyList()
        val upcoming = items.filter { it.end > now && it.start < until && it.end > it.start }
            .sortedWith(compareBy({ it.start }, { it.end }))
        val boundaries = (listOf(now, until) + upcoming.flatMap { listOf(it.start, it.end) })
            .filter { it >= now && it <= until }.distinct().sorted()
        val entries = mutableListOf<AgendaTileEntry>()
        for ((start, end) in boundaries.zipWithNext()) {
            val active = upcoming.firstOrNull { it.start <= start && it.end > start }
            val item = active ?: upcoming.firstOrNull { it.start > start }
            val previous = entries.lastOrNull()
            if (previous != null && previous.item == item && previous.ongoing == (active != null)) {
                entries[entries.lastIndex] = previous.copy(end = end)
            } else {
                entries += AgendaTileEntry(start, end, item, active != null)
            }
        }
        return entries
    }
}
