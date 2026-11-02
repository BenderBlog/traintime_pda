package io.github.benderblog.traintime_pda.liveupdate

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.Typeface
import android.graphics.drawable.Icon
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import io.github.benderblog.traintime_pda.MainActivity
import io.github.benderblog.traintime_pda.R

/// Posts the "a class is going on" notification.
///
/// Android 16 promotes ongoing progress notifications into Live Updates: a
/// chip in the status bar, on the lock screen and in the always-on display.
/// Devices which ship their own version of it (Xiaomi's "Super Island" for
/// instance) pick the very same notification up.
object CourseLiveUpdateManager {
    /// Live Updates are an Android 16 feature.
    private const val LIVE_UPDATE_API_LEVEL = 36

    private const val CHANNEL_ID = "course_live_update"

    /// Kept outside of the range the scheduled classes use.
    private const val PREVIEW_NOTIFICATION_ID = 2147483000

    /// The looks of the badge are chosen on the debug page. They are kept in
    /// the preferences of the native side: the Dart side stores its own ones in
    /// a place the platform cannot read.
    private const val PREFERENCES = "course_live_update"
    private const val BADGE_STYLE_KEY = "badge_style"
    private const val BADGE_STYLE_INITIAL = 0
    private const val BADGE_STYLE_SHORT = 1
    private const val BADGE_STYLE_SQUARE = 2
    private const val BADGE_STYLE_NONE = 3

    /// How long before a class starts its Live Update shows up.
    ///
    /// Twenty minutes is the time it takes to walk to the classroom, so the
    /// island is a reminder on its own even for someone who does not look at the
    /// notifications of the app.
    private const val LEAD_MINUTES_KEY = "lead_minutes"
    private const val DEFAULT_LEAD_MINUTES = 20

    /// Whether the classes are put on the island at all.
    ///
    /// It is a setting of its own: the reminders of the app are notifications
    /// which beep once, the island is a status which stays while the class goes
    /// on, and someone may well want one without the other.
    private const val ENABLED_KEY = "enabled"

    /// The class which is on the island right now, as JSON.
    private const val SHOWN_EVENT_KEY = "shown_event"

    /// Remembers how the badge of the course should look.
    fun setBadgeStyle(context: Context, style: Int) {
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putInt(BADGE_STYLE_KEY, style.coerceIn(0, BADGE_STYLE_NONE))
            .apply()
    }

    /// Minutes between the moment the Live Update of a class shows up and the
    /// moment the class starts.
    fun leadMinutes(context: Context): Int =
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getInt(LEAD_MINUTES_KEY, DEFAULT_LEAD_MINUTES)
            .coerceIn(0, MAX_LEAD_MINUTES)

    fun leadMillis(context: Context): Long = leadMinutes(context) * 60_000L

    /// Whether the classes are shown on the island.
    fun isEnabled(context: Context): Boolean =
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getBoolean(ENABLED_KEY, true)

    fun setEnabled(context: Context, enabled: Boolean) {
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(ENABLED_KEY, enabled)
            .apply()
    }

    /// Remembers how early the island of a class should appear.
    ///
    /// It is kept on this side as well: the alarms which put a class on the
    /// island are set by the platform when the app is not running, and they
    /// need to know when to fire.
    fun setLeadMinutes(context: Context, minutes: Int) {
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putInt(LEAD_MINUTES_KEY, minutes.coerceIn(0, MAX_LEAD_MINUTES))
            .apply()
    }

    /// Remembers which class is on the island right now.
    ///
    /// The look of the notification is decided on the platform side, and only
    /// one class fits on the island, so the one which is up has to be known:
    /// changing the badge inside it must not put a second one next to it.
    private fun rememberShown(context: Context, event: CourseLiveUpdateEvent) {
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(SHOWN_EVENT_KEY, event.toJson().toString())
            .apply()
    }

