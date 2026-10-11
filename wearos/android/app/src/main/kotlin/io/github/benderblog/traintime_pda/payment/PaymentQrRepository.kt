// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.payment

import io.github.benderblog.traintime_pda.data.WearCacheStore
import io.github.benderblog.traintime_pda.sync.WearCompanionClient
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull

data class PaymentQrResult(
    val bytes: ByteArray,
    val fromCache: Boolean,
    val fetchedAtEpochMs: Long,
    val refreshError: String? = null,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is PaymentQrResult) return false
        return fromCache == other.fromCache &&
            refreshError == other.refreshError &&
            fetchedAtEpochMs == other.fetchedAtEpochMs &&
            bytes.contentEquals(other.bytes)
    }

    override fun hashCode(): Int {
        var result = bytes.contentHashCode()
        result = 31 * result + fromCache.hashCode()
        result = 31 * result + fetchedAtEpochMs.hashCode()
        result = 31 * result + (refreshError?.hashCode() ?: 0)
        return result
    }
}

/** Payment codes are refreshed by the paired phone; the watch only stores images. */
class PaymentQrRepository(
    private val cache: WearCacheStore,
    private val companionClient: WearCompanionClient,
) {
    suspend fun load(forceRefresh: Boolean = false): PaymentQrResult = withContext(Dispatchers.IO) {
        loadPaymentQr(
            forceRefresh = forceRefresh,
            readCache = {
                cache.readPaymentQr()?.let { (bytes, fetchedAt) ->
                    PaymentQrResult(bytes, fromCache = true, fetchedAtEpochMs = fetchedAt)
                }
            },
            requestFromPhone = {
                val response = companionClient.requestPaymentQrFromPhone()
                if (!response.ok || response.pngBytes == null || response.fetchedAtEpochMs == null) {
                    throw IllegalStateException(response.error ?: "phone_payment_request_failed")
                }
                cache.writePaymentQr(response.pngBytes, response.fetchedAtEpochMs)
                PaymentQrResult(response.pngBytes, false, response.fetchedAtEpochMs)
            },
        )
    }
}

internal suspend fun loadPaymentQr(
    forceRefresh: Boolean,
    readCache: () -> PaymentQrResult?,
    requestFromPhone: suspend () -> PaymentQrResult,
): PaymentQrResult {
    currentCoroutineContext().ensureActive()
    if (!forceRefresh) readCache()?.let { return it }
    return try {
        withTimeoutOrNull(10_000L) { requestFromPhone() }
            ?: throw IllegalStateException("phone_timeout")
    } catch (cancelled: CancellationException) {
        throw cancelled
    } catch (error: Exception) {
        currentCoroutineContext().ensureActive()
        val message = when (error.message) {
            "phone_authentication_required", "phone_authentication_cancelled" -> "请在手机端 XDYou 完成认证后重试"
            "phone_app_required" -> "请打开手机端 XDYou 后重试"
            "phone_timeout" -> "手机响应超时，请打开手机端 XDYou 后重试"
            "Companion phone is disconnected", "No companion phone is paired" -> "请连接手机并打开 XDYou 后重试"
            else -> "手机刷新失败，请在手机端 XDYou 重试"
        }
        readCache()?.copy(refreshError = message) ?: throw IllegalStateException(message)
    }
}
