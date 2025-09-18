// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.widget.classtable

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import io.github.benderblog.traintime_pda.model.ClassTableConstants
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.IOException

object ClassTableDataHolder {

    @JvmStatic
    var schoolClassJsonData: String? = null
        @Synchronized set

    @JvmStatic
    var userDefinedClassJsonData: String? = null
        @Synchronized set

    @JvmStatic
    var examJsonData: String? = null
        @Synchronized set

    @JvmStatic
    var experimentJsonData: String? = null
        @Synchronized set

    @JvmStatic
    var weekSwift: Long = 0
        @Synchronized set

    private const val TAG = "[PDA ClassTableWidget][ClassTableDataHolder]"

    suspend fun loadData(context: Context) {
        withContext(Dispatchers.IO) {
            Log.d(TAG, "Starting to load data from files...")

            schoolClassJsonData = loadFileContent(context, ClassTableConstants.CLASS_FILE_NAME)
            Log.d(TAG, "School Class JSON loaded: ${schoolClassJsonData != null}")

            examJsonData = loadFileContent(context, ClassTableConstants.EXAM_FILE_NAME)
            Log.d(TAG, "Exam JSON loaded: ${examJsonData != null}")

            userDefinedClassJsonData = loadFileContent(context, ClassTableConstants.USER_CLASS_FILE_NAME)
            Log.d(TAG, "User Class JSON loaded: ${userDefinedClassJsonData != null}")

            experimentJsonData = loadFileContent(context, ClassTableConstants.EXPERIMENT_FILE_NAME)
            Log.d(TAG, "Experiment JSON loaded: ${experimentJsonData != null}")

            Log.d(TAG, "Finished loading data from files.")

            Log.d(TAG, "Loading weekSwift from SharedPreferences...")
            try {
                val configPrefs: SharedPreferences = context.getSharedPreferences(
                    ClassTableConstants.CONFIG_SHARED_PREFS_NAME,
                    Context.MODE_PRIVATE
                )
                val loadedWeekSwift = configPrefs.getLong(
                    ClassTableConstants.CONFIG_WEEK_SWIFT_KEY,
                    0L
                )
                weekSwift = loadedWeekSwift
                Log.d(TAG, "Loaded weekSwift from SharedPreferences: $weekSwift")
            } catch (e: Exception) {
                Log.e(TAG, "Error loading weekSwift from SharedPreferences. Using default value 0L.", e)
                weekSwift = 0L
            }
            Log.d(TAG, "Finished loading weekSwift.")
        }
    }

    private fun loadFileContent(context: Context, fileName: String): String? {
        return try {
            val file = File(context.filesDir, fileName)
            if (file.exists() && file.canRead()) {
                file.readText()
            } else {
                Log.w(TAG, "File '$fileName' does not exist or cannot be read.")
                null
            }
        } catch (e: IOException) {
            Log.e(TAG, "IOException while reading file '$fileName'", e)
            null
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while reading file '$fileName'", e)
            null
        }
    }
}
