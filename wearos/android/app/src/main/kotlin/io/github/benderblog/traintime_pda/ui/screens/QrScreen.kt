// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui.screens

import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.rememberScrollableState
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import io.github.benderblog.traintime_pda.payment.PaymentQrResult
import io.github.benderblog.traintime_pda.ui.PullRefresh
import io.github.benderblog.traintime_pda.ui.pressFeedback
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.delay

private val CacheFmt: DateTimeFormatter = DateTimeFormatter.ofPattern("HH:mm:ss")

@Composable
fun QrScreen(
    loading: Boolean,
    result: PaymentQrResult?,
    error: String?,
    onBack: () -> Unit,
    onRetry: () -> Unit,
) {
    PullRefresh(refreshing = loading, onRefresh = onRetry) {
        when {
            loading && result == null -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(rememberScrollState())
                        .padding(horizontal = 34.dp, vertical = 28.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                ) {
                    Text(
                        text = "正在获取付款码",
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.body2,
                    )
                }
            }
            error != null && result == null -> {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(rememberScrollState())
                        .padding(28.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center,
                ) {
                    Text("付款码获取失败", textAlign = TextAlign.Center)
                    Spacer(Modifier.height(6.dp))
                    Text(
                        text = error.take(100),
                        textAlign = TextAlign.Center,
                        style = MaterialTheme.typography.caption2,
                        color = MaterialTheme.colors.error,
                    )
                    Spacer(Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        val retryInteraction = remember { MutableInteractionSource() }
                        val backInteraction = remember { MutableInteractionSource() }
                        Button(
                            onClick = onRetry,
                            interactionSource = retryInteraction,
                            modifier = Modifier.pressFeedback(retryInteraction),
                        ) { Text("重试") }
                        Button(
                            onClick = onBack,
                            colors = ButtonDefaults.secondaryButtonColors(),
                            interactionSource = backInteraction,
                            modifier = Modifier.pressFeedback(backInteraction),
                        ) { Text("返回") }
                    }
                }
            }
            result != null -> {
                var showTime by remember(result) { mutableStateOf(true) }
                LaunchedEffect(result) {
                    delay(3_000)
                    showTime = false
                }
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .scrollable(rememberScrollableState { 0f }, Orientation.Vertical),
                ) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .fillMaxWidth(0.78f)
                            .aspectRatio(1f)
                            .clip(RoundedCornerShape(18.dp))
                            .background(Color.White)
                            .padding(12.dp),
                    ) {
                        val bitmap = remember(result.bytes) {
                            BitmapFactory.decodeByteArray(result.bytes, 0, result.bytes.size)
                        }
                        if (bitmap != null) {
                            Image(
                                bitmap = bitmap.asImageBitmap(),
                                contentDescription = "付款码",
                                contentScale = ContentScale.Fit,
                                modifier = Modifier.fillMaxSize(),
                            )
                        }
                    }
                    result.refreshError?.let { message ->
                        Text(
                            text = message,
                            fontSize = 10.sp,
                            textAlign = TextAlign.Center,
                            maxLines = 2,
                            overflow = TextOverflow.Ellipsis,
                            color = MaterialTheme.colors.error,
                            modifier = Modifier
                                .align(Alignment.TopCenter)
                                .padding(horizontal = 52.dp, vertical = 16.dp),
                        )
                    }
                    if (showTime) Column(
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .padding(horizontal = 40.dp, vertical = 6.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                    ) {
                        val label = remember(result.fetchedAtEpochMs, result.fromCache) {
                            val time = Instant.ofEpochMilli(result.fetchedAtEpochMs)
                                .atZone(ZoneId.systemDefault())
                                .toLocalDateTime()
                            if (result.fromCache) "缓存 ${CacheFmt.format(time)} · 可能失效"
                            else "更新 ${CacheFmt.format(time)}"
                        }
                        Text(
                            text = label,
                            fontSize = 10.sp,
                            textAlign = TextAlign.Center,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                            modifier = Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .background(if (result.fromCache) Color(0xFF7A3E00) else Color.Black)
                                .padding(horizontal = 8.dp, vertical = 2.dp),
                        )
                    }
                }
            }
            else -> {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator()
                }
            }
        }
    }
}
