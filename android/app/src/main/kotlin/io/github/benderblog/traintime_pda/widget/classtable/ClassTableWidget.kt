// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.widget.classtable

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.util.Log
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.intl.Locale
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.edit
import androidx.core.graphics.toColorInt
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalGlanceId
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.components.Scaffold
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.state.updateAppWidgetState
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import io.github.benderblog.traintime_pda.R
import io.github.benderblog.traintime_pda.model.ClassTableWidgetKeys
import io.github.benderblog.traintime_pda.model.ClassTableWidgetLoadState
import io.github.benderblog.traintime_pda.model.Source
import io.github.benderblog.traintime_pda.model.TimeLineItem
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

class ClassTableWidget : GlanceAppWidget() {
    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    private val tag = "[PDA ClassTableWidget][ClassTableWidget]"

    // Glance related code
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            Content(currentState())
        }
    }

    override val sizeMode = SizeMode.Exact

    companion object {
        private var timeFormatter = DateTimeFormatter.ofPattern("HH:mm")

        private val indicatorColorList = listOf(
            "#EF5350",
            "#EC407A",
            "#AB47BC",
            "#7E57C2",
            "#5C6BC0",
            "#42A5F5",
            "#29B6F6",
            "#26C6DA",
            "#26A69A",
            "#66BB6A",
            "#9CCC65",
            "#66BB6A",
        ).map { it.toColorInt() }
    }

    override suspend fun onDelete(context: Context, glanceId: GlanceId) {
        Log.i(tag, "onDelete() triggered on $glanceId.")
        super.onDelete(context, glanceId)
        try {
            updateAppWidgetState(context, HomeWidgetGlanceStateDefinition(), glanceId) { prefs ->
                prefs.preferences.edit {
                    remove(ClassTableWidgetKeys.SHOW_TODAY)
                }
                Log.i(tag, "Key ${ClassTableWidgetKeys.SHOW_TODAY} terminated.")
                prefs
            }
        } catch (e: Exception) {
            Log.e(tag, "Error updating state in onDelete for $glanceId: ${e.message}", e)
        }
        Log.i(tag, "Goodbye widget $glanceId.")
    }

    @Composable
    private fun Content(currentState: HomeWidgetGlanceState) {
        // Data Source
        val context = LocalContext.current
        val glanceId = LocalGlanceId.current
        val dataProvider = remember { ClassTableWidgetDataProvider() }
        Log.i(tag, "Content triggered.")

        // Widget State
        var isShowingToday by remember { mutableStateOf(false) }
        var widgetState by remember { mutableStateOf(ClassTableWidgetLoadState.LOADING) }
        var errorMessage by remember { mutableStateOf<String?>(null) }
        Log.i(tag, "Content state initialized.")

        // Check whether today or tomorrow's data should be loaded
        val prefs = currentState.preferences
        isShowingToday = prefs.getBoolean(ClassTableWidgetKeys.SHOW_TODAY, true)
        Log.i(tag, "isShowingToday: $isShowingToday.")

        LaunchedEffect(key1 = glanceId) {
            widgetState = ClassTableWidgetLoadState.LOADING
            errorMessage = null
            Log.i(tag, "LaunchedEffect triggered.")

            // Load data
            withContext(Dispatchers.IO) {
                ClassTableDataHolder.loadData(context)
                dataProvider.reloadData(isShowingToday, context)
            }

            // Read status from dataProvider
            if (dataProvider.getLoadingState() != ClassTableWidgetLoadState.FINISHED) {
                Log.e(tag, "Error during data loading prep: $errorMessage")
                widgetState = dataProvider.getLoadingState()
                errorMessage = dataProvider.getErrorMessage()
                return@LaunchedEffect
            }

            widgetState = ClassTableWidgetLoadState.FINISHED
            Log.i(tag, "LaunchedEffect finished.")
        }

        ClassTableWidgetGlanceView(
            widgetState,
            errorMessage,
            dataProvider.getWeekIndex(),
            dataProvider.getCurrentTime(),
            isShowingToday,
            dataProvider.getTimeLineItems()
        )
    }

    @Composable
    private fun ClassTableWidgetGlanceView(
        status: ClassTableWidgetLoadState,
        errorMessage: String?,
        weekIndex: Int,
        time: LocalDateTime,
        isShowingToday: Boolean,
        schedules: List<TimeLineItem>,
    ) {
        val context = LocalContext.current

        // Format date
        val locale = Locale.current
        val formatter = if (locale.language == "zh") {
            DateTimeFormatter.ofPattern(
                "M月d日 E", locale.platformLocale
            )
        } else {
            DateTimeFormatter.ofPattern(
                "MMMM d E", locale.platformLocale
            )
        }

        GlanceTheme {
            Scaffold(
                backgroundColor = GlanceTheme.colors.widgetBackground,
            ) {
                Column(modifier = GlanceModifier.padding(6.dp)) {
                    // The title part
                    Row(
                        modifier = GlanceModifier.fillMaxWidth().padding(top = 4.dp),
                        verticalAlignment = Alignment.Vertical.CenterVertically,
                    ) {
                        Column(modifier = GlanceModifier.defaultWeight().padding(vertical = 4.dp)) {
                            Text(
                                context.getString(R.string.widget_classtable_title),
                                style = TextStyle(
                                    fontWeight = FontWeight.Medium,
                                    fontSize = 14.sp,
                                    color = GlanceTheme.colors.primary
                                )
                            )

                            Text(
                                "${
                                    time.plusDays(if (!isShowingToday) 1 else 0).format(formatter)
                                } " + if (status != ClassTableWidgetLoadState.FINISHED) ""
                                else if (weekIndex < 0) context.getString(R.string.widget_classtable_on_holiday)
                                else context.getString(
                                    R.string.widget_classtable_week_identifier, weekIndex + 1
                                ), style = TextStyle(
                                    fontWeight = FontWeight.Medium,
                                    fontSize = 10.sp,
                                    color = GlanceTheme.colors.primary
                                )
                            )
                        }
                        if (status != ClassTableWidgetLoadState.LOADING) {
                            Box(
                                modifier = GlanceModifier.clickable(onClick = actionRunCallback<ToggleDayAction>())
                            ) {
                                Image(
                                    provider = ImageProvider(
                                        if (isShowingToday) {
                                            R.drawable.ic_next_day
                                        } else {
                                            R.drawable.ic_prev_day
                                        }
                                    ),
                                    colorFilter = ColorFilter.tint(GlanceTheme.colors.primary),
                                    modifier = GlanceModifier.size(24.dp),
                                    contentDescription = ""
                                )
                            }
                        }
                    }

                    // The remaining part
                    if (status == ClassTableWidgetLoadState.FINISHED && schedules.isNotEmpty()) {
                        LazyColumn(
                            modifier = GlanceModifier.fillMaxSize().padding(vertical = 6.dp)
                        ) {
                            items(schedules.size) { item ->
                                Box(
                                    modifier = GlanceModifier.padding(
                                        bottom = if (item == schedules.size - 1) 0.dp else 6.dp
                                    )
                                ) {
                                    ScheduleRow(item = schedules[item])
                                }
                            }
                        }
                    } else if (status == ClassTableWidgetLoadState.LOADING || status == ClassTableWidgetLoadState.FINISHED) {
                        val icon = ImageProvider(
                            if (status == ClassTableWidgetLoadState.LOADING) R.drawable.ic_classtable_refresh
                            else R.drawable.ic_classtable_no_course
                        )

                        val textDefault = context.getString(
                            if (status == ClassTableWidgetLoadState.LOADING) R.string.widget_classtable_date_loading
                            else R.string.widget_classtable_no_arrangement
                        )

                        Column(
                            modifier = GlanceModifier.fillMaxSize(),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Image(
                                provider = icon,
                                colorFilter = ColorFilter.tint(GlanceTheme.colors.primary),
                                modifier = GlanceModifier.size(72.dp),
                                contentDescription = ""
                            )
                            Spacer(modifier = GlanceModifier.size(8.dp))
                            Text(
                                textDefault, style = TextStyle(
                                    fontSize = 13.sp, color = GlanceTheme.colors.primary
                                )
                            )
                        }
                    } else {
                        val icon = ImageProvider(R.drawable.ic_classtable_error)
                        val titleText = context.getString(
                            when (status) {
                                ClassTableWidgetLoadState.ERROR_COURSE -> R.string.widget_classtable_error_course
                                ClassTableWidgetLoadState.ERROR_COURSE_USER_DEFINED -> R.string.widget_classtable_error_course_user_defined
                                ClassTableWidgetLoadState.ERROR_EXPERIMENT -> R.string.widget_classtable_error_experience
                                ClassTableWidgetLoadState.ERROR_EXAM -> R.string.widget_classtable_error_exam
                                ClassTableWidgetLoadState.ERROR_OTHER -> R.string.widget_classtable_error_other
                                else -> R.string.widget_classtable_unknown_error
                            }
                        )
                        Column(
                            modifier = GlanceModifier.fillMaxSize(),
                            horizontalAlignment = Alignment.Start,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(verticalAlignment = Alignment.Vertical.CenterVertically) {
                                Image(
                                    provider = icon,
                                    colorFilter = ColorFilter.tint(GlanceTheme.colors.primary),
                                    modifier = GlanceModifier.size(13.dp),
                                    contentDescription = ""
                                )
                                Spacer(modifier = GlanceModifier.size(4.dp))
                                Text(
                                    context.getString(
                                        R.string.widget_classtable_on_error, titleText
                                    ), style = TextStyle(
                                        fontSize = 13.sp, color = GlanceTheme.colors.primary
                                    )
                                )
                            }
                            Text(
                                errorMessage ?: context.getString(
                                    R.string.widget_classtable_unknown_error,
                                ), style = TextStyle(
                                    fontSize = 13.sp, color = GlanceTheme.colors.primary
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    @Composable
    private fun ScheduleRow(item: TimeLineItem) {
        val color = Color(indicatorColorList[item.colorIndex % indicatorColorList.size])
        val colorProvider = ColorProvider(color, color)

        Row(
            modifier = GlanceModifier.fillMaxSize().padding(6.dp).cornerRadius(8.dp)
                .background(color.copy(alpha = 0.15f)),
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            Text(
                "${item.startTimeStr}\n${item.endTimeStr}", style = TextStyle(
                    fontSize = 12.sp,
                    color = colorProvider,
                ), modifier = GlanceModifier.padding(end = 6.dp)
            )
            Spacer(
                modifier = GlanceModifier.width(6.dp).cornerRadius(4.dp)
                    .background(color.copy(alpha = 0.6f))
            )
            Column(
                modifier = GlanceModifier.defaultWeight().padding(start = 6.dp),
                verticalAlignment = Alignment.Vertical.CenterVertically,
            ) {
                Text(
                    item.name, style = TextStyle(
                        fontSize = 14.sp, color = colorProvider
                    ), maxLines = 1
                )
                Text(
                    "${item.place} ${item.teacher}", style = TextStyle(
                        fontSize = 10.sp, color = colorProvider
                    ), maxLines = 1
                )
            }

            Text(
                "${item.startTime.format(timeFormatter)}\n${item.endTime.format(timeFormatter)}",
                style = TextStyle(fontSize = 12.sp, color = colorProvider)
            )
        }
    }

    @OptIn(ExperimentalGlancePreviewApi::class)
    @Preview(widthDp = 203, heightDp = 220) // 2x2
    @Preview(widthDp = 276, heightDp = 220) // 3x2
    @Preview(widthDp = 349, heightDp = 337) // 3x2
    @Composable
    fun NoSchedulePreview() {
        ClassTableWidgetGlanceView(
            ClassTableWidgetLoadState.ERROR_COURSE_USER_DEFINED,
            "测试错误信号发出",
            -1,
            LocalDateTime.now(),
            true,
            emptyList(),
        )
    }


    @OptIn(ExperimentalGlancePreviewApi::class)
    @Preview(widthDp = 203, heightDp = 220) // 2x2
    @Preview(widthDp = 276, heightDp = 220) // 3x2
    @Preview(widthDp = 349, heightDp = 337) // 3x2
    @Composable
    fun SchedulePreview() {
        ClassTableWidgetGlanceView(
            ClassTableWidgetLoadState.FINISHED,
            "测试错误信号发出",
            -1,
            LocalDateTime.now(),
            true,
            arrayOf(
                TimeLineItem(
                    type = Source.EXAM,
                    name = "哲学课程考试",
                    teacher = "56",
                    place = "B-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 0,
                ), TimeLineItem(
                    type = Source.EXPERIMENT,
                    name = "关于对机器人进行调试和发电处理的实验课程",
                    teacher = "BenderBlog",
                    place = "B-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 1,
                ), TimeLineItem(
                    type = Source.SCHOOL,
                    name = "女装和化妆练习课",
                    teacher = "小赵",
                    place = "B-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 2,
                ), TimeLineItem(
                    type = Source.SCHOOL,
                    name = "英语课",
                    teacher = "不知道",
                    place = "EIII-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 3,
                ), TimeLineItem(
                    type = Source.SCHOOL,
                    name = "英语课",
                    teacher = "不知道",
                    place = "EIII-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 4,
                ), TimeLineItem(
                    type = Source.SCHOOL,
                    name = "英语课",
                    teacher = "不知道",
                    place = "EIII-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 5,
                )
            ).toList(),
        )
    }
}

