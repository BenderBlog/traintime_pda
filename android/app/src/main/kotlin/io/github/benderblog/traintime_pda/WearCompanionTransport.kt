package io.github.benderblog.traintime_pda

import org.json.JSONObject
import java.util.UUID
import android.content.Context
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.WearableListenerService

internal object WearCompanionTransport {
    const val CHANNEL = "io.github.benderblog.traintime_pda/wear_companion_phone"
    const val SYNC_PATH = "/traintime_pda_wear_os/sync/v1"
    const val SYNC_ACK_PATH = "/traintime_pda_wear_os/sync/ack/v1"
    const val REQUEST_PATH = "/traintime_pda_wear_os/request/v1"
    const val PAYMENT_REQUEST_PATH = "/traintime_pda_wear_os/payment/request/v1"
    const val PAYMENT_RESPONSE_PATH = "/traintime_pda_wear_os/payment/response/v1"
    private const val PREFS = "wear_companion_transport"
    private const val PAYLOAD = "latest_payload"
    private const val PAIRED_WATCH_NODE_ID = "paired_watch_node_id"
    @Volatile
    private var paymentProxyActive = false

    fun profileIdForAccount(context: Context, account: String): String {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val previous = prefs.getString("profile_account", null)
        val stored = prefs.getString("profile_id", null)
        if (previous == account && stored != null) return stored
        val id = UUID.randomUUID().toString()
        prefs.edit().apply {
            if (previous != null && previous != account) remove(PAYLOAD)
            putString("profile_account", account)
            putString("profile_id", id)
        }.apply()
        return id
    }

    fun sanitizedPayload(context: Context, payload: String): String {
        val json = JSONObject(payload)
        val legacyAccount = json.optJSONObject("credentials")?.optString("idsAccount")
        if (!json.has("profileId") && !legacyAccount.isNullOrEmpty()) {
            json.put("profileId", profileIdForAccount(context, legacyAccount))
        }
        json.remove("credentials")
        return json.toString()
    }

    fun cachePayload(context: Context, payload: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(PAYLOAD, sanitizedPayload(context, payload)).apply()
    }

    fun cachedPayload(context: Context): String? {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val stored = prefs.getString(PAYLOAD, null) ?: return null
        return try {
            sanitizedPayload(context, stored).also { safe ->
                if (safe != stored) prefs.edit().putString(PAYLOAD, safe).apply()
            }
        } catch (_: Exception) {
            prefs.edit().remove(PAYLOAD).apply()
            null
        }
    }

    fun rememberPairedWatch(context: Context, nodeId: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(PAIRED_WATCH_NODE_ID, nodeId).apply()
    }

    fun pairedWatchNodeId(context: Context): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(PAIRED_WATCH_NODE_ID, null)

    fun setPaymentProxyActive(active: Boolean) {
        paymentProxyActive = active
    }

    fun isPaymentProxyActive(): Boolean = paymentProxyActive
}

/** Answers a paired watch with the last phone-generated snapshot. */
class WearCompanionListenerService : WearableListenerService() {
    override fun onMessageReceived(event: MessageEvent) {
        if (event.sourceNodeId != WearCompanionTransport.pairedWatchNodeId(this)) return
        when (event.path) {
            WearCompanionTransport.REQUEST_PATH -> {
                val payload = WearCompanionTransport.cachedPayload(this) ?: return
                Wearable.getMessageClient(this).sendMessage(
                    event.sourceNodeId,
                    WearCompanionTransport.SYNC_PATH,
                    payload.toByteArray(Charsets.UTF_8),
                )
            }
            WearCompanionTransport.PAYMENT_REQUEST_PATH -> {
                if (WearCompanionTransport.isPaymentProxyActive()) return
                Wearable.getMessageClient(this).sendMessage(
                    event.sourceNodeId,
                    WearCompanionTransport.PAYMENT_RESPONSE_PATH,
                    "{\"ok\":false,\"error\":\"phone_app_required\"}"
                        .toByteArray(Charsets.UTF_8),
                )
            }
        }
    }
}
