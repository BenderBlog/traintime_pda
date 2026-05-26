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
import java.io.FileNotFoundException
import java.io.IOException

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

object ClassTableDataHolder {

    @JvmStatic
    var isLoggedIn: Boolean = false
        @Synchronized set

    @JvmStatic
    var schoolClassJsonData: Result<String> = Result.success("")
        @Synchronized set

    @JvmStatic
    var userDefinedClassJsonData: Result<String?> = Result.success(null)
        @Synchronized set

    @JvmStatic
    var examJsonData: Result<String> = Result.success("")
        @Synchronized set

    @JvmStatic
    var physicsExperimentJsonData: Result<String?> = Result.success(null)
        @Synchronized set

    @JvmStatic
    var otherExperimentJsonData: Result<String?> = Result.success(null)
        @Synchronized set

    @JvmStatic
    var weekSwift: Long = 0
        @Synchronized set

    private const val TAG = "[PDA ClassTableWidget][ClassTableDataHolder]"

    suspend fun loadData(context: Context) {
        withContext(Dispatchers.IO) {
            Log.i(TAG, "Starting to load data from files...")

            // Check login state first
            isLoggedIn = try {
                val stateFile = File(context.filesDir, ClassTableConstants.WIDGET_STATE_FILE_NAME)
                if (!stateFile.exists()) {
                    Log.w(TAG, "WidgetState.json not found, treating as not logged in")
                    false
                } else {
                    val json = Json.parseToJsonElement(stateFile.readText())
                    json.jsonObject["loggedIn"]?.jsonPrimitive?.boolean ?: false
                }
            } catch (e: Exception) {
                Log.w(TAG, "Failed to parse WidgetState.json: ${e.message}")
                false
            }
            Log.i(TAG, "isLoggedIn: $isLoggedIn")
            if (!isLoggedIn) {
                Log.i(TAG, "User is not logged in, skip loading data")
                return@withContext
            }

            schoolClassJsonData = loadFileContent(
                context, ClassTableConstants.CLASS_FILE_NAME
            )
            Log.i(
                TAG,
                "School Class JSON loaded, isSuccess: ${schoolClassJsonData.isSuccess}, " + "length: ${schoolClassJsonData.getOrNull()?.length ?: 0}"
            )

            examJsonData = loadFileContent(
                context, ClassTableConstants.EXAM_FILE_NAME
            )
            Log.i(
                TAG,
                "Exam JSON loaded, isSuccess: ${examJsonData.isSuccess}, " + "length: ${examJsonData.getOrNull()?.length ?: 0}"
            )

            userDefinedClassJsonData = loadFileContent(
                context, ClassTableConstants.USER_CLASS_FILE_NAME
            ).fold(onSuccess = { Result.success(it) }, onFailure = {
                if (it is FileNotFoundException) {
                    Result.success(null)
                } else {
                    Result.failure(it)
                }
            })
            Log.i(
                TAG,
                "User Class JSON loaded, isSuccess: ${userDefinedClassJsonData.isSuccess} " + "length: ${userDefinedClassJsonData.getOrNull()?.length ?: 0}"
            )

            physicsExperimentJsonData = loadFileContent(
                context, ClassTableConstants.PHYSICS_EXPERIMENT_FILE_NAME
            ).fold(onSuccess = { Result.success(it) }, onFailure = {
                if (it is FileNotFoundException) {
                    Result.success(null)
                } else {
                    Result.failure(it)
                }
            })
            Log.i(
                TAG,
                "Physics Experiment JSON loaded, isSuccess: ${physicsExperimentJsonData.isSuccess} " + "length: ${physicsExperimentJsonData.getOrNull()?.length ?: 0}"
            )

            otherExperimentJsonData = loadFileContent(
                context, ClassTableConstants.OTHER_EXPERIMENT_FILE_NAME
            ).fold(onSuccess = { Result.success(it) }, onFailure = {
                if (it is FileNotFoundException) {
                    Result.success(null)
                } else {
                    Result.failure(it)
                }
            })
            Log.i(
                TAG,
                "Other Experiment JSON loaded, isSuccess: ${otherExperimentJsonData.isSuccess} " + "length: ${otherExperimentJsonData.getOrNull()?.length ?: 0}"
            )

            Log.i(TAG, "Finished loading data from files.")

            Log.i(TAG, "Loading weekSwift from SharedPreferences...")
            try {
                val configPrefs: SharedPreferences = context.getSharedPreferences(
                    ClassTableConstants.CONFIG_SHARED_PREFS_NAME, Context.MODE_PRIVATE
                )
                val loadedWeekSwift = configPrefs.getLong(
                    ClassTableConstants.CONFIG_WEEK_SWIFT_KEY, 0L
                )
                weekSwift = loadedWeekSwift
                Log.i(TAG, "Loaded weekSwift from SharedPreferences: $weekSwift")
            } catch (e: Exception) {
                Log.w(
                    TAG,
                    "Error loading weekSwift from SharedPreferences. Using default value 0L.",
                    e
                )
                weekSwift = 0L
            }
            Log.i(TAG, "Finished loading weekSwift.")
        }
    }

    private fun loadFileContent(context: Context, fileName: String): Result<String> {
        return try {
            val file = File(context.filesDir, fileName)
            if (!file.exists()) {
                return Result.failure(FileNotFoundException())
            }
            if (!file.canRead()) {
                return Result.failure(
                    IOException(
                        "File '$fileName' cannot be read."
                    )
                )
            }
            val text = file.readText()
            Log.i(TAG, "Text length: ${text.length}")
            Result.success(text)
        } catch (e: IOException) {
            Log.e(TAG, "IOException while reading file '$fileName'", e)
            Result.failure(e)
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error while reading file '$fileName'", e)
            Result.failure(e)
        }
    }
}
