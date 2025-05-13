package io.github.benderblog.traintime_pda.widget.classtable

class StartDayFetchError(private val startDay: String) :
    Exception("Can not get start day from str:${startDay}")