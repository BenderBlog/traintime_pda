// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import io.github.benderblog.traintime_pda.ui.WearApp
import io.github.benderblog.traintime_pda.ui.WearScreen
import io.github.benderblog.traintime_pda.ui.WearViewModel
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    private val container by lazy { WearAppContainer(this) }

    private val viewModel: WearViewModel by viewModels {
        WearViewModel.Factory(container)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val lifecycleOwner = LocalLifecycleOwner.current
            val state by viewModel.state.collectAsStateWithLifecycle()

            DisposableEffect(lifecycleOwner) {
                val observer = LifecycleEventObserver { _, event ->
                    when (event) {
                        Lifecycle.Event.ON_RESUME -> viewModel.onForeground()
                        Lifecycle.Event.ON_PAUSE -> viewModel.onBackground()
                        else -> Unit
                    }
                }
                lifecycleOwner.lifecycle.addObserver(observer)
                onDispose {
                    lifecycleOwner.lifecycle.removeObserver(observer)
                    viewModel.onBackground()
                }
            }

            LaunchedEffect(state.screen, state.qrResult) {
                // Give scanners enough time to read the code without allowing an
                // accidentally abandoned QR screen to keep the watch awake forever.
                val keepOn = state.screen == WearScreen.QR && state.qrResult != null
                if (keepOn) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    try {
                        delay(QR_SCREEN_ON_TIMEOUT_MS)
                    } finally {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                }
            }

            WearApp(viewModel = viewModel)
        }
    }

    private companion object {
        const val QR_SCREEN_ON_TIMEOUT_MS = 60_000L
    }
}
