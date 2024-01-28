package io.github.benderblog.traintime_pda.utils

import java.util.Calendar
import java.util.Date

fun Date.toCalendar(): Calendar = Calendar.getInstance().apply {
    time = this@toCalendar
}

val Calendar.year: Int
    get() = get(Calendar.YEAR)

val Calendar.month: Int
    get() = get(Calendar.MONTH)

val Calendar.day: Int
    get() = get(Calendar.DAY_OF_MONTH)