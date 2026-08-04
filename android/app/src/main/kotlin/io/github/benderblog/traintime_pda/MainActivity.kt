package io.github.benderblog.traintime_pda

import android.os.Bundle
import androidx.core.view.WindowCompat
import com.google.android.gms.wearable.MessageClient
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity(), MessageClient.OnMessageReceivedListener {
    private var companionChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge display
        WindowCompat.enableEdgeToEdge(window)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        companionChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WearCompanionTransport.CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                "getConnectedWearNodes" -> {
                    Wearable.getNodeClient(this).connectedNodes
                        .addOnSuccessListener { nodes ->
                            val pairedNodeId = WearCompanionTransport.pairedWatchNodeId(this)
                            result.success(nodes.map { node ->
                                mapOf(
                                    "id" to node.id,
                                    "name" to node.displayName,
                                    "isNearby" to node.isNearby,
                                    "isPaired" to (node.id == pairedNodeId),
                                )
                            })
                        }
                        .addOnFailureListener { error ->
                            result.error("nodes_unavailable", error.message, null)
                        }
                }
                "sendSyncPayload" -> {
                    val nodeId = call.argument<String>("nodeId")
                    val path = call.argument<String>("messagePath")
                    val payload = call.argument<String>("payload")
                    if (nodeId.isNullOrBlank() ||
                        path != WearCompanionTransport.SYNC_PATH ||
                        payload.isNullOrBlank()
                    ) {
                        result.error("invalid_arguments", "Invalid Wear sync request", null)
                        return@setMethodCallHandler
                    }
                    WearCompanionTransport.cachePayload(this, payload)
                    Wearable.getMessageClient(this)
                        .sendMessage(nodeId, path, payload.toByteArray(Charsets.UTF_8))
                        .addOnSuccessListener {
                            WearCompanionTransport.rememberPairedWatch(this, nodeId)
                            result.success(null)
                        }
                        .addOnFailureListener { error ->
                            result.error("send_failed", error.message, null)
                        }
                }
                "cacheSyncPayload" -> {
                    val payload = call.argument<String>("payload")
                    if (payload.isNullOrBlank()) {
                        result.error("invalid_arguments", "Sync payload is empty", null)
                    } else {
                        WearCompanionTransport.cachePayload(this, payload)
                        result.success(null)
                    }
                }
                "sendPaymentQrResponse" -> {
                    val nodeId = call.argument<String>("nodeId")
                    val payload = call.argument<String>("payload")
                    if (nodeId.isNullOrBlank() || payload.isNullOrBlank() ||
                        nodeId != WearCompanionTransport.pairedWatchNodeId(this)
                    ) {
                        result.error("invalid_arguments", "Invalid payment response", null)
                    } else {
                        Wearable.getMessageClient(this)
                            .sendMessage(
                                nodeId,
                                WearCompanionTransport.PAYMENT_RESPONSE_PATH,
                                payload.toByteArray(Charsets.UTF_8),
                            )
                            .addOnSuccessListener { result.success(null) }
                            .addOnFailureListener { error ->
                                result.error("send_failed", error.message, null)
                            }
                    }
                }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        WearCompanionTransport.setPaymentProxyActive(true)
        Wearable.getMessageClient(this).addListener(this)
    }

    override fun onPause() {
        Wearable.getMessageClient(this).removeListener(this)
        WearCompanionTransport.setPaymentProxyActive(false)
        super.onPause()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        companionChannel?.setMethodCallHandler(null)
        companionChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onMessageReceived(event: MessageEvent) {
        if (event.path != WearCompanionTransport.PAYMENT_REQUEST_PATH ||
            event.sourceNodeId != WearCompanionTransport.pairedWatchNodeId(this)
        ) return
        runOnUiThread {
            companionChannel?.invokeMethod("receivePaymentQrRequest", event.sourceNodeId)
        }
    }
}
