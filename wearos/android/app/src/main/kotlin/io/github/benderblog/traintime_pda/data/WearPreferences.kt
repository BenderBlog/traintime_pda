// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.data

import android.content.Context
import android.content.SharedPreferences

/**
 * Semester and display preferences.
 *
 * Keys match the former Flutter [Preference] enum so values remain readable if a
 * user upgrades from the Flutter Wear build (flutter.* prefix is also probed).
 */
class WearPreferences(context: Context) {
    private val prefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    private val flutterPrefs: SharedPreferences =
        context.applicationContext.getSharedPreferences(
            FLUTTER_PREFS_NAME,
            Context.MODE_PRIVATE,
        )

    var currentSemester: String
        get() = readString(KEY_CURRENT_SEMESTER)
        set(value) = writeString(KEY_CURRENT_SEMESTER, value)

    var agendaSwipeHintShown: Boolean
        get() = prefs.getBoolean(KEY_AGENDA_SWIPE_HINT_SHOWN, false)
        set(value) = prefs.edit().putBoolean(KEY_AGENDA_SWIPE_HINT_SHOWN, value).apply()

    var profileId: String?
        get() = prefs.getString("profileId", null)
        set(value) = prefs.edit().putString("profileId", value).apply()

    fun clearLegacyAuthentication(): Boolean {
        val keys = listOf("idsAccount", "idsPassword", "role", "idsBrowserFingerprint", "schoolCardOpenId", "schoolCardOpenIdFetchedAt")
        val existed = keys.any { prefs.contains(it) || flutterPrefs.contains("flutter.$it") }
        prefs.edit().apply { keys.forEach { remove(it) } }.apply()
        flutterPrefs.edit().apply { keys.forEach { remove("flutter.$it") } }.apply()
        return existed
    }

    fun contains(key: String): Boolean =
        prefs.contains(key) || flutterPrefs.contains("flutter.$key")

    private fun readString(key: String): String {
        val local = prefs.getString(key, null)
        if (!local.isNullOrEmpty()) return local
        return flutterPrefs.getString("flutter.$key", "") ?: ""
    }

    private fun writeString(key: String, value: String) {
        prefs.edit().putString(key, value).apply()
    }

    companion object {
        const val PREFS_NAME = "wear_app_prefs"
        private const val FLUTTER_PREFS_NAME = "FlutterSharedPreferences"
        const val KEY_CURRENT_SEMESTER = "currentSemester"
        private const val KEY_AGENDA_SWIPE_HINT_SHOWN = "agendaSwipeHintShown"
    }
}
