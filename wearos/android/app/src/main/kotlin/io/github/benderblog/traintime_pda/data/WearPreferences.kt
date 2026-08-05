// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.data

import android.content.Context
import android.content.SharedPreferences
import java.security.SecureRandom

/**
 * Credential / semester preferences.
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

    var idsAccount: String
        get() = readString(KEY_IDS_ACCOUNT)
        set(value) = writeString(KEY_IDS_ACCOUNT, value)

    var idsPassword: String
        get() = readString(KEY_IDS_PASSWORD)
        set(value) = writeString(KEY_IDS_PASSWORD, value)

    var currentSemester: String
        get() = readString(KEY_CURRENT_SEMESTER)
        set(value) = writeString(KEY_CURRENT_SEMESTER, value)

    var isPostGraduate: Boolean?
        get() = if (contains(KEY_ROLE)) readBool(KEY_ROLE) else null
        set(value) {
            if (value == null) {
                prefs.edit().remove(KEY_ROLE).apply()
            } else {
                prefs.edit().putBoolean(KEY_ROLE, value).apply()
            }
        }

    var isUserDefinedSemester: Boolean
        get() = readBool(KEY_IS_USER_DEFINED_SEMESTER)
        set(value) = prefs.edit().putBoolean(KEY_IS_USER_DEFINED_SEMESTER, value).apply()

    val schoolCardOpenId: String?
        get() = prefs.getString(KEY_SCHOOL_CARD_OPEN_ID, null)?.ifEmpty { null }

    val schoolCardOpenIdFetchedAt: Long?
        get() = if (prefs.contains(KEY_SCHOOL_CARD_OPEN_ID_FETCHED_AT)) {
            prefs.getLong(KEY_SCHOOL_CARD_OPEN_ID_FETCHED_AT, 0L).takeIf { it > 0L }
        } else {
            null
        }

    fun contains(key: String): Boolean =
        prefs.contains(key) || flutterPrefs.contains("flutter.$key")

    fun clearCredentials() {
        prefs.edit()
            .remove(KEY_IDS_ACCOUNT)
            .remove(KEY_IDS_PASSWORD)
            .remove(KEY_CURRENT_SEMESTER)
            .remove(KEY_ROLE)
            .remove(KEY_IS_USER_DEFINED_SEMESTER)
            .remove(KEY_SCHOOL_CARD_OPEN_ID)
            .remove(KEY_SCHOOL_CARD_OPEN_ID_FETCHED_AT)
            .apply()
        flutterPrefs.edit()
            .remove("flutter.$KEY_IDS_ACCOUNT")
            .remove("flutter.$KEY_IDS_PASSWORD")
            .remove("flutter.$KEY_CURRENT_SEMESTER")
            .remove("flutter.$KEY_ROLE")
            .remove("flutter.$KEY_IS_USER_DEFINED_SEMESTER")
            .apply()
    }

    fun hasPaymentCredentials(): Boolean =
        idsAccount.isNotEmpty() && idsPassword.isNotEmpty()

    fun getOrCreateIdsBrowserFingerprint(): String {
        val stored = prefs.getString(KEY_IDS_BROWSER_FINGERPRINT, null)
        if (stored != null && stored.matches(Regex("^[0-9A-F]{32}$"))) return stored
        val bytes = ByteArray(16).also { SecureRandom().nextBytes(it) }
        val generated = bytes.joinToString("") { byte -> "%02X".format(byte.toInt() and 0xFF) }
        prefs.edit().putString(KEY_IDS_BROWSER_FINGERPRINT, generated).apply()
        return generated
    }

    fun storeSchoolCardOpenId(value: String, fetchedAtEpochMs: Long) {
        prefs.edit()
            .putString(KEY_SCHOOL_CARD_OPEN_ID, value)
            .putLong(KEY_SCHOOL_CARD_OPEN_ID_FETCHED_AT, fetchedAtEpochMs)
            .apply()
    }

    fun clearSchoolCardOpenId() {
        prefs.edit()
            .remove(KEY_SCHOOL_CARD_OPEN_ID)
            .remove(KEY_SCHOOL_CARD_OPEN_ID_FETCHED_AT)
            .apply()
    }

    private fun readString(key: String): String {
        val local = prefs.getString(key, null)
        if (!local.isNullOrEmpty()) return local
        return flutterPrefs.getString("flutter.$key", "") ?: ""
    }

    private fun writeString(key: String, value: String) {
        prefs.edit().putString(key, value).apply()
    }

    private fun readBool(key: String): Boolean {
        if (prefs.contains(key)) return prefs.getBoolean(key, false)
        return flutterPrefs.getBoolean("flutter.$key", false)
    }

    companion object {
        const val PREFS_NAME = "wear_app_prefs"
        private const val FLUTTER_PREFS_NAME = "FlutterSharedPreferences"
        const val KEY_IDS_ACCOUNT = "idsAccount"
        const val KEY_IDS_PASSWORD = "idsPassword"
        const val KEY_CURRENT_SEMESTER = "currentSemester"
        const val KEY_ROLE = "role"
        const val KEY_IS_USER_DEFINED_SEMESTER = "isUserDefinedSemester"
        private const val KEY_IDS_BROWSER_FINGERPRINT = "idsBrowserFingerprint"
        private const val KEY_SCHOOL_CARD_OPEN_ID = "schoolCardOpenId"
        private const val KEY_SCHOOL_CARD_OPEN_ID_FETCHED_AT = "schoolCardOpenIdFetchedAt"
    }
}
