package io.github.benderblog.traintime_pda.liveupdate

import android.content.Intent
import org.json.JSONObject

/// A class which is shown as a Live Update while it is ongoing.
data class CourseLiveUpdateEvent(
    val id: Int,
    val title: String,
    val body: String,
    val color: Int,
    val startMillis: Long,
    val endMillis: Long,
    /// A very short form of the name, for the status bar chip and the badge.
    val shortTitle: String = "",
    /// "第 3-4 节"
    val periodText: String = "",
    /// "08:30 - 10:05"
    val timeText: String = "",
    /// "下一节 10:25 · B-106"
    val nextText: String = "",
    /// "即将开始", shown while the class has not begun yet.
    val upcomingText: String = "",
    /// How many class periods the lesson takes.
    val periods: Int = 1,
) {
    val durationMillis: Long
        get() = (endMillis - startMillis).coerceAtLeast(1L)

    /// How far the lesson has come, measured in class periods: the progress bar
    /// is cut into one piece per period.
    fun progressInPeriods(now: Long): Int {
        val total = periods.coerceAtLeast(1)
        val fraction = ((now - startMillis).toDouble() / durationMillis.toDouble())
            .coerceIn(0.0, 1.0)
        return (fraction * total).toInt().coerceIn(0, total)
    }

    /// The line under the title of the notification.
    val detailText: String
        get() = listOf(periodText, body)
            .filter { it.isNotEmpty() }
            .joinToString(" · ")

    /// The small line next to the time.
    ///
    /// While a lesson is going on the class which comes next is worth more than
    /// the clock: the countdown next to the title already tells how long the
    /// lesson still lasts, and one line is all the room there is. Before the
    /// lesson starts the countdown runs towards its beginning, which on its own
    /// looks just like the countdown to the end of a lesson, so the hint that it
    /// has not begun yet comes first.
    fun footnoteText(now: Long): String =
        if (now >= startMillis) {
            nextText.ifEmpty { timeText }
        } else {
            listOf(upcomingText, timeText).filter { it.isNotEmpty() }.joinToString(" · ")
        }

    /// The moment the countdown of the notification runs towards: the start of
    /// the lesson while it has not begun, its end afterwards.
    fun countdownTarget(now: Long): Long =
        if (now >= startMillis) endMillis else startMillis

    fun writeTo(intent: Intent): Intent = intent.apply {
        putExtra(EXTRA_ID, id)
        putExtra(EXTRA_TITLE, title)
        putExtra(EXTRA_BODY, body)
        putExtra(EXTRA_COLOR, color)
        putExtra(EXTRA_START, startMillis)
        putExtra(EXTRA_END, endMillis)
        putExtra(EXTRA_SHORT_TITLE, shortTitle)
        putExtra(EXTRA_PERIOD_TEXT, periodText)
        putExtra(EXTRA_TIME_TEXT, timeText)
        putExtra(EXTRA_NEXT_TEXT, nextText)
        putExtra(EXTRA_UPCOMING_TEXT, upcomingText)
        putExtra(EXTRA_PERIODS, periods)
    }

    fun toJson(): JSONObject = JSONObject().apply {
        put("id", id)
        put("title", title)
        put("body", body)
        put("color", color)
        put("startMillis", startMillis)
        put("endMillis", endMillis)
        put("shortTitle", shortTitle)
        put("periodText", periodText)
        put("timeText", timeText)
        put("nextText", nextText)
        put("upcomingText", upcomingText)
        put("periods", periods)
    }

    companion object {
        const val EXTRA_ID = "course_live_update.id"
        const val EXTRA_TITLE = "course_live_update.title"
        const val EXTRA_BODY = "course_live_update.body"
        const val EXTRA_COLOR = "course_live_update.color"
        const val EXTRA_START = "course_live_update.start"
        const val EXTRA_END = "course_live_update.end"
        const val EXTRA_SHORT_TITLE = "course_live_update.shortTitle"
        const val EXTRA_PERIOD_TEXT = "course_live_update.periodText"
        const val EXTRA_TIME_TEXT = "course_live_update.timeText"
        const val EXTRA_NEXT_TEXT = "course_live_update.nextText"
        const val EXTRA_UPCOMING_TEXT = "course_live_update.upcomingText"
        const val EXTRA_PERIODS = "course_live_update.periods"

        const val DEFAULT_COLOR: Int = 0xFF4A6CF7.toInt()

        fun from(intent: Intent): CourseLiveUpdateEvent? {
            if (!intent.hasExtra(EXTRA_ID)) {
                return null
            }
            return CourseLiveUpdateEvent(
                id = intent.getIntExtra(EXTRA_ID, 0),
                title = intent.getStringExtra(EXTRA_TITLE).orEmpty(),
                body = intent.getStringExtra(EXTRA_BODY).orEmpty(),
                color = intent.getIntExtra(EXTRA_COLOR, DEFAULT_COLOR),
                startMillis = intent.getLongExtra(EXTRA_START, 0L),
                endMillis = intent.getLongExtra(EXTRA_END, 0L),
                shortTitle = intent.getStringExtra(EXTRA_SHORT_TITLE).orEmpty(),
                periodText = intent.getStringExtra(EXTRA_PERIOD_TEXT).orEmpty(),
                timeText = intent.getStringExtra(EXTRA_TIME_TEXT).orEmpty(),
                nextText = intent.getStringExtra(EXTRA_NEXT_TEXT).orEmpty(),
                upcomingText = intent.getStringExtra(EXTRA_UPCOMING_TEXT).orEmpty(),
                periods = intent.getIntExtra(EXTRA_PERIODS, 1),
            )
        }

        fun fromJson(json: JSONObject): CourseLiveUpdateEvent = CourseLiveUpdateEvent(
            id = json.optInt("id"),
            title = json.optString("title"),
            body = json.optString("body"),
            color = json.optInt("color", DEFAULT_COLOR),
            startMillis = json.optLong("startMillis"),
            endMillis = json.optLong("endMillis"),
            shortTitle = json.optString("shortTitle"),
            periodText = json.optString("periodText"),
            timeText = json.optString("timeText"),
            nextText = json.optString("nextText"),
            upcomingText = json.optString("upcomingText"),
            periods = json.optInt("periods", 1),
        )

        /// Reads an event which the Dart side sent over the method channel.
        fun fromMap(map: Map<*, *>): CourseLiveUpdateEvent? {
            val start = (map["startMillis"] as? Number)?.toLong() ?: return null
            val end = (map["endMillis"] as? Number)?.toLong() ?: return null
            if (end <= start) {
                return null
            }

            return CourseLiveUpdateEvent(
                id = (map["id"] as? Number)?.toInt() ?: start.hashCode(),
                title = map["title"] as? String ?: "",
                body = map["body"] as? String ?: "",
                color = (map["color"] as? Number)?.toInt() ?: DEFAULT_COLOR,
                startMillis = start,
                endMillis = end,
                shortTitle = map["shortTitle"] as? String ?: "",
                periodText = map["periodText"] as? String ?: "",
                timeText = map["timeText"] as? String ?: "",
                nextText = map["nextText"] as? String ?: "",
                upcomingText = map["upcomingText"] as? String ?: "",
                periods = (map["periods"] as? Number)?.toInt() ?: 1,
            )
        }
    }
}
