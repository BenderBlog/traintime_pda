package io.github.benderblog.traintime_pda.widget.classtable

import android.content.Intent
import android.widget.RemoteViewsService
import io.github.benderblog.traintime_pda.model.ClassTableConstants
import io.github.benderblog.traintime_pda.model.ClassTableWidgetKeys
import kotlinx.coroutines.Dispatchers
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