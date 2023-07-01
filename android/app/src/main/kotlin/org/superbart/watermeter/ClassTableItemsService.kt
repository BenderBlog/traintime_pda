package org.superbart.watermeter

import android.content.Intent
import android.widget.RemoteViewsService
import org.superbart.watermeter.ClassTableItemsFactory

class ClassTableItemsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory =
        ClassTableItemsFactory(
            intent!!.getStringExtra("packageName")!!,
            intent.getStringExtra("json")!!
        )
}