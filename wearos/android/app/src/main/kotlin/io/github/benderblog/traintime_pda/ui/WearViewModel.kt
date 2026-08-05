// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import io.github.benderblog.traintime_pda.WearAppContainer
import io.github.benderblog.traintime_pda.domain.WearAgendaBuilder
import io.github.benderblog.traintime_pda.domain.WearHomeData
import io.github.benderblog.traintime_pda.ids.IdsLoginState
import io.github.benderblog.traintime_pda.ids.WearIDSReAuthClient
import io.github.benderblog.traintime_pda.payment.PaymentQrRepository
import io.github.benderblog.traintime_pda.payment.PaymentQrResult
import kotlinx.coroutines.Job
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout
import kotlinx.coroutines.withContext
import java.net.URI
import kotlin.coroutines.resume

enum class WearScreen {
    PAIRING,
    HOME,
    QR,
    REAUTH,
}

data class WearUiState(
    val screen: WearScreen = WearScreen.PAIRING,
    val homeData: WearHomeData = WearHomeData(emptyList(), emptyList()),
    val homeLoading: Boolean = false,
    val homeError: String? = null,
    val syncing: Boolean = false,
    val pairingStarting: Boolean = true,
    val pairingStatus: String = "请在手机端打开“设置 > XDYou Wear”，选择这块手表",
    val qrLoading: Boolean = false,
    val qrResult: PaymentQrResult? = null,
    val qrError: String? = null,
    val reAuthClient: WearIDSReAuthClient? = null,
    val reAuthNotice: String? = null,
    val reAuthError: String? = null,
    val reAuthSending: Boolean = false,
    val reAuthSubmitting: Boolean = false,
    val reAuthSecondsRemaining: Int = 0,
    val reAuthTrustDevice: Boolean = true,
    val reAuthCode: String = "",
)

