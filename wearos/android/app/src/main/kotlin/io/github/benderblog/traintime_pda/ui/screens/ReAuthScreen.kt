// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text
import androidx.wear.compose.material.ToggleChip
import androidx.wear.compose.material.ToggleChipDefaults

@Composable
fun ReAuthScreen(
    notice: String?,
    error: String?,
    code: String,
    sending: Boolean,
    submitting: Boolean,
    secondsRemaining: Int,
    trustDevice: Boolean,
    onCodeChange: (String) -> Unit,
    onTrustChange: (Boolean) -> Unit,
    onSend: () -> Unit,
    onSubmit: () -> Unit,
    onCancel: () -> Unit,
) {
    val busy = sending || submitting
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 24.dp, vertical = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Top,
    ) {
        Text(
            text = "短信验证",
            style = MaterialTheme.typography.title3,
            fontWeight = FontWeight.Bold,
        )
        Spacer(Modifier.height(8.dp))
        notice?.let {
            Text(
                text = it,
                textAlign = TextAlign.Center,
                style = MaterialTheme.typography.caption1,
            )
            Spacer(Modifier.height(6.dp))
        }
        BasicTextField(
            value = code,
            onValueChange = onCodeChange,
            singleLine = true,
            textStyle = TextStyle(
                color = MaterialTheme.colors.onBackground,
                fontSize = 18.sp,
                textAlign = TextAlign.Center,
            ),
            cursorBrush = SolidColor(MaterialTheme.colors.primary),
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            decorationBox = { inner ->
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    if (code.isEmpty()) {
                        Text(
                            text = "输入验证码",
                            color = MaterialTheme.colors.onBackground.copy(alpha = 0.5f),
                            fontSize = 16.sp,
                        )
                    }
                    inner()
                }
            },
        )
        ToggleChip(
            checked = trustDevice,
            onCheckedChange = onTrustChange,
            label = { Text("信任此设备", style = MaterialTheme.typography.caption2) },
            toggleControl = {
                androidx.wear.compose.material.Checkbox(checked = trustDevice)
            },
            colors = ToggleChipDefaults.toggleChipColors(),
            modifier = Modifier.fillMaxWidth(),
        )
        error?.let {
            Text(
                text = it,
                color = MaterialTheme.colors.error,
                style = MaterialTheme.typography.caption2,
                textAlign = TextAlign.Center,
            )
        }
        Spacer(Modifier.height(8.dp))
        Button(
            onClick = onSubmit,
            enabled = !busy && code.isNotEmpty(),
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text(if (submitting) "提交中…" else "确认")
        }
        Spacer(Modifier.height(6.dp))
        Button(
            onClick = onSend,
            enabled = !busy && secondsRemaining <= 0,
            colors = ButtonDefaults.secondaryButtonColors(),
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text(
                when {
                    sending -> "发送中…"
                    secondsRemaining > 0 -> "${secondsRemaining}s 后重发"
                    else -> "重新发送"
                },
            )
        }
        Spacer(Modifier.height(4.dp))
        Button(
            onClick = onCancel,
            colors = ButtonDefaults.secondaryButtonColors(),
            modifier = Modifier.fillMaxWidth(),
        ) {
            Text("取消")
        }
    }
}
