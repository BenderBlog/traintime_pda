package io.github.benderblog.traintime_pda.liveupdate

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// Starts, refreshes and finishes the Live Update of a class.
///
/// It is triggered by the alarms of [CourseLiveUpdateScheduler], so it also
/// runs when the app itself is not running.
class CourseLiveUpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            -> {
                CourseLiveUpdateScheduler.restore(context)
                return
            }
        }

        val event = CourseLiveUpdateEvent.from(intent) ?: return
        when (intent.action) {
            CourseLiveUpdateScheduler.ACTION_START,
            CourseLiveUpdateScheduler.ACTION_UPDATE,
            -> CourseLiveUpdateManager.show(context, event)

            CourseLiveUpdateScheduler.ACTION_STOP ->
                CourseLiveUpdateManager.cancel(context, event.id)
        }
    }
}