    private fun shownEvent(context: Context): CourseLiveUpdateEvent? {
        val raw = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getString(SHOWN_EVENT_KEY, null) ?: return null
        return try {
            CourseLiveUpdateEvent.fromJson(org.json.JSONObject(raw))
        } catch (e: Exception) {
            null
        }
    }

    private fun forgetShown(context: Context) {
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .remove(SHOWN_EVENT_KEY)
            .apply()
    }

    /// Takes the class which is on the island off it.
    fun hideCurrent(context: Context) {
        shownEvent(context)?.let { cancel(context, it.id) }
        forgetShown(context)
    }

    /// Posts the class which is on the island again, with the look which is set
    /// right now. Returns whether there was a class to post.
    fun refreshCurrent(context: Context): Boolean {
        val event = shownEvent(context) ?: return false
        if (System.currentTimeMillis() >= event.endMillis) {
            forgetShown(context)
            return false
        }

        show(context, event)
        return true
    }

    val isSupported: Boolean
        get() = Build.VERSION.SDK_INT >= LIVE_UPDATE_API_LEVEL

    fun show(
        context: Context,
        event: CourseLiveUpdateEvent,
        now: Long = System.currentTimeMillis(),
    ) {
        if (Build.VERSION.SDK_INT < LIVE_UPDATE_API_LEVEL) {
            return
        }
        if (now >= event.endMillis) {
            cancel(context, event.id)
            return
        }

        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        ensureChannel(context, manager)
        manager.notify(event.id, build(context, event, now))
        rememberShown(context, event)
    }