class WearViewModel(
    private val container: WearAppContainer,
) : ViewModel() {
    private val paymentRepo = PaymentQrRepository(
        preferences = container.preferences,
        cache = container.cache,
        companionClient = container.companionClient,
    )

    private val _state = MutableStateFlow(
        WearUiState(
            screen = if (container.needsPairing()) WearScreen.PAIRING else WearScreen.HOME,
        ),
    )
    val state: StateFlow<WearUiState> = _state.asStateFlow()

    private var reAuthContinuation: kotlinx.coroutines.CancellableContinuation<URI>? = null
    private var countdownJob: Job? = null
    private var reAuthSendJob: Job? = null
    private var reAuthSubmitJob: Job? = null
    private var pendingSyncJob: Job? = null
    private var qrJob: Job? = null
    private var qrFlowGeneration = 0L
    private var activeReAuthGeneration: Long? = null
    private var bootstrapSyncRequested = false

    init {
        if (!container.needsPairing()) {
            IdsLoginState.state = IdsLoginState.State.NONE
            refreshHome()
        } else {
            IdsLoginState.state = IdsLoginState.State.MANUAL
        }
        viewModelScope.launch {
            container.companionClient.imports.collect {
                onImportReceived()
            }
        }
    }

    fun onForeground() {
        container.companionClient.startListening()
        if (!container.needsPairing() &&
            !container.preferences.hasPaymentCredentials() &&
            !bootstrapSyncRequested
        ) {
            bootstrapSyncRequested = true
            requestManualSync()
        }
    }

    fun onBackground() {
        container.companionClient.stopListening()
        if ((_state.value.screen == WearScreen.QR ||
                _state.value.screen == WearScreen.REAUTH) &&
            _state.value.qrResult == null
        ) {
            qrFlowGeneration++
            cancelActiveQrWork()
            _state.update {
                it.copy(
                    screen = WearScreen.QR,
                    qrLoading = false,
                    qrError = "操作已暂停，请下拉刷新后重试",
                    reAuthClient = null,
                    reAuthNotice = null,
                    reAuthError = null,
                    reAuthSending = false,
                    reAuthSubmitting = false,
                    reAuthSecondsRemaining = 0,
                    reAuthCode = "",
                )
            }
        }
    }

    fun beginPairing() {
        viewModelScope.launch {
            _state.update {
                it.copy(
                    screen = WearScreen.PAIRING,
                    pairingStarting = true,
                    pairingStatus = "请在手机端打开“设置 > XDYou Wear”，选择这块手表",
                )
            }
            try {
                container.companionClient.beginDirectPairing()
                _state.update { it.copy(pairingStarting = false) }
            } catch (e: Exception) {
                _state.update {
                    it.copy(
                        pairingStarting = false,
                        pairingStatus = "无法开始配对：${e.message ?: e}",
                    )
                }
            }
        }
    }

    private fun onImportReceived() {
        _state.update {
            it.copy(
                screen = WearScreen.HOME,
                homeError = null,
                syncing = false,
            )
        }
        refreshHome()
    }

    fun refreshHome() {
        viewModelScope.launch {
            _state.update { it.copy(homeLoading = true, homeError = null) }
            try {
                val data = WearAgendaBuilder.loadHomeData(
                    semesterCode = container.preferences.currentSemester,
                    classTable = container.cache.readClassTable(),
                    experiments = container.cache.readExperiments(),
                )
                _state.update {
                    it.copy(homeData = data, homeLoading = false, homeError = null)
                }
            } catch (e: Exception) {
                _state.update {
                    it.copy(
                        homeLoading = false,
                        homeError = e.message ?: e.toString(),
                    )
                }
            }
        }
    }

    fun requestManualSync() {
        if (pendingSyncJob?.isActive == true) return
        pendingSyncJob = viewModelScope.launch {
            _state.update { it.copy(syncing = true, homeError = null) }
            try {
                withTimeout(15_000L) {
                    coroutineScope {
                        val wait = async { container.companionClient.imports.first() }
                        container.companionClient.requestCompanionSync()
                        wait.await()
                    }
                }
            } catch (e: Exception) {
                // Keep previous cache; surface a soft error while offline data remains usable.
                _state.update {
                    it.copy(homeError = e.message ?: "同步失败")
                }
            } finally {
                _state.update { it.copy(syncing = false) }
                refreshHome()
            }
        }
    }

    fun logout() {
        container.importer.logout()
        container.companionClient.clearPairedPhone()
        _state.update {
            WearUiState(
                screen = WearScreen.PAIRING,
                pairingStarting = true,
                pairingStatus = "请在手机端打开“设置 > XDYou Wear”，选择这块手表",
            )
        }
        beginPairing()
    }

    fun openQr() {
        val flowId = startNewQrFlow()
        _state.update {
            it.copy(
                screen = WearScreen.QR,
                qrLoading = true,
                qrResult = null,
                qrError = null,
            )
        }
        loadQr(flowId, forceRefresh = false)
    }

    fun closeQr() {
        qrFlowGeneration++
        cancelActiveQrWork()
        _state.update {
            it.copy(
                screen = WearScreen.HOME,
                qrLoading = false,
                qrResult = null,
                qrError = null,
            )
        }
    }

    fun retryQr() {
        val flowId = startNewQrFlow()
        _state.update {
            it.copy(
                qrLoading = true,
                qrResult = null,
                qrError = null,
            )
        }
        loadQr(flowId, forceRefresh = true)
    }

    private fun loadQr(flowId: Long, forceRefresh: Boolean) {
        qrJob = viewModelScope.launch {
            try {
                val result = paymentRepo.load(
                    forceRefresh = forceRefresh,
                    reAuthHandler = { client ->
                        currentCoroutineContext().ensureActive()
                        if (!isQrFlowActive(flowId)) {
                            throw CancellationException("付款码流程已失效")
                        }
                        awaitReAuth(client, flowId)
                    },
                )
                ensureActive()
                if (!isQrFlowActive(flowId)) return@launch
                _state.update {
                    it.copy(
                        qrLoading = false,
                        qrResult = result,
                        qrError = null,
                    )
                }
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (e: Exception) {
                if (!isQrFlowActive(flowId)) return@launch
                _state.update {
                    it.copy(
                        qrLoading = false,
                        qrResult = null,
                        qrError = e.message ?: "付款码获取失败",
                    )
                }
            }
        }
    }

    private suspend fun awaitReAuth(client: WearIDSReAuthClient, flowId: Long): URI {
        currentCoroutineContext().ensureActive()
        if (!isQrFlowActive(flowId)) throw CancellationException("付款码流程已失效")
        return kotlinx.coroutines.suspendCancellableCoroutine { cont ->
            if (!isQrFlowActive(flowId)) {
                cont.cancel(CancellationException("付款码流程已失效"))
                return@suspendCancellableCoroutine
            }
            reAuthContinuation?.cancel(CancellationException("短信认证已被新请求替代"))
            reAuthContinuation = cont
            activeReAuthGeneration = flowId
            _state.update {
                it.copy(
                    screen = WearScreen.REAUTH,
                    reAuthClient = client,
                    reAuthNotice = null,
                    reAuthError = null,
                    reAuthCode = "",
                    reAuthSending = false,
                    reAuthSubmitting = false,
                    reAuthSecondsRemaining = 0,
                    reAuthTrustDevice = true,
                )
            }
            sendReAuthSms()
            cont.invokeOnCancellation {
                if (reAuthContinuation === cont) reAuthContinuation = null
            }
        }
    }

    fun sendReAuthSms() {
        val flowId = activeReAuthGeneration ?: return
        if (!isQrFlowActive(flowId)) return
        val client = _state.value.reAuthClient ?: return
        if (_state.value.reAuthSending || _state.value.reAuthSecondsRemaining > 0) return
        reAuthSendJob?.cancel()
        reAuthSendJob = viewModelScope.launch {
            _state.update { it.copy(reAuthSending = true, reAuthError = null) }
            try {
                val delivery = withContext(Dispatchers.IO) { client.sendSms() }
                ensureActive()
                if (!isQrFlowActive(flowId)) return@launch
                val notice = if (delivery.recipient == null) {
                    delivery.message
                } else {
                    "${delivery.message}\n${delivery.recipient}"
                }
                _state.update { it.copy(reAuthNotice = notice) }
                startCountdown(delivery.retryAfterSeconds, flowId)
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (e: Exception) {
                if (!isQrFlowActive(flowId)) return@launch
                _state.update {
                    it.copy(reAuthError = e.message ?: "短信验证码发送失败")
                }
            } finally {
                if (isQrFlowActive(flowId) && _state.value.screen == WearScreen.REAUTH) {
                    _state.update { it.copy(reAuthSending = false) }
                }
            }
        }
    }

    private fun startCountdown(seconds: Int, flowId: Long) {
        if (!isQrFlowActive(flowId)) return
        countdownJob?.cancel()
        _state.update { it.copy(reAuthSecondsRemaining = seconds.coerceAtLeast(0)) }
        if (seconds <= 0) return
        countdownJob = viewModelScope.launch {
            var remaining = seconds
            while (remaining > 0) {
                kotlinx.coroutines.delay(1_000L)
                if (!isQrFlowActive(flowId)) return@launch
                remaining--
                _state.update { it.copy(reAuthSecondsRemaining = remaining) }
            }
        }
    }

    fun updateReAuthCode(code: String) {
        _state.update { it.copy(reAuthCode = code.filter { ch -> ch.isDigit() }.take(8)) }
    }

    fun updateReAuthTrustDevice(trust: Boolean) {
        _state.update { it.copy(reAuthTrustDevice = trust) }
    }

    fun submitReAuth() {
        val flowId = activeReAuthGeneration ?: return
        if (!isQrFlowActive(flowId)) return
        val client = _state.value.reAuthClient ?: return
        val code = _state.value.reAuthCode.trim()
        if (code.isEmpty()) {
            _state.update { it.copy(reAuthError = "请输入短信验证码") }
            return
        }
        if (_state.value.reAuthSubmitting) return
        reAuthSubmitJob?.cancel()
        reAuthSubmitJob = viewModelScope.launch {
            _state.update { it.copy(reAuthSubmitting = true, reAuthError = null) }
            try {
                val uri = withContext(Dispatchers.IO) {
                    client.submitSms(code, _state.value.reAuthTrustDevice)
                }
                ensureActive()
                if (!isQrFlowActive(flowId)) return@launch
                val cont = reAuthContinuation
                reAuthContinuation = null
                activeReAuthGeneration = null
                _state.update {
                    it.copy(
                        screen = WearScreen.QR,
                        reAuthClient = null,
                        reAuthSubmitting = false,
                    )
                }
                cont?.resume(uri)
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (e: Exception) {
                if (!isQrFlowActive(flowId)) return@launch
                _state.update {
                    it.copy(
                        reAuthSubmitting = false,
                        reAuthError = e.message ?: "验证失败",
                        reAuthCode = "",
                    )
                }
            }
        }
    }

    private fun startNewQrFlow(): Long {
        cancelActiveQrWork()
        qrFlowGeneration++
        return qrFlowGeneration
    }

    private fun isQrFlowActive(flowId: Long): Boolean =
        qrFlowGeneration == flowId &&
            (_state.value.screen == WearScreen.QR || _state.value.screen == WearScreen.REAUTH)

    private fun cancelActiveQrWork() {
        val cancellation = CancellationException("付款码页面已关闭")
        qrJob?.cancel(cancellation)
        qrJob = null
        paymentRepo.cancelActiveRequests()
        reAuthSendJob?.cancel(cancellation)
        reAuthSendJob = null
        reAuthSubmitJob?.cancel(cancellation)
        reAuthSubmitJob = null
        countdownJob?.cancel(cancellation)
        countdownJob = null
        val cont = reAuthContinuation
        reAuthContinuation = null
        activeReAuthGeneration = null
        cont?.cancel(cancellation)
    }

    override fun onCleared() {
        qrFlowGeneration++
        cancelActiveQrWork()
        container.companionClient.stopListening()
        super.onCleared()
    }

    class Factory(private val container: WearAppContainer) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(WearViewModel::class.java)) {
                return WearViewModel(container) as T
            }
            throw IllegalArgumentException("Unknown ViewModel: ${modelClass.name}")
        }
    }
}
