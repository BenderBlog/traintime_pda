// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.Chip
import androidx.wear.compose.material.ChipDefaults
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import io.github.benderblog.traintime_pda.domain.WearAgendaItem
import io.github.benderblog.traintime_pda.domain.WearAgendaKind
import io.github.benderblog.traintime_pda.domain.WearHomeData
import java.time.format.DateTimeFormatter

private val TimeFmt: DateTimeFormatter = DateTimeFormatter.ofPattern("HH:mm")

@Composable
fun HomeScreen(
    data: WearHomeData,
    loading: Boolean,
    error: String?,
    onRefresh: () -> Unit,
    onLogout: () -> Unit,
    onOpenQr: () -> Unit,
    onRetry: () -> Unit,
) {
    if (loading && data.todayItems.isEmpty() && data.tomorrowItems.isEmpty() && error == null) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        return
    }

    if (error != null && data.todayItems.isEmpty() && data.tomorrowItems.isEmpty()) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
        ) {
            Text(
                text = error.take(120),
                textAlign = TextAlign.Center,
                style = MaterialTheme.typography.body2,
                color = MaterialTheme.colors.error,
            )
            Spacer(Modifier.height(12.dp))
            Button(onClick = onRetry) { Text("重试") }
            Spacer(Modifier.height(8.dp))
            Button(
                onClick = onLogout,
                colors = ButtonDefaults.secondaryButtonColors(),
            ) { Text("重新登录") }
        }
        return
    }

    // Content is biased slightly upward for round screens (extra top padding is modest).
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(start = 28.dp, top = 32.dp, end = 28.dp, bottom = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Column(
            modifier = Modifier
                .widthIn(max = 280.dp)
                .fillMaxWidth(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            AgendaSection(title = "今天", items = data.todayItems)
            AgendaSection(title = "明天", items = data.tomorrowItems)
            Spacer(Modifier.height(8.dp))
            CampusCard(onOpenQr = onOpenQr)
            Spacer(Modifier.height(8.dp))
            Row(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Button(
                    onClick = onRefresh,
                    modifier = Modifier.weight(1f, fill = false),
                ) {
                    Text(if (loading) "…" else "刷新")
                }
                Button(
                    onClick = onLogout,
                    colors = ButtonDefaults.secondaryButtonColors(),
                    modifier = Modifier.weight(1f, fill = false),
                ) {
                    Text("退出")
                }
            }
            if (error != null) {
                Spacer(Modifier.height(6.dp))
                Text(
                    text = error.take(80),
                    color = MaterialTheme.colors.error,
                    style = MaterialTheme.typography.caption2,
                    textAlign = TextAlign.Center,
                )
            }
        }
    }
}

@Composable
private fun AgendaSection(title: String, items: List<WearAgendaItem>) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 8.dp),
        horizontalAlignment = Alignment.Start,
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.title3,
            fontWeight = FontWeight.SemiBold,
        )
        if (items.isEmpty()) {
            Text(
                text = "没有安排",
                style = MaterialTheme.typography.body2,
                modifier = Modifier.padding(vertical = 8.dp),
            )
        } else {
            items.forEach { item ->
                AgendaCard(item)
            }
        }
    }
}

@Composable
private fun AgendaCard(item: WearAgendaItem) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp)
            .clip(RoundedCornerShape(18.dp))
            .background(MaterialTheme.colors.surface)
            .padding(12.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            KindPill(item.kind)
            Spacer(Modifier.padding(horizontal = 3.dp))
            Text(
                text = item.title,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                fontWeight = FontWeight.Bold,
                style = MaterialTheme.typography.body1,
                modifier = Modifier.weight(1f),
            )
        }
        Spacer(Modifier.height(6.dp))
        Text(
            text = "${item.start.format(TimeFmt)}-${item.end.format(TimeFmt)}",
            style = MaterialTheme.typography.body2,
        )
        item.location?.let {
            Text(
                text = it,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = MaterialTheme.typography.caption1,
            )
        }
        item.subtitle?.let {
            Text(
                text = it,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                style = MaterialTheme.typography.caption2,
            )
        }
    }
}

@Composable
private fun KindPill(kind: WearAgendaKind) {
    val (label, color) = when (kind) {
        WearAgendaKind.COURSE -> "课" to MaterialTheme.colors.primary
        WearAgendaKind.OTHER_EXPERIMENT -> "实" to Color(0xFF4CAF50)
    }
    Text(
        text = label,
        color = color,
        fontSize = 11.sp,
        modifier = Modifier
            .clip(RoundedCornerShape(999.dp))
            .background(color.copy(alpha = 0.22f))
            .padding(horizontal = 7.dp, vertical = 2.dp),
    )
}

@Composable
private fun CampusCard(onOpenQr: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(MaterialTheme.colors.surface)
            .padding(14.dp),
    ) {
        Text(
            text = "校园卡",
            style = MaterialTheme.typography.title3,
            fontWeight = FontWeight.SemiBold,
        )
        Spacer(Modifier.height(8.dp))
        Chip(
            onClick = onOpenQr,
            label = { Text("付款码") },
            colors = ChipDefaults.primaryChipColors(),
            modifier = Modifier.fillMaxWidth(),
        )
    }
}
