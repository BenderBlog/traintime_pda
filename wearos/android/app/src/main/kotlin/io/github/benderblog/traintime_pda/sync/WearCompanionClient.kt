// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.sync

import android.content.Context
import android.util.Log
import com.google.android.gms.wearable.MessageClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import io.github.benderblog.traintime_pda.data.WearSyncImporter
import io.github.benderblog.traintime_pda.protocol.WearCompanionPaths
import io.github.benderblog.traintime_pda.protocol.WearCompanionSyncEnvelope
import io.github.benderblog.traintime_pda.protocol.WearPaymentQrResponse
import kotlinx.coroutines.async
import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withTimeout
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Wear Data Layer client. Listens only while the activity is in the foreground
 * (registered/unregistered from the Activity lifecycle) to avoid resident listeners.
 */
class WearCompanionClient(
    context: Context,
    private val importer: WearSyncImporter,
) : MessageClient.OnMessageReceivedListener {
    private val appContext = context.applicationContext
    private val messageClient: MessageClient = Wearable.getMessageClient(appContext)

    private val _imports = MutableSharedFlow<WearCompanionSyncEnvelope>(
        extraBufferCapacity = 4,
        onBufferOverflow = BufferOverflow.DROP_OLDEST,
    )
    val imports: SharedFlow<WearCompanionSyncEnvelope> = _imports.asSharedFlow()

    private val _paymentResponses = MutableSharedFlow<WearPaymentQrResponse>(
        extraBufferCapacity = 2,
        onBufferOverflow = BufferOverflow.DROP_OLDEST,
    )
    val paymentResponses: SharedFlow<WearPaymentQrResponse> = _paymentResponses.asSharedFlow()

    @Volatile
    private var directPairingExpiresAtEpochMs: Long = 0

    @Volatile
    private var pendingSyncPayload: String? = null
    private val listening = AtomicBoolean(false)

    fun beginDirectPairing(): Long {
        directPairingExpiresAtEpochMs =
            System.currentTimeMillis() + WearCompanionPaths.DIRECT_PAIRING_TTL_MS
        return directPairingExpiresAtEpochMs
    }

    fun isCompanionPaired(): Boolean = pairedPhoneNodeId() != null

    fun startListening() {
        if (!listening.compareAndSet(false, true)) return
        messageClient.addListener(this)
        pendingSyncPayload?.let { payload ->
            pendingSyncPayload = null
            handleSyncPayload(payload, pairedPhoneNodeId())
        }
    }

    fun stopListening() {
        if (!listening.compareAndSet(true, false)) return
        messageClient.removeListener(this)
    }

    suspend fun requestCompanionSync() {
        val nodeId = pairedPhoneNodeId()
            ?: throw IllegalStateException("No companion phone is paired")
        messageClient.sendMessage(nodeId, WearCompanionPaths.REQUEST, ByteArray(0)).await()
    }

    suspend fun requestPaymentQrFromPhone(timeoutMs: Long = 20_000L): WearPaymentQrResponse {
        val nodeId = pairedPhoneNodeId()
            ?: throw IllegalStateException("No companion phone is paired")
        return withTimeout(timeoutMs) {
            coroutineScope {
                // Subscribe before send to avoid missing a fast response.
                val deferred = async { paymentResponses.first() }
                messageClient
                    .sendMessage(nodeId, WearCompanionPaths.PAYMENT_REQUEST, ByteArray(0))
                    .await()
                deferred.await()
            }
        }
    }

    override fun onMessageReceived(event: MessageEvent) {
        when (event.path) {
            WearCompanionPaths.PAYMENT_RESPONSE -> {
                if (event.sourceNodeId != pairedPhoneNodeId()) return
                val payload = event.data.toString(Charsets.UTF_8)
                val response = try {
                    WearPaymentQrResponse.decode(payload)
                } catch (e: Exception) {
                    Log.w(TAG, "Invalid payment response", e)
                    WearPaymentQrResponse(ok = false, error = "invalid_payment_qr_response")
                }
                _paymentResponses.tryEmit(response)
            }
            WearCompanionPaths.SYNC -> {
                val payload = event.data.toString(Charsets.UTF_8)
                if (!isActiveSyncPayload(payload, event.sourceNodeId)) return
                handleSyncPayload(payload, event.sourceNodeId)
            }
        }
    }

    private fun handleSyncPayload(payload: String, sourceNodeId: String?) {
        try {
            val envelope = WearCompanionSyncEnvelope.decode(payload)
            importer.importEnvelope(envelope, payload)
            sourceNodeId?.let { nodeId ->
                rememberPairedPhone(nodeId)
                messageClient.sendMessage(
                    nodeId,
                    WearCompanionPaths.SYNC_ACK,
                    envelope.sessionId.toByteArray(Charsets.UTF_8),
                ).addOnFailureListener { error ->
                    Log.w(TAG, "Failed to acknowledge sync", error)
                }
            }
            clearActiveSyncSession()
            _imports.tryEmit(envelope)
        } catch (e: Exception) {
            Log.w(TAG, "Failed to import sync payload", e)
            // Keep payload for a later retry only when channel was unavailable in Flutter;
            // with native import we surface failure by not emitting.
        }
    }

    private fun isActiveSyncPayload(payload: String, sourceNodeId: String): Boolean {
        return try {
            val json = org.json.JSONObject(payload)
            if (json.optInt("schemaVersion") != WearCompanionPaths.SCHEMA_VERSION) return false
            val paired = pairedPhoneNodeId()
            if (paired != null) return paired == sourceNodeId
            json.optBoolean("directPairing", false) &&
                (listening.get() || System.currentTimeMillis() <= directPairingExpiresAtEpochMs)
        } catch (_: Exception) {
            false
        }
    }

    private fun rememberPairedPhone(nodeId: String) {
        appContext.getSharedPreferences(WearCompanionPaths.PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(WearCompanionPaths.PAIRED_PHONE_NODE_ID, nodeId)
            .apply()
    }

    fun pairedPhoneNodeId(): String? =
        appContext.getSharedPreferences(WearCompanionPaths.PREFS, Context.MODE_PRIVATE)
            .getString(WearCompanionPaths.PAIRED_PHONE_NODE_ID, null)

    fun clearPairedPhone() {
        appContext.getSharedPreferences(WearCompanionPaths.PREFS, Context.MODE_PRIVATE)
            .edit()
            .remove(WearCompanionPaths.PAIRED_PHONE_NODE_ID)
            .apply()
    }

    private fun clearActiveSyncSession() {
        directPairingExpiresAtEpochMs = 0
        pendingSyncPayload = null
    }

    companion object {
        private const val TAG = "WearCompanionClient"
    }
}
