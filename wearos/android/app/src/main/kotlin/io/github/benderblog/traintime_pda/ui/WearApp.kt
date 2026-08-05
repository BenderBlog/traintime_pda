// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui

import androidx.compose.foundation.background
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.activity.compose.BackHandler
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Colors
import io.github.benderblog.traintime_pda.ui.screens.HomeScreen
import io.github.benderblog.traintime_pda.ui.screens.PairingScreen
import io.github.benderblog.traintime_pda.ui.screens.QrScreen
import io.github.benderblog.traintime_pda.ui.screens.ReAuthScreen

private val WearColorPalette = Colors(
    primary = Color(0xFF70D6FF),
    primaryVariant = Color(0xFF38BDF2),
    secondary = Color(0xFFA7E8F0),
    secondaryVariant = Color(0xFF62CEDB),
    background = Color.Black,
    surface = Color(0xFF1C1C1E),
    error = Color(0xFFFF6B6B),
    onPrimary = Color.Black,
    onSecondary = Color.Black,
    onBackground = Color.White,
    onSurface = Color.White,
    onError = Color.Black,
)

@Composable
fun WearApp(viewModel: WearViewModel) {
    val state by viewModel.state.collectAsStateWithLifecycle()

    LaunchedEffect(Unit) {
        if (state.screen == WearScreen.PAIRING) {
            viewModel.beginPairing()
        }
    }

    BackHandler(enabled = state.screen == WearScreen.QR) {
        viewModel.closeQr()
    }
    BackHandler(enabled = state.screen == WearScreen.REAUTH) {
        viewModel.closeQr()
    }

    MaterialTheme(colors = WearColorPalette) {
        androidx.compose.foundation.layout.Box(
            modifier = Modifier.background(MaterialTheme.colors.background),
        ) {
            when (state.screen) {
                WearScreen.PAIRING -> PairingScreen(
                    starting = state.pairingStarting,
                    status = state.pairingStatus,
                )
                WearScreen.HOME -> HomeScreen(
                    data = state.homeData,
                    loading = state.homeLoading || state.syncing,
                    error = state.homeError,
                    onRefresh = viewModel::requestManualSync,
                    onLogout = viewModel::logout,
                    onOpenQr = viewModel::openQr,
                    onRetry = viewModel::requestManualSync,
                )
                WearScreen.QR -> QrScreen(
                    loading = state.qrLoading,
                    result = state.qrResult,
                    error = state.qrError,
                    onBack = viewModel::closeQr,
                    onRetry = viewModel::retryQr,
                )
                WearScreen.REAUTH -> ReAuthScreen(
                    notice = state.reAuthNotice,
                    error = state.reAuthError,
                    code = state.reAuthCode,
                    sending = state.reAuthSending,
                    submitting = state.reAuthSubmitting,
                    secondsRemaining = state.reAuthSecondsRemaining,
                    trustDevice = state.reAuthTrustDevice,
                    onCodeChange = viewModel::updateReAuthCode,
                    onTrustChange = viewModel::updateReAuthTrustDevice,
                    onSend = viewModel::sendReAuthSms,
                    onSubmit = viewModel::submitReAuth,
                    onCancel = viewModel::closeQr,
                )
            }
        }
    }
}
