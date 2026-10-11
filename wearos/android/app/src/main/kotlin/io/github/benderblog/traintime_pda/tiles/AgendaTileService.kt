// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.tiles

import androidx.wear.protolayout.ActionBuilders
import androidx.wear.protolayout.ColorBuilders.argb
import androidx.wear.protolayout.DimensionBuilders.dp
import androidx.wear.protolayout.DimensionBuilders.expand
import androidx.wear.protolayout.DimensionBuilders.sp
import androidx.wear.protolayout.LayoutElementBuilders
import androidx.wear.protolayout.ModifiersBuilders
import androidx.wear.protolayout.ResourceBuilders
import androidx.wear.protolayout.TimelineBuilders
import androidx.wear.tiles.RequestBuilders
import androidx.wear.tiles.TileBuilders
import androidx.wear.tiles.TileService
import com.google.common.util.concurrent.Futures
import com.google.common.util.concurrent.ListenableFuture
import io.github.benderblog.traintime_pda.MainActivity
import io.github.benderblog.traintime_pda.data.WearCacheStore
import io.github.benderblog.traintime_pda.data.WearPreferences
import io.github.benderblog.traintime_pda.domain.WearAgendaBuilder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.guava.future
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.format.DateTimeFormatter

/** System-managed, cache-only provider; it never creates a network client. */
class AgendaTileService : TileService() {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override fun onTileRequest(requestParams: RequestBuilders.TileRequest): ListenableFuture<TileBuilders.Tile> =
        scope.future {
            val cache = WearCacheStore(this@AgendaTileService)
            val preferences = WearPreferences(this@AgendaTileService)
            val zone = ZoneId.systemDefault()
            val now = LocalDateTime.now(zone)
            val table = cache.readClassTable()
            val experiments = cache.readExperiments()
            val timeline = TimelineBuilders.Timeline.Builder()
                .addTimelineEntry(
                    TimelineBuilders.TimelineEntry.Builder()
                        .setLayout(layout("XDYou 课表", "打开应用查看课表", "本地课表需刷新"))
                        .build(),
                )

            if (table == null && experiments == null) {
                timeline.addTimelineEntry(
                    TimelineBuilders.TimelineEntry.Builder()
                        .setLayout(layout("XDYou 课表", "请先同步课表", "打开应用完成配对和同步"))
                        .setValidity(interval(now, now.toLocalDate().plusDays(2).atStartOfDay(), zone))
                        .build(),
                )
            } else {
                val data = WearAgendaBuilder.loadHomeData(
                    preferences.currentSemester, table, experiments, now, zone,
                )
                val entries = AgendaTileTimeline.build(
                    data.todayItems + data.tomorrowItems,
                    now,
                    now.toLocalDate().plusDays(2).atStartOfDay(),
                )
                for (entry in entries) {
                    val item = entry.item
                    val title = item?.title ?: "暂无后续安排"
                    val time = item?.let {
                        "${it.start.format(DateTimeFmt)}–${it.end.format(TimeFmt)}"
                    } ?: "今天和明天没有剩余安排"
                    timeline.addTimelineEntry(
                        TimelineBuilders.TimelineEntry.Builder()
                            .setValidity(interval(entry.start, entry.end, zone))
                            .setLayout(
                                layout(
                                    if (entry.ongoing) "进行中" else "XDYou · 接下来",
                                    title,
                                    time,
                                    item?.location,
                                ),
                            )
                            .build(),
                    )
                }
            }
            TileBuilders.Tile.Builder()
                .setResourcesVersion(RESOURCES_VERSION)
                .setTileTimeline(timeline.build())
                // Rebuild tomorrow's local timeline daily; course transitions are system-rendered.
                .setFreshnessIntervalMillis(24 * 60 * 60 * 1000L)
                .build()
        }

    override fun onTileResourcesRequest(
        requestParams: RequestBuilders.ResourcesRequest,
    ): ListenableFuture<ResourceBuilders.Resources> = Futures.immediateFuture(
        ResourceBuilders.Resources.Builder().setVersion(RESOURCES_VERSION).build(),
    )

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }

    private fun interval(start: LocalDateTime, end: LocalDateTime, zone: ZoneId) =
        TimelineBuilders.TimeInterval.Builder()
            .setStartMillis(start.atZone(zone).toInstant().toEpochMilli())
            .setEndMillis(end.atZone(zone).toInstant().toEpochMilli())
            .build()

    private fun layout(
        header: String,
        title: String,
        detail: String,
        location: String? = null,
    ): LayoutElementBuilders.Layout {
        val content = LayoutElementBuilders.Column.Builder()
            .setWidth(expand())
            .setHorizontalAlignment(LayoutElementBuilders.HORIZONTAL_ALIGN_CENTER)
            .addContent(text(header, 12f, ACCENT))
            .addContent(LayoutElementBuilders.Spacer.Builder().setHeight(dp(8f)).build())
            .addContent(text(title, 18f, WHITE, 2))
            .addContent(LayoutElementBuilders.Spacer.Builder().setHeight(dp(6f)).build())
            .addContent(text(detail, 12f, WHITE))
        location?.let { content.addContent(text(it, 12f, SECONDARY)) }
        content.addContent(LayoutElementBuilders.Spacer.Builder().setHeight(dp(8f)).build())
            .addContent(text("查看课表 ›", 12f, ACCENT))

        val clickable = ModifiersBuilders.Clickable.Builder()
            .setId("open_agenda")
            .setOnClick(
                ActionBuilders.LaunchAction.Builder()
                    .setAndroidActivity(
                        ActionBuilders.AndroidActivity.Builder()
                            .setPackageName(packageName)
                            .setClassName(MainActivity::class.java.name)
                            .addKeyToExtraMapping(MainActivity.EXTRA_SHOW_AGENDA, ActionBuilders.booleanExtra(true))
                            .build(),
                    )
                    .build(),
            )
            .build()
        return LayoutElementBuilders.Layout.Builder().setRoot(
            LayoutElementBuilders.Box.Builder()
                .setWidth(expand())
                .setHeight(expand())
                .setModifiers(
                    ModifiersBuilders.Modifiers.Builder()
                        .setClickable(clickable)
                        .setPadding(ModifiersBuilders.Padding.Builder().setAll(dp(24f)).build())
                        .setSemantics(
                            ModifiersBuilders.Semantics.Builder()
                                .setContentDescription(listOfNotNull(header, title, detail, location, "查看课表").joinToString("，"))
                                .build(),
                        )
                        .build(),
                )
                .addContent(content.build())
                .build(),
        ).build()
    }

    private fun text(value: String, size: Float, color: Int, lines: Int = 1) =
        LayoutElementBuilders.Text.Builder()
            .setText(value)
            .setFontStyle(LayoutElementBuilders.FontStyle.Builder().setSize(sp(size)).setColor(argb(color)).build())
            .setMaxLines(lines)
            .setMultilineAlignment(LayoutElementBuilders.TEXT_ALIGN_CENTER)
            .setOverflow(LayoutElementBuilders.TEXT_OVERFLOW_ELLIPSIZE)
            .build()

    private companion object {
        const val RESOURCES_VERSION = "agenda-1"
        const val ACCENT = 0xFF70D6FF.toInt()
        const val WHITE = 0xFFFFFFFF.toInt()
        const val SECONDARY = 0xFFB0B0B0.toInt()
        val DateTimeFmt: DateTimeFormatter = DateTimeFormatter.ofPattern("MM-dd HH:mm")
        val TimeFmt: DateTimeFormatter = DateTimeFormatter.ofPattern("HH:mm")
    }
}
