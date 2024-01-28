package io.github.benderblog.traintime_pda

import android.content.Intent
import android.os.Environment
import android.util.Log
import android.widget.RemoteViewsService
import io.github.benderblog.traintime_pda.ClassTableItemsFactory
import io.github.benderblog.traintime_pda.model.ClassTableConstants
import io.github.benderblog.traintime_pda.model.ClassTableWidgetKeys
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.channels.produce
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileReader

class ClassTableItemsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent?): RemoteViewsFactory = runBlocking {
        withContext(Dispatchers.IO) {
            try {
                File(filesDir, ClassTableConstants.CLASS_FILE_NAME).run {
                    if (exists())
                        ClassTableItemsFactory.classJsonData = run {
                            FileReader(this).readText()
                        }
                }
                File(filesDir, ClassTableConstants.EXAM_FILE_NAME).run {
                    if (exists())
                        ClassTableItemsFactory.examJsonData = run {
                            FileReader(this).readText()
                        }
                }

            } catch (e: Exception) {
                // not readable file or other errors
                // just ignore and regard it as empty data file
                e.printStackTrace()
            }
        }
        ClassTableItemsFactory(
            intent!!.getStringExtra(ClassTableWidgetKeys.PACKAGE_NAME)!!,
            applicationContext
        )
    }
}