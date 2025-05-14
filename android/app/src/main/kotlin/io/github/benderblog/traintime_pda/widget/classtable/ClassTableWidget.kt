// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.widget.classtable

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.util.Log
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
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
        Log.d(tag, "onDelete() triggered on $glanceId.")
        super.onDelete(context, glanceId)
        try {
            updateAppWidgetState(context, HomeWidgetGlanceStateDefinition(), glanceId) { prefs ->
                prefs.preferences.edit {
                    remove(ClassTableWidgetKeys.SHOW_TODAY)
                }
                Log.d(tag, "Key ${ClassTableWidgetKeys.SHOW_TODAY} terminated.")
                prefs
            }
        } catch (e: Exception) {
            Log.e(tag, "Error updating state in onDelete for $glanceId: ${e.message}", e)
        }
        Log.d(tag, "Goodbye widget $glanceId.")
    }

    @Composable
    private fun Content(currentState: HomeWidgetGlanceState) {
        // 数据来源
        val context = LocalContext.current
        val glanceId = LocalGlanceId.current
        val dataProvider = remember { ClassTableWidgetDataProvider() }
        Log.d(tag, "Content triggered.")

        // 组件状态
        var currentWeekIndex by remember { mutableIntStateOf(-1) }
        var tomorrowWeekIndex by remember { mutableStateOf(-1)}
        var schedulesToday by remember { mutableStateOf<List<TimeLineItem>>(emptyList()) }
        var schedulesTomorrow by remember { mutableStateOf<List<TimeLineItem>>(emptyList()) }
        var isShowingToday by remember { mutableStateOf(false) }
        var widgetState by remember { mutableStateOf(ClassTableWidgetLoadState.LOADING) }
        var errorMessage by remember { mutableStateOf<String?>(null) }
        Log.d(tag, "Content state initialized.")

        // 获取当前日期
        val day = LocalDateTime.now()

        // 加载显示今天还是明天
        val prefs = currentState.preferences
        isShowingToday = prefs.getBoolean(ClassTableWidgetKeys.SHOW_TODAY, true)
        Log.d(tag,
            "Will load day: "+
                    "${day.format(DateTimeFormatter.ofPattern("yyyy/MM/dd"))}, " +
                    "isShowingToday: $isShowingToday."
         )

        LaunchedEffect(key1 = glanceId) {
            widgetState = ClassTableWidgetLoadState.LOADING
            errorMessage = null
            Log.d(tag, "LaunchedEffect triggered.")

            // 加载数据
            withContext(Dispatchers.IO) {
                try {
                    ClassTableDataHolder.loadData(context)
                    dataProvider.reloadData(day, context)
                } catch (e: Exception) {
                    Log.e(tag, "Error during data loading prep: ${e.message}", e)
                    errorMessage = context.getString(
                        R.string.widget_classtable_load_data_error,
                        e.localizedMessage ?: context.getString(R.string.widget_classtable_unknown_error)
                    )
                }
            }

            // 读取 ClassTableDataHolder 里面的 errorMessage
            if (errorMessage == null) {
                errorMessage = dataProvider.getErrorMessage()
                Log.e(tag, "Error during data loading prep: ${errorMessage}")
            }

            if (errorMessage != null) {
                widgetState = ClassTableWidgetLoadState.ERROR
                return@LaunchedEffect
            }

            // 加载日程
            schedulesToday = dataProvider.getTodayItems()
            schedulesTomorrow = dataProvider.getTomorrowItems()

            // 加载当前周次
            currentWeekIndex = dataProvider.getCurrentWeekIndex()
            tomorrowWeekIndex = dataProvider.getTomorrowWeekIndex()

            widgetState = ClassTableWidgetLoadState.FINISHED
            Log.d(tag, "LaunchedEffect finished.")
        }

        ClassTableWidgetGlanceView(
            widgetState,
            errorMessage,
            currentWeekIndex,
            tomorrowWeekIndex,
            day,
            isShowingToday,
            schedulesToday,
            schedulesTomorrow
        )
    }

    @Composable
    private fun ClassTableWidgetGlanceView(
        status: ClassTableWidgetLoadState,
        errorMessage: String?,
        currentWeekIndex: Int,
        tomorrowWeekIndex: Int,
        day: LocalDateTime,
        isShowingToday: Boolean,
        schedulesToday: List<TimeLineItem>,
        schedulesTomorrow: List<TimeLineItem>
    ) {
        val context = LocalContext.current

        // 根据本地化生成日期格式化器
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
            Scaffold (
                backgroundColor = GlanceTheme.colors.widgetBackground,
            ){
                Column(modifier = GlanceModifier.padding(6.dp)) {
                    // The title part
                    Row (
                        modifier =  GlanceModifier.fillMaxWidth().padding(top = 4.dp),
                        verticalAlignment = Alignment.Vertical.CenterVertically,
                    ){
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
                                "${day.plusDays(if (!isShowingToday) 1 else 0).format(formatter)} " +
                                        if (currentWeekIndex < 0)
                                            context.getString(R.string.widget_classtable_on_holiday)
                                        else
                                            context.getString(
                                                R.string.widget_classtable_week_identifier,
                                                if (isShowingToday) {
                                                    currentWeekIndex + 1
                                                } else {
                                                    tomorrowWeekIndex + 1
                                                }
                                            ),
                                style = TextStyle(
                                    fontWeight = FontWeight.Medium,
                                    fontSize = 10.sp,
                                    color = GlanceTheme.colors.primary
                                )
                            )
                        }
                        if (status != ClassTableWidgetLoadState.LOADING) {
                            Box(
                                modifier = GlanceModifier
                                    .clickable(onClick = actionRunCallback<ToggleDayAction>())
                            ) {
                                Image(
                                    provider = ImageProvider(
                                        if (isShowingToday) {
                                            R.drawable.ic_next_day
                                        }
                                        else {
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
                    val schedulesToShow = if (isShowingToday) schedulesToday else schedulesTomorrow
                    if (status == ClassTableWidgetLoadState.FINISHED && schedulesToShow.isNotEmpty()) {
                        LazyColumn(modifier = GlanceModifier.fillMaxSize().padding(vertical = 6.dp)) {
                            items(schedulesToShow.size) { item ->
                                Box(modifier = GlanceModifier.padding(
                                    bottom = if (item == schedulesToShow.size - 1) 0.dp else 6.dp)
                                ) {
                                    ScheduleRow(item = schedulesToShow[item])
                                }
                            }
                        }
                    } else {
                        // For the remaining part
                        val icon = when (status) {
                            ClassTableWidgetLoadState.LOADING -> ImageProvider(R.drawable.ic_classtable_refresh)
                            ClassTableWidgetLoadState.ERROR -> ImageProvider(R.drawable.ic_classtable_error)
                            ClassTableWidgetLoadState.FINISHED -> ImageProvider(R.drawable.ic_classtable_no_course)
                        }

                        val textDefault = when (status) {
                            ClassTableWidgetLoadState.LOADING ->
                                context.getString(R.string.widget_classtable_date_loading)
                            ClassTableWidgetLoadState.FINISHED ->
                                context.getString(R.string.widget_classtable_no_arrangement)
                            ClassTableWidgetLoadState.ERROR ->
                                context.getString(
                                    R.string.widget_classtable_on_error,
                                    errorMessage ?: context.getString(
                                        R.string.widget_classtable_unknown_error
                                    )
                                )
                        }

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
                                textDefault,
                                style = TextStyle(
                                    fontSize = 13.sp,
                                    color = GlanceTheme.colors.primary
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

        Row(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(6.dp)
                .cornerRadius(8.dp)
                .background(color.copy(alpha = 0.15f)),
            verticalAlignment = Alignment.Vertical.CenterVertically
        ) {
            Text(
                "${item.startTimeStr}\n${item.endTimeStr}",
                style = TextStyle(fontSize = 12.sp),
                modifier = GlanceModifier.padding(end = 6.dp)
            )
            Spacer(modifier =
                GlanceModifier.width(6.dp)
                    .cornerRadius(4.dp)
                    .background(color)
            )
            Column(
                modifier = GlanceModifier.defaultWeight().padding(start = 6.dp),
                verticalAlignment = Alignment.Vertical.CenterVertically,
            ) {
                Text(item.name, style = TextStyle(fontSize = 14.sp), maxLines = 1)
                Text("${item.place} ${item.teacher}", style = TextStyle(fontSize = 10.sp), maxLines = 1)
            }

            Text(
                "${item.startTime.format(timeFormatter)}\n${item.endTime.format(timeFormatter)}",
                style = TextStyle(fontSize = 12.sp)
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
            ClassTableWidgetLoadState.FINISHED,
            "测试错误信号发出",
            -1,
            -1,
            LocalDateTime.now(),
            true,
            emptyList(),
            emptyList()
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
                ),
                TimeLineItem(
                    type = Source.EXPERIMENT,
                    name = "一个超级没用但是必须要显示的实验课程哦",
                    teacher = "BenderBlog",
                    place = "B-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 1,
                ),
                TimeLineItem(
                    type = Source.SCHOOL,
                    name = "二次元绘画课",
                    teacher = "小赵",
                    place = "B-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 2,
                ),
                TimeLineItem(
                    type = Source.SCHOOL,
                    name = "英语课",
                    teacher = "不知道",
                    place = "EIII-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 3,
                ),
                TimeLineItem(
                    type = Source.SCHOOL,
                    name = "英语课",
                    teacher = "不知道",
                    place = "EIII-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 4,
                ),
                TimeLineItem(
                    type = Source.SCHOOL,
                    name = "英语课",
                    teacher = "不知道",
                    place = "EIII-102",
                    startTime = LocalDateTime.now(),
                    endTime = LocalDateTime.now(),
                    colorIndex = 5,
                )
            ).toList(),
            emptyList()
        )
    }

}

