package io.github.benderblog.traintime_pda

import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import com.google.android.gms.wearable.MessageClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity(), MessageClient.OnMessageReceivedListener {
    private var syncChannel: MethodChannel? = null
    private var paymentChannel: MethodChannel? = null
    private var pendingSyncPayload: String? = null
    private var directPairingExpiresAtEpochMs: Long = 0
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        syncChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WEAR_COMPANION_SYNC_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "beginDirectPairing" -> beginDirectPairing(result)
                    "isCompanionPaired" -> result.success(pairedPhoneNodeId() != null)
                    "setKeepScreenOn" -> {
                        val enabled = call.arguments as? Boolean ?: false
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        }
                        result.success(null)
                    }
                    "readPendingSyncPayload" -> readPendingSyncPayload(result)
                    "requestCompanionSync" -> requestCompanionSync(result)
                    else -> result.notImplemented()
                }
            }
        }
        paymentChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WEAR_PAYMENT_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPaymentQr" -> requestPaymentQr(result)
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        Wearable.getMessageClient(this).addListener(this)
    }

    override fun onPause() {
        Wearable.getMessageClient(this).removeListener(this)
        super.onPause()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        syncChannel?.setMethodCallHandler(null)
        syncChannel = null
        paymentChannel?.setMethodCallHandler(null)
        paymentChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private fun beginDirectPairing(result: MethodChannel.Result) {
        directPairingExpiresAtEpochMs = System.currentTimeMillis() + SYNC_SESSION_TTL_MS
        result.success(directPairingExpiresAtEpochMs)
    }

    private fun readPendingSyncPayload(result: MethodChannel.Result) {
        val payload = pendingSyncPayload
        pendingSyncPayload = null
        result.success(payload)
    }

    override fun onMessageReceived(event: MessageEvent) {
        if (event.path == WEAR_PAYMENT_RESPONSE_PATH) {
            if (event.sourceNodeId != pairedPhoneNodeId()) return
            val payload = event.data.toString(Charsets.UTF_8)
            mainHandler.post {
                paymentChannel?.invokeMethod("receivePaymentQrResponse", payload)
            }
            return
        }
        if (event.path != WEAR_COMPANION_SYNC_MESSAGE_PATH) return
        val payload = event.data.toString(Charsets.UTF_8)
        if (!isActiveSyncPayload(payload, event.sourceNodeId)) return
        val channel = syncChannel
        if (channel == null) {
            rememberPairedPhone(event.sourceNodeId)
            pendingSyncPayload = payload
            return
        }
        mainHandler.post {
            val currentChannel = syncChannel
            if (currentChannel == null) {
                rememberPairedPhone(event.sourceNodeId)
                pendingSyncPayload = payload
            } else {
                currentChannel.invokeMethod(
                    "receiveSyncPayload",
                    payload,
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            rememberPairedPhone(event.sourceNodeId)
                            clearActiveSyncSession()
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?,
                        ) {
                            // Keep the active session until expiry so the phone can retry.
                        }

                        override fun notImplemented() {
                            pendingSyncPayload = payload
                        }
                    },
                )
            }
        }
    }

    private fun isActiveSyncPayload(payload: String, sourceNodeId: String): Boolean {
        return try {
            val json = JSONObject(payload)
            if (json.optInt("schemaVersion") != 1) return false
            val pairedNodeId = pairedPhoneNodeId()
            if (pairedNodeId != null) return pairedNodeId == sourceNodeId
            System.currentTimeMillis() <= directPairingExpiresAtEpochMs &&
                json.optBoolean("directPairing", false)
        } catch (_: Exception) {
            false
        }
    }

    private fun requestCompanionSync(result: MethodChannel.Result) {
        val nodeId = pairedPhoneNodeId()
        if (nodeId == null) {
            result.error("not_paired", "No companion phone is paired", null)
            return
        }
        Wearable.getMessageClient(this)
            .sendMessage(nodeId, WEAR_COMPANION_REQUEST_PATH, ByteArray(0))
            .addOnSuccessListener { result.success(null) }
            .addOnFailureListener { error ->
                result.error("request_failed", error.message, null)
            }
    }

    private fun requestPaymentQr(result: MethodChannel.Result) {
        val nodeId = pairedPhoneNodeId()
        if (nodeId == null) {
            result.error("not_paired", "No companion phone is paired", null)
            return
        }
        Wearable.getMessageClient(this)
            .sendMessage(nodeId, WEAR_PAYMENT_REQUEST_PATH, ByteArray(0))
            .addOnSuccessListener { result.success(null) }
            .addOnFailureListener { error ->
                result.error("request_failed", error.message, null)
            }
    }

    private fun rememberPairedPhone(nodeId: String) {
        getSharedPreferences(WEAR_COMPANION_PREFS, MODE_PRIVATE)
            .edit().putString(PAIRED_PHONE_NODE_ID, nodeId).apply()
    }

    private fun pairedPhoneNodeId(): String? =
        getSharedPreferences(WEAR_COMPANION_PREFS, MODE_PRIVATE)
            .getString(PAIRED_PHONE_NODE_ID, null)

    private fun clearActiveSyncSession() {
        directPairingExpiresAtEpochMs = 0
        pendingSyncPayload = null
    }

    companion object {
        private const val WEAR_COMPANION_SYNC_CHANNEL =
            "io.github.benderblog.traintime_pda/wear_companion_sync"
        private const val WEAR_PAYMENT_CHANNEL =
            "io.github.benderblog.traintime_pda/wear_payment"
        private const val WEAR_COMPANION_SYNC_MESSAGE_PATH =
            "/traintime_pda_wear_os/sync/v1"
        private const val WEAR_COMPANION_REQUEST_PATH =
            "/traintime_pda_wear_os/request/v1"
        private const val WEAR_PAYMENT_REQUEST_PATH =
            "/traintime_pda_wear_os/payment/request/v1"
        private const val WEAR_PAYMENT_RESPONSE_PATH =
            "/traintime_pda_wear_os/payment/response/v1"
        private const val WEAR_COMPANION_PREFS = "wear_companion_transport"
        private const val PAIRED_PHONE_NODE_ID = "paired_phone_node_id"
        private const val SYNC_SESSION_TTL_MS = 5 * 60 * 1000L
    }
}
