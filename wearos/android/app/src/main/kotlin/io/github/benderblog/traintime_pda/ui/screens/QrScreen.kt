// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui.screens

import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
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
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.CircularProgressIndicator
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import io.github.benderblog.traintime_pda.payment.PaymentQrResult
import java.time.Instant
import java.time.ZoneId
import java.time.format.DateTimeFormatter

private val CacheFmt: DateTimeFormatter = DateTimeFormatter.ofPattern("MM-dd HH:mm")

@Composable
fun QrScreen(
    loading: Boolean,
    usingWatchAuth: Boolean,
    result: PaymentQrResult?,
    error: String?,
    onBack: () -> Unit,
    onRetry: () -> Unit,
    onWatchAuth: () -> Unit,
) {
    when {
        loading -> {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 34.dp, vertical = 28.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center,
            ) {
                CircularProgressIndicator()
                Spacer(Modifier.height(12.dp))
                Text(
                    text = if (usingWatchAuth) "正在由手表认证" else "正在向手机请求付款码",
                    textAlign = TextAlign.Center,
                    style = MaterialTheme.typography.body2,
                )
                if (!usingWatchAuth) {
                    Spacer(Modifier.height(10.dp))
                    Button(
                        onClick = onWatchAuth,
                        colors = ButtonDefaults.secondaryButtonColors(),
                    ) {
                        Text("改用手表认证")
                    }
                }
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
                    Button(onClick = onRetry) { Text("重试") }
                    Button(
                        onClick = onBack,
                        colors = ButtonDefaults.secondaryButtonColors(),
                    ) { Text("返回") }
                }
            }
        }
        result != null -> {
            Column(Modifier.fillMaxSize()) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(46.dp)
                        .padding(horizontal = 34.dp, vertical = 5.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Button(
                        onClick = onBack,
                        modifier = Modifier.size(36.dp),
                        colors = ButtonDefaults.secondaryButtonColors(),
                    ) { Text("←", fontSize = 17.sp) }
                    Button(
                        onClick = onRetry,
                        modifier = Modifier.size(36.dp),
                        colors = ButtonDefaults.secondaryButtonColors(),
                    ) { Text("↻", fontSize = 17.sp) }
                }
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .fillMaxWidth(),
                ) {
                    val bitmap = remember(result.bytes) {
                        BitmapFactory.decodeByteArray(result.bytes, 0, result.bytes.size)
                    }
                    if (bitmap != null) {
                        Box(
                            modifier = Modifier
                                .align(Alignment.Center)
                                .padding(horizontal = 44.dp, vertical = 2.dp)
                                .clip(RoundedCornerShape(18.dp))
                                .background(Color.White)
                                .padding(12.dp),
                        ) {
                            Image(
                                bitmap = bitmap.asImageBitmap(),
                                contentDescription = "付款码",
                                contentScale = ContentScale.Fit,
                                modifier = Modifier.fillMaxWidth(),
                            )
                        }
                    }
                }
                if (result.fromCache) {
                    val label = remember(result.fetchedAtEpochMs) {
                        val time = Instant.ofEpochMilli(result.fetchedAtEpochMs)
                            .atZone(ZoneId.systemDefault())
                            .toLocalDateTime()
                        "缓存 ${CacheFmt.format(time)}，可能失效"
                    }
                    Text(
                        text = label,
                        fontSize = 10.sp,
                        textAlign = TextAlign.Center,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 34.dp, vertical = 8.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(Color(0xFF7A3E00))
                            .padding(horizontal = 8.dp, vertical = 6.dp),
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
