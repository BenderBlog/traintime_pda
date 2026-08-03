package io.github.benderblog.traintime_pda

import android.os.Bundle
import androidx.core.view.WindowCompat
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge display
        WindowCompat.enableEdgeToEdge(window)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WearCompanionTransport.CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getConnectedWearNodes" -> {
                    Wearable.getNodeClient(this).connectedNodes
                        .addOnSuccessListener { nodes ->
                            result.success(nodes.map { node ->
                                mapOf(
                                    "id" to node.id,
                                    "name" to node.displayName,
                                    "isNearby" to node.isNearby,
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
                        .addOnSuccessListener { result.success(null) }
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
                else -> result.notImplemented()
            }
        }
    }
}
