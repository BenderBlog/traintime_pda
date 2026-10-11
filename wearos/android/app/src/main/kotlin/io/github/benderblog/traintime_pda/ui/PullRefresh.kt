// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Velocity
import androidx.compose.ui.unit.dp
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme

@Composable
internal fun PullRefresh(
    refreshing: Boolean,
    onRefresh: () -> Unit,
    content: @Composable () -> Unit,
) {
    val threshold = with(LocalDensity.current) { 48.dp.toPx() }
    val busy by rememberUpdatedState(refreshing)
    val refresh by rememberUpdatedState(onRefresh)
    var pull by remember { mutableFloatStateOf(0f) }
    val connection = remember(threshold) {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                if (source != NestedScrollSource.UserInput || busy || pull == 0f || available.y >= 0f) return Offset.Zero
                val consumed = available.y.coerceAtLeast(-pull * 2f)
                pull += consumed / 2f
                return Offset(0f, consumed)
            }

            override fun onPostScroll(consumed: Offset, available: Offset, source: NestedScrollSource): Offset {
                // Only the distance left after the page reaches its top starts a refresh.
                if (source != NestedScrollSource.UserInput || busy || available.y <= 0f) return Offset.Zero
                pull = (pull + available.y / 2f).coerceAtMost(threshold * 1.5f)
                return Offset(0f, available.y)
            }

            override suspend fun onPreFling(available: Velocity): Velocity {
                val released = pull
                pull = 0f
                if (!busy && released >= threshold) refresh()
                return if (released > 0f) available else Velocity.Zero
            }
        }
    }
    val offset by animateFloatAsState(
        targetValue = if (refreshing) threshold else pull,
        animationSpec = tween(160),
        label = "pullRefresh",
    )
    Box(Modifier.fillMaxSize().nestedScroll(connection)) {
        Box(Modifier.fillMaxSize()) { content() }
        if (offset > 1f) {
            Box(
                Modifier.align(Alignment.TopCenter).padding(top = 14.dp)
                    .graphicsLayer { alpha = (offset / threshold).coerceIn(0f, 1f) }
                    .background(MaterialTheme.colors.surface, RoundedCornerShape(20.dp))
                    .padding(horizontal = 10.dp, vertical = 6.dp),
                contentAlignment = Alignment.Center,
            ) {
                if (refreshing) CircularProgressIndicator(Modifier.size(18.dp))
                else CircularProgressIndicator(
                    progress = (pull / threshold).coerceIn(0f, 1f),
                    modifier = Modifier.size(18.dp),
                )
            }
        }
    }
}
