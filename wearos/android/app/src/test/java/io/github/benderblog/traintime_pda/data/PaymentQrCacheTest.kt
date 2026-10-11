// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.data

import com.google.common.truth.Truth.assertThat
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

class PaymentQrCacheTest {
    @get:Rule
    val tempFolder = TemporaryFolder()

    @Test
    fun scheduleSyncCannotReplaceFreshWatchCodeWithOlderPhoneSnapshot() {
        val cache = WearCacheStore(tempFolder.root)
        cache.writePaymentQr(byteArrayOf(2), 2_000L)
        cache.writePaymentQr(byteArrayOf(1), 1_000L)
        val stored = cache.readPaymentQr()!!
        assertThat(stored.first).isEqualTo(byteArrayOf(2))
        assertThat(stored.second).isEqualTo(2_000L)
    }

    @Test
    fun newPhoneCodeStillUpdatesExistingWatchCache() {
        val cache = WearCacheStore(tempFolder.root)
        cache.writePaymentQr(byteArrayOf(1), 1_000L)
        cache.writePaymentQr(byteArrayOf(2), 2_000L)
        val stored = cache.readPaymentQr()!!
        assertThat(stored.first).isEqualTo(byteArrayOf(2))
        assertThat(stored.second).isEqualTo(2_000L)
    }

    @Test
    fun clearedAccountCacheDoesNotBlockFirstCodeForNewAccount() {
        val cache = WearCacheStore(tempFolder.root)
        cache.writePaymentQr(byteArrayOf(1), 2_000L)
        cache.clearPaymentQr()
        cache.writePaymentQr(byteArrayOf(2), 1_000L)
        assertThat(cache.readPaymentQr()!!.first).isEqualTo(byteArrayOf(2))
    }
}
