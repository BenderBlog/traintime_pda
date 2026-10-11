// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import io.github.benderblog.traintime_pda.domain.WearAgendaDay
import java.time.format.DateTimeFormatter
import java.util.Locale
import kotlinx.coroutines.delay

private val DayFmt = DateTimeFormatter.ofPattern("EEEE M/d", Locale.CHINESE)
private val RangeFmt = DateTimeFormatter.ofPattern("M/d")

@Composable
fun AgendaScreen(
    weeks: List<List<WearAgendaDay>>,
    initialWeek: Int,
    showSwipeHint: Boolean,
    error: String?,
) {
    if (weeks.isEmpty()) {
        Column(
            modifier = Modifier.fillMaxSize().padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Text(error ?: "暂无日程", textAlign = TextAlign.Center)
        }
        return
    }
    val pager = rememberPagerState(initialPage = initialWeek) { weeks.size }
    var hintVisible by remember(showSwipeHint) { mutableStateOf(showSwipeHint) }
    LaunchedEffect(showSwipeHint) {
        if (showSwipeHint) {
            delay(3_000)
            hintVisible = false
        }
    }
    Box(Modifier.fillMaxSize()) {
        HorizontalPager(state = pager, modifier = Modifier.fillMaxSize()) { page ->
            val days = weeks[page]
            Column(
                modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())
                    .padding(horizontal = 28.dp, vertical = 32.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
            ) {
                Text("第 ${page + 1} 周", style = MaterialTheme.typography.title3)
                Text(
                    "${days.first().date.format(RangeFmt)} – ${days.last().date.format(RangeFmt)}",
                    style = MaterialTheme.typography.caption1,
                )
                days.forEach { day ->
                    AgendaSection(day.date.format(DayFmt), day.items)
                }
            }
        }
        if (hintVisible) {
            Text(
                "左右滑动切换周",
                fontSize = 10.sp,
                modifier = Modifier.align(Alignment.TopCenter).padding(top = 10.dp)
                    .background(MaterialTheme.colors.surface, RoundedCornerShape(16.dp))
                    .padding(horizontal = 8.dp, vertical = 3.dp),
            )
        }
    }
}