    fun cancel(context: Context, id: Int) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        manager.cancel(id)
        if (shownEvent(context)?.id == id) {
            forgetShown(context)
        }
    }

    /// Shows a made up class right away, to try the island out without waiting
    /// for a real lesson. It is not part of the schedule, so it does not touch
    /// the pending alarms.
    ///
    /// Only one class fits on the island, so the preview takes the place of the
    /// class which is shown at that moment; [stopPreview] puts it back.
    fun showPreview(context: Context, event: CourseLiveUpdateEvent) {
        if (Build.VERSION.SDK_INT < LIVE_UPDATE_API_LEVEL) {
            return
        }

        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        ensureChannel(context, manager)
        shownEvent(context)?.let { manager.cancel(it.id) }
        manager.notify(PREVIEW_NOTIFICATION_ID, build(context, event, System.currentTimeMillis()))
    }

    fun stopPreview(context: Context) {
        val manager = context.getSystemService(NotificationManager::class.java)
        manager?.cancel(PREVIEW_NOTIFICATION_ID)

        /// Whatever the preview replaced comes back.
        refreshCurrent(context)
    }

    private fun ensureChannel(context: Context, manager: NotificationManager) {
        if (manager.getNotificationChannel(CHANNEL_ID) != null) {
            return
        }

        val channel = NotificationChannel(
            CHANNEL_ID,
            "Ongoing class",
            NotificationManager.IMPORTANCE_DEFAULT,
        ).apply {
            description = "Shows the class which is going on right now"
            setShowBadge(false)
            // A class going on is a status, it should never beep.
            setSound(null, null)
            enableVibration(false)
        }
        manager.createNotificationChannel(channel)
    }

    @RequiresApi(LIVE_UPDATE_API_LEVEL)
    private fun build(
        context: Context,
        event: CourseLiveUpdateEvent,
        now: Long,
    ): Notification {
        val total = event.periods.coerceAtLeast(1)
        val style = Notification.ProgressStyle()
            .setStyledByProgress(false)
            .setProgress(event.progressInPeriods(now))
            // One piece per class period, in the colour of the course card.
            .setProgressTrackerIcon(trackerDot(context, event))
            .setProgressSegments(
                (0 until total).map {
                    Notification.ProgressStyle.Segment(1).setColor(event.color)
                },
            )

        // The badge of the course is optional: the debug page switches between
        // one character, the short name, a rounded square and no badge at all.
        // The chip of the collapsed island is set from it as well, so that both
        // ends of the notification talk about the course the same way.
        val badge = badgeStyle(context)

        val builder = Notification.Builder(context, CHANNEL_ID)
            // The left icon stands for the lesson, not for the app: the app is
            // the only one posting an ongoing class, while the notification has
            // to say "class" at a glance where the course name does not fit.
            .setSmallIcon(R.drawable.ic_course_live_update)
            .setContentTitle(event.title)
            .setContentText(event.detailText)
            .setSubText(event.footnoteText(now))
            .setContentIntent(openAppIntent(context))
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            // A live countdown to the end of the lesson, kept running by the
            // system itself; before the lesson starts it counts towards its
            // beginning instead.
            .setWhen(event.countdownTarget(now))
            .setUsesChronometer(true)
            .setChronometerCountDown(true)
            .setStyle(style)
            // The countdown of the system runs past its target once the lesson
            // is over: without this the island would sit there counting "-00:06"
            // until the alarm which takes it off fires, and that alarm is only
            // exact when the app is allowed to set exact alarms. The system takes
            // the notification off itself at the end of the lesson instead.
            .setTimeoutAfter((event.endMillis - now).coerceAtLeast(1L))
            // What the collapsed island and the status bar chip show. Only a
            // couple of characters fit there, so it is the short form of the
            // name: a single character says nothing about which class it is, and
            // the badge is not part of this chip anyway.
            .setShortCriticalText(event.shortTitle.ifEmpty { event.title })
            // This is the bit which asks the system to promote the notification
            // into a Live Update.
            .setRequestPromotedOngoing(true)
            // The colour of the course, the same one its card has in the
            // classtable. The system draws the small icon inside a circle of this
            // colour, and the bar of the periods is drawn in it: left to itself
            // the circle takes the colour of the app and the island ends up blue
            // on one side and purple on the other.
            .setColor(event.color)
            // Note: setColorized(true) must *not* be used, a colorized
            // notification is not eligible for promotion.

        if (badge != BADGE_STYLE_NONE) {
            builder.setLargeIcon(
                courseBadge(
                    context = context,
                    event = event,
                    characters = if (badge == BADGE_STYLE_SHORT) 2 else 1,
                    rounded = badge == BADGE_STYLE_SQUARE,
                ),
            )
        }

        return builder.build()
    }

    /// Which badge the card shows, one of the `BADGE_STYLE_` values.
    ///
    /// The card is left without a badge by default: the title of the class is
    /// already there, and one more mark of the same class next to it only makes
    /// the notification look busy.
    private fun badgeStyle(context: Context): Int =
        context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
            .getInt(BADGE_STYLE_KEY, BADGE_STYLE_NONE)

    /// The mark of the course: a circle (or a rounded square) in the colour of
    /// its card with the beginning of its name.
    ///
    /// It is the only place where the course is drawn inside the card; the left
    /// icon stays the app itself.
    private fun courseBadge(
        context: Context,
        event: CourseLiveUpdateEvent,
        characters: Int,
        rounded: Boolean = false,
    ): Icon {
        val size = dp(context, 48)
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val background = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = event.color }
        if (rounded) {
            val corner = size * 0.24f
            canvas.drawRoundRect(
                0f,
                0f,
                size.toFloat(),
                size.toFloat(),
                corner,
                corner,
                background,
            )
        } else {
            canvas.drawCircle(size / 2f, size / 2f, size / 2f, background)
        }

        val label = (event.shortTitle.ifEmpty { event.title }).take(characters)
        if (label.isNotEmpty()) {
            drawLabel(canvas, label, size.toFloat(), Color.WHITE)
        }

        return Icon.createWithBitmap(bitmap)
    }

    /// The mark which travels along the progress bar: a plain dot, so that the
    /// badge of the course is not repeated inside the same card.
    private fun trackerDot(context: Context, event: CourseLiveUpdateEvent): Icon {
        val size = dp(context, 20)
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val radius = size / 2.4f
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = Color.WHITE
        }
        canvas.drawCircle(size / 2f, size / 2f, radius, paint)

        paint.style = Paint.Style.STROKE
        paint.strokeWidth = size / 9f
        paint.color = event.color
        canvas.drawCircle(size / 2f, size / 2f, radius, paint)

        return Icon.createWithBitmap(bitmap)
    }

    private fun dp(context: Context, value: Int): Int =
        (value * context.resources.displayMetrics.density).toInt()
            .coerceAtLeast(value * 2)

    /// Draws the text centred inside a square of [size].
    ///
    /// The font is the one of the system interface - MiSans on HyperOS, Roboto
    /// elsewhere - at its regular weight; a bold weight makes a single Chinese
    /// character look heavy. The ink of the glyphs is centred instead of the
    /// font box, which would put them a little off centre.
    private fun drawLabel(canvas: Canvas, label: String, size: Float, color: Int) {
        val text = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            textAlign = Paint.Align.CENTER
            textSize = size * if (label.length > 1) 0.42f else 0.6f
            typeface = Typeface.DEFAULT
            isSubpixelText = true
            if (label.length > 1) {
                letterSpacing = -0.03f
            }
        }

        val ink = Rect()
        text.getTextBounds(label, 0, label.length, ink)
        canvas.drawText(
            label,
            size / 2f,
            size / 2f - (ink.top + ink.bottom) / 2f,
            text,
        )
    }

    /// Whether the notification of a class satisfies the rules the system
    /// applies before promoting it into a Live Update.
    fun hasPromotableCharacteristics(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < LIVE_UPDATE_API_LEVEL) {
            return false
        }

        val now = System.currentTimeMillis()
        val sample = CourseLiveUpdateEvent(
            id = PREVIEW_NOTIFICATION_ID,
            title = "Class",
            body = "",
            color = CourseLiveUpdateEvent.DEFAULT_COLOR,
            startMillis = now,
            endMillis = now + 60_000L,
        )
        return build(context, sample, now).hasPromotableCharacteristics()
    }

    /// Whether the system is showing one of our notifications as a Live Update
    /// right now.
    fun isPromoted(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < LIVE_UPDATE_API_LEVEL) {
            return false
        }

        val manager = context.getSystemService(NotificationManager::class.java)
            ?: return false
        return manager.activeNotifications.any { statusBarNotification ->
            (statusBarNotification.notification.flags and
                Notification.FLAG_PROMOTED_ONGOING) != 0
        }
    }

    /// Everything which decides whether the island shows up, for the debug
    /// page.
    fun diagnostics(context: Context): Map<String, Any?> {
        val manager = context.getSystemService(NotificationManager::class.java)
        manager?.let { ensureChannel(context, it) }
        val channel = manager?.getNotificationChannel(CHANNEL_ID)

        return mapOf(
            "supported" to isSupported,
            "targetSdk" to context.applicationInfo.targetSdkVersion,
            "notificationsEnabled" to (manager?.areNotificationsEnabled() ?: false),
            "canPostPromoted" to canPostPromoted(manager),
            "promotableCharacteristics" to hasPromotableCharacteristics(context),
            "promoted" to isPromoted(context),
            "channelImportance" to (channel?.importance ?: -1),
            "badgeStyle" to badgeStyle(context),
            "leadMinutes" to leadMinutes(context),
            "enabled" to isEnabled(context),
        )
    }

    private fun canPostPromoted(manager: NotificationManager?): Boolean {
        if (Build.VERSION.SDK_INT < LIVE_UPDATE_API_LEVEL) {
            return false
        }
        return manager?.canPostPromotedNotifications() ?: false
    }

    /// Opens the notification settings of the app, where the user can turn the
    /// live updates on.
    fun openNotificationSettings(context: Context) {
        val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
            putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try {
            context.startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            android.util.Log.w("CourseLiveUpdate", "No notification settings: ${e.message}")
        }
    }

    private fun openAppIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /// The longest lead time the setting allows.
    const val MAX_LEAD_MINUTES = 60
}
