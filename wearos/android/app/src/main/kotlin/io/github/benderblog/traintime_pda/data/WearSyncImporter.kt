// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.data

import io.github.benderblog.traintime_pda.ids.IdsLoginState
import io.github.benderblog.traintime_pda.ids.SchoolCardSession
import io.github.benderblog.traintime_pda.protocol.WearCompanionSyncEnvelope
import io.github.benderblog.traintime_pda.protocol.WearCredentialSyncPayload
import io.github.benderblog.traintime_pda.protocol.WearPaymentQrSyncPayload
import io.github.benderblog.traintime_pda.protocol.WearScheduleSyncPayload
import org.json.JSONObject

/**
 * Imports a phone-produced envelope into local prefs + file caches.
 * Schedule is never fetched by the watch; only this path updates it.
 */
class WearSyncImporter(
    private val preferences: WearPreferences,
    private val cache: WearCacheStore,
) {
    fun importEnvelope(envelope: WearCompanionSyncEnvelope, rawPayload: String? = null) {
        importCredentials(envelope.credentials)
        importSchedule(envelope.schedule, rawPayload)
        envelope.paymentQr?.let { importPaymentQr(it) }
    }

    fun importCredentials(payload: WearCredentialSyncPayload) {
        val accountChanged = preferences.idsAccount != payload.idsAccount
        if (accountChanged) {
            clearUserScopedState(clearPaymentQr = true)
        }
        preferences.idsAccount = payload.idsAccount
        preferences.idsPassword = payload.idsPassword
        payload.isPostGraduate?.let { preferences.isPostGraduate = it }
        val semester = payload.currentSemester
        if (!semester.isNullOrEmpty()) {
            preferences.currentSemester = semester
            preferences.isUserDefinedSemester = false
        }
    }

    fun importSchedule(payload: WearScheduleSyncPayload, rawPayload: String? = null) {
        val rawClassTable = rawPayload?.let {
            try {
                JSONObject(it).optJSONObject("schedule")?.optJSONObject("classTable")?.toString()
            } catch (_: Exception) {
                null
            }
        }
        if (rawClassTable != null) {
            cache.writeClassTableRaw(rawClassTable)
        } else {
            cache.writeClassTable(payload.classTable)
        }
        if (payload.classTable.semesterCode.isNotEmpty()) {
            preferences.currentSemester = payload.classTable.semesterCode
            preferences.isUserDefinedSemester = false
        }

        val experiments = payload.otherExperiments
        if (experiments != null) {
            val rawExperiments = rawPayload?.let {
                try {
                    JSONObject(it).optJSONObject("schedule")
                        ?.optJSONArray("otherExperiments")
                        ?.toString()
                } catch (_: Exception) {
                    null
                }
            }
            if (rawExperiments != null) {
                cache.writeExperimentsRaw(rawExperiments)
            } else {
                cache.writeExperiments(experiments)
            }
        }
    }

    fun importPaymentQr(payload: WearPaymentQrSyncPayload) {
        cache.writePaymentQr(payload.bytes, payload.fetchedAtEpochMs)
    }

    fun logout() {
        preferences.clearCredentials()
        cache.clearIdsCookies()
        SchoolCardSession.resetOpenId()
        cache.clearCampusCaches()
        cache.clearPaymentQr()
        IdsLoginState.state = IdsLoginState.State.MANUAL
    }

    private fun clearUserScopedState(clearPaymentQr: Boolean) {
        cache.clearIdsCookies()
        SchoolCardSession.resetOpenId()
        cache.clearCampusCaches()
        if (clearPaymentQr) cache.clearPaymentQr()
        IdsLoginState.state = IdsLoginState.State.NONE
        preferences.currentSemester = ""
        preferences.isPostGraduate = null
        preferences.isUserDefinedSemester = false
    }
}
