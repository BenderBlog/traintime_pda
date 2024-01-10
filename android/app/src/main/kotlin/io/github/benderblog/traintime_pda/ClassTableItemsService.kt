package io.github.benderblog.traintime_pda

import android.content.Intent
import android.widget.RemoteViewsService
import io.github.benderblog.traintime_pda.ClassTableItemsFactory

class ClassTableItemsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory =
        ClassTableItemsFactory(
            intent!!.getStringExtra("packageName")!!
        )
}