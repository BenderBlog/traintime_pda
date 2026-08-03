package io.github.benderblog.traintime_pda

import android.content.Context
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.Wearable
import com.google.android.gms.wearable.WearableListenerService

internal object WearCompanionTransport {
    const val CHANNEL = "io.github.benderblog.traintime_pda/wear_companion_phone"
    const val SYNC_PATH = "/traintime_pda_wear_os/sync/v1"
    const val REQUEST_PATH = "/traintime_pda_wear_os/request/v1"
    private const val PREFS = "wear_companion_transport"
    private const val PAYLOAD = "latest_payload"

    fun cachePayload(context: Context, payload: String) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit().putString(PAYLOAD, payload).apply()
    }

    fun cachedPayload(context: Context): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(PAYLOAD, null)
}

/** Answers a paired watch with the last phone-generated snapshot. */
class WearCompanionListenerService : WearableListenerService() {
    override fun onMessageReceived(event: MessageEvent) {
        if (event.path != WearCompanionTransport.REQUEST_PATH) return
        val payload = WearCompanionTransport.cachedPayload(this) ?: return
        Wearable.getMessageClient(this).sendMessage(
            event.sourceNodeId,
            WearCompanionTransport.SYNC_PATH,
            payload.toByteArray(Charsets.UTF_8),
        )
    }
}
