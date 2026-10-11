// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import io.github.benderblog.traintime_pda.WearAppContainer
import io.github.benderblog.traintime_pda.domain.WearAgendaBuilder
import io.github.benderblog.traintime_pda.domain.WearHomeData
import io.github.benderblog.traintime_pda.domain.WearAgendaDay
import io.github.benderblog.traintime_pda.payment.PaymentQrRepository
import io.github.benderblog.traintime_pda.payment.PaymentQrResult
import kotlinx.coroutines.Job
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout
import java.time.LocalDate
import java.time.DayOfWeek
import java.time.temporal.ChronoUnit
import java.time.temporal.TemporalAdjusters

enum class WearScreen {
    PAIRING,
    HOME,
    AGENDA,
    QR,
}

data class WearUiState(
    val screen: WearScreen = WearScreen.PAIRING,
    val homeData: WearHomeData = WearHomeData(emptyList(), emptyList()),
    val homeLoading: Boolean = false,
    val homeError: String? = null,
    val syncing: Boolean = false,
    val agendaWeeks: List<List<WearAgendaDay>> = emptyList(),
    val agendaInitialWeek: Int = 0,
    val agendaShowSwipeHint: Boolean = false,
    val agendaError: String? = null,
    val pairingStarting: Boolean = true,
    val pairingStatus: String = "请在手机端打开“设置 > XDYou Wear”，选择这块手表",
    val qrLoading: Boolean = false,
    val qrResult: PaymentQrResult? = null,
    val qrError: String? = null,

)

class WearViewModel(
    private val container: WearAppContainer,
) : ViewModel() {
    private val paymentRepo = PaymentQrRepository(
        cache = container.cache,
        companionClient = container.companionClient,
    )

    private val _state = MutableStateFlow(
        WearUiState(
            screen = if (container.needsPairing()) WearScreen.PAIRING else WearScreen.HOME,
        ),
    )
    val state: StateFlow<WearUiState> = _state.asStateFlow()

    private var pendingSyncJob: Job? = null
    private var qrJob: Job? = null
    private var qrFlowGeneration = 0L

    init {
        if (!container.needsPairing()) {
            refreshHome()
        }
        viewModelScope.launch {
            container.companionClient.imports.collect {
                onImportReceived()
            }
        }
    }

    fun onForeground() {
        container.companionClient.startListening()

    }

    fun onBackground() {
        container.companionClient.stopListening()
        pendingSyncJob?.cancel()
        if (_state.value.screen == WearScreen.QR &&
            (_state.value.qrLoading || _state.value.qrResult == null)
        ) {
            qrFlowGeneration++
            cancelActiveQrWork()
            _state.update {
                it.copy(
                    screen = WearScreen.QR,
                    qrLoading = false,
                    qrError = "操作已暂停，请下拉刷新后重试",
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

    fun openAgenda() {
        try {
            val table = container.cache.readClassTable()
            val experiments = container.cache.readExperiments()
            val currentWeek = LocalDate.now().with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY))
            val termStart = table?.termStartDay?.let { raw ->
                runCatching { LocalDate.parse(raw.take(10)) }.getOrNull()
            }
            val start = termStart?.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY)) ?: currentWeek
            val weekCount = if (termStart != null) table.semesterLength.coerceAtLeast(1) else 1
            val weeks = (0 until weekCount).map { week ->
                WearAgendaBuilder.loadWeekData(
                    semesterCode = container.preferences.currentSemester,
                    classTable = table,
                    experiments = experiments,
                    weekStart = start.plusWeeks(week.toLong()),
                )
            }
            val initialWeek = ChronoUnit.WEEKS.between(start, currentWeek).toInt().coerceIn(0, weeks.lastIndex)
            val showSwipeHint = !container.preferences.agendaSwipeHintShown
            container.preferences.agendaSwipeHintShown = true
            _state.update {
                it.copy(
                    screen = WearScreen.AGENDA,
                    agendaWeeks = weeks,
                    agendaInitialWeek = initialWeek,
                    agendaShowSwipeHint = showSwipeHint,
                    agendaError = null,
                )
            }
        } catch (_: Exception) {
            _state.update {
                it.copy(screen = WearScreen.AGENDA, agendaWeeks = emptyList(), agendaError = "无法读取日程，请返回首页下拉同步")
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
                        val wait = async(start = CoroutineStart.UNDISPATCHED) {
                            container.companionClient.imports.first()
                        }
                        container.companionClient.requestCompanionSync()
                        wait.await()
                    }
                }
            } catch (_: TimeoutCancellationException) {
                _state.update { it.copy(homeError = "同步超时，请确认手机已连接") }
            } catch (cancelled: CancellationException) {
                throw cancelled
            } catch (e: Exception) {
                // Keep previous cache; surface a soft error while offline data remains usable.
                _state.update {
                    it.copy(homeError = e.message ?: "同步失败")
                }
            } finally {
                _state.update { it.copy(syncing = false) }
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

    fun showAgenda() {
        if (container.needsPairing()) return
        closeQr()
        refreshHome()
    }

    fun retryQr() {
        val flowId = startNewQrFlow()
        _state.update {
            it.copy(
                qrLoading = true,
                qrError = null,
            )
        }
        loadQr(flowId, forceRefresh = true)
    }

    private fun loadQr(flowId: Long, forceRefresh: Boolean) {
        qrJob = viewModelScope.launch {
            try {
                val result = paymentRepo.load(forceRefresh = forceRefresh)
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

    private fun startNewQrFlow(): Long {
        cancelActiveQrWork()
        qrFlowGeneration++
        return qrFlowGeneration
    }

    private fun isQrFlowActive(flowId: Long): Boolean =
        qrFlowGeneration == flowId &&
            _state.value.screen == WearScreen.QR

    private fun cancelActiveQrWork() {
        val cancellation = CancellationException("付款码页面已关闭")
        qrJob?.cancel(cancellation)
        qrJob = null

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
