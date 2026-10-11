// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.payment

import com.google.common.truth.Truth.assertThat
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class PaymentQrLoadingTest {
    private val cached = PaymentQrResult(byteArrayOf(1), true, 100L)
    private val fresh = PaymentQrResult(byteArrayOf(2), false, 200L)

    @Test
    fun openingCachedCodeDoesNotContactPhone() = runTest {
        val result = loadPaymentQr(
            forceRefresh = false,
            readCache = { cached },
            requestFromPhone = { error("Cached opening must not contact phone") },
        )
        assertThat(result).isEqualTo(cached)
    }

    @Test
    fun phoneRefreshReplacesCachedCode() = runTest {
        val result = loadPaymentQr(
            forceRefresh = true,
            readCache = { error("Refresh must request a fresh code first") },
            requestFromPhone = { fresh },
        )
        assertThat(result).isEqualTo(fresh)
    }

    @Test
    fun firstOpenWithoutCacheUsesPhone() = runTest {
        val result = loadPaymentQr(
            forceRefresh = false,
            readCache = { null },
            requestFromPhone = { fresh },
        )
        assertThat(result).isEqualTo(fresh)
    }

    @Test
    fun unavailablePhoneReturnsCacheImmediately() = runTest {
        val result = loadPaymentQr(true, { cached }, { error("phone_app_required") })
        assertThat(result.bytes).isEqualTo(cached.bytes)
        assertThat(result.refreshError).isEqualTo("请打开手机端 XDYou 后重试")
        assertThat(testScheduler.currentTime).isEqualTo(0L)
    }

    @Test
    fun phoneWaitIsBoundedAndCancelledBeforeCacheFallback() = runTest {
        var phoneCancelled = false
        val result = loadPaymentQr(true, { cached }) {
            try { awaitCancellation() } finally { phoneCancelled = true }
        }
        assertThat(phoneCancelled).isTrue()
        assertThat(result.bytes).isEqualTo(cached.bytes)
        assertThat(testScheduler.currentTime).isEqualTo(10_000L)
    }

    @Test
    fun failedRefreshPreservesOfflineCode() = runTest {
        val result = loadPaymentQr(
            forceRefresh = true,
            readCache = { cached },
            requestFromPhone = { error("Phone disconnected") },
        )
        assertThat(result.bytes).isEqualTo(cached.bytes)
        assertThat(result.fetchedAtEpochMs).isEqualTo(cached.fetchedAtEpochMs)
        assertThat(result.fromCache).isTrue()
        assertThat(result.refreshError).isEqualTo("手机刷新失败，请在手机端 XDYou 重试")
    }

    @Test
    fun unavailablePhoneRefreshTellsUserHowToRetry() = runTest {
        val result = loadPaymentQr(
            forceRefresh = true,
            readCache = { cached },
            requestFromPhone = { error("phone_app_required") },
        )
        assertThat(result.refreshError).isEqualTo("请打开手机端 XDYou 后重试")
        assertThat(result.fetchedAtEpochMs).isEqualTo(cached.fetchedAtEpochMs)
    }

    @Test
    fun backgroundCancellationDoesNotReturnCachedSuccess() = runTest {
        val job = launch {
            loadPaymentQr(
                forceRefresh = true,
                readCache = { error("Cancellation must not be reported as cached success") },
                requestFromPhone = { awaitCancellation() },
            )
        }
        runCurrent()
        job.cancel()
        job.join()
        assertThat(job.isCancelled).isTrue()
        assertThat(testScheduler.currentTime).isEqualTo(0L)
    }

}
