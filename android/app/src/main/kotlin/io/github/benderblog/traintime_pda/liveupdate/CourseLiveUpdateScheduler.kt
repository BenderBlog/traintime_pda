package io.github.benderblog.traintime_pda.liveupdate

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject

/// Schedules the alarms which start, refresh and finish the Live Update of a
/// class. It works while the app is not running, the alarms carry everything
/// the receiver needs.
object CourseLiveUpdateScheduler {
    const val ACTION_START: String =
        "io.github.benderblog.traintime_pda.liveupdate.START"
    const val ACTION_UPDATE: String =
        "io.github.benderblog.traintime_pda.liveupdate.UPDATE"
    const val ACTION_STOP: String =
        "io.github.benderblog.traintime_pda.liveupdate.STOP"

    /// The alarms of one class: it is put on the island some minutes before it
    /// starts, refreshed when it starts, refreshed again in the middle (the bar
    /// of periods is a value the system does not move by itself) and taken off
    /// when it ends.
    private const val ALARMS_PER_EVENT = 4

    /// What each of the alarms of a class does, in the order of their request
    /// codes. [cancelAll] walks the very same list.
    private val ALARM_ACTIONS = listOf(ACTION_START, ACTION_UPDATE, ACTION_UPDATE, ACTION_STOP)

    /// Keeps the amount of pending alarms sane: the platform refuses to keep
    /// more than a few hundred alarms of an app, and each class takes
    /// [ALARMS_PER_EVENT] of them.
    private const val MAX_EVENTS = 120

    private const val PREFERENCES = "course_live_update"
    private const val KEY_EVENTS = "events"
    private const val KEY_EVENT_COUNT = "event_count"

    /// Replaces the whole schedule with [events].
    ///
    /// Returns how many classes are on the island from now on: the ones which
    /// are already over are dropped, and so are the ones past [MAX_EVENTS].
    fun schedule(context: Context, events: List<CourseLiveUpdateEvent>): Int {
        cancelAll(context)

        // The island has a switch of its own: when it is off, nothing is planned
        // and whatever is on it goes away.
        if (!CourseLiveUpdateManager.isEnabled(context)) {
            log("the island is turned off")
            return 0
        }

        val now = System.currentTimeMillis()
        val lead = CourseLiveUpdateManager.leadMillis(context)
        val planned = events
            .filter { it.endMillis > now }
            .sortedBy { it.startMillis }
            .take(MAX_EVENTS)

        var index = 0

        /// The end of the last class which was planned, so that a class never
        /// takes the island away from the class before it: a lead of twenty
        /// minutes would otherwise put the next class up in the middle of the
        /// ongoing one whenever the break is shorter than that.
        var previousEnd = 0L

        for (event in planned) {
            val offset = index * ALARMS_PER_EVENT
            val showAt = maxOf(event.startMillis - lead, previousEnd)
            if (showAt > now) {
                setAlarm(context, event, ACTION_START, showAt, offset)
            } else {
                // The class starts within the lead time (or is already going
                // on): the user has just opened the app inside that window, so
                // it goes up right away.
                CourseLiveUpdateManager.show(context, event, now)
            }
            // The countdown of the notification runs towards the start of the
            // class by itself, but the line under the title and the bar of
            // periods are what they were when it went up, so a class which went
            // up early is posted again when it really begins.
            if (lead > 0 && event.startMillis > now) {
                setAlarm(context, event, ACTION_UPDATE, event.startMillis, offset + 1)
            }
            val middle = event.startMillis + event.durationMillis / 2
            if (middle > now) {
                setAlarm(context, event, ACTION_UPDATE, middle, offset + 2)
            }
            setAlarm(context, event, ACTION_STOP, event.endMillis, offset + 3)
            previousEnd = maxOf(previousEnd, event.endMillis)
            index++
        }

        log("scheduled $index classes")
        store(context, planned)
        return index
    }

    /// Drops everything, the ongoing notification included.
    fun cancelAll(context: Context) {
        val count = loadCount(context)
        for (index in 0 until count * ALARMS_PER_EVENT) {
            val action = ALARM_ACTIONS[index % ALARMS_PER_EVENT]
            val alarmManager = context.getSystemService(AlarmManager::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                index,
                Intent(context, CourseLiveUpdateReceiver::class.java).setAction(action),
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
            )
            if (pendingIntent != null) {
                alarmManager?.cancel(pendingIntent)
                pendingIntent.cancel()
            }
        }
        store(context, emptyList())

        // The class which is on the island right now has no alarm left which
        // would take it off, so it is removed here.
        CourseLiveUpdateManager.hideCurrent(context)
    }

    /// Puts the stored schedule back in place, e.g. after a reboot.
    fun restore(context: Context) {
        val events = load(context)
        if (events.isEmpty()) {
            return
        }
        log("restoring ${events.size} classes")
        schedule(context, events)
    }

    private fun setAlarm(
        context: Context,
        event: CourseLiveUpdateEvent,
        action: String,
        atMillis: Long,
        requestCode: Int,
    ) {
        val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestCode,
            event.writeTo(
                Intent(context, CourseLiveUpdateReceiver::class.java).setAction(action),
            ),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
            alarmManager.canScheduleExactAlarms()
        try {
            if (exact) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    atMillis,
                    pendingIntent,
                )
            } else {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    atMillis,
                    pendingIntent,
                )
            }
        } catch (e: SecurityException) {
            log("exact alarm refused, falling back: ${e.message}")
            alarmManager.setAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                atMillis,
                pendingIntent,
            )
        }
    }

    private fun store(context: Context, events: List<CourseLiveUpdateEvent>) {
        val array = JSONArray()
        events.forEach { array.put(it.toJson()) }
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_EVENTS, array.toString())
            .putInt(KEY_EVENT_COUNT, events.size)
            .apply()
    }

    private fun load(context: Context): List<CourseLiveUpdateEvent> {
        val raw = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getString(KEY_EVENTS, null) ?: return emptyList()
        return try {
            val array = JSONArray(raw)
            (0 until array.length()).mapNotNull { index ->
                val entry = array.optJSONObject(index) ?: return@mapNotNull null
                CourseLiveUpdateEvent.fromJson(entry)
            }
        } catch (e: Exception) {
            log("unable to read the stored schedule: ${e.message}")
            emptyList()
        }
    }

    private fun loadCount(context: Context): Int =
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getInt(KEY_EVENT_COUNT, 0)

    private fun log(message: String) {
        android.util.Log.i("CourseLiveUpdate", message)
    }
}
