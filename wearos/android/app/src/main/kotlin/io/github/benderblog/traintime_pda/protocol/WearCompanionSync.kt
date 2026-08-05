// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.protocol

import io.github.benderblog.traintime_pda.domain.ClassTableData
import io.github.benderblog.traintime_pda.domain.ExperimentData
import org.json.JSONObject
import java.util.Base64

/** Message paths shared with the phone companion (must stay stable). */
object WearCompanionPaths {
    const val SYNC = "/traintime_pda_wear_os/sync/v1"
    const val SYNC_ACK = "/traintime_pda_wear_os/sync/ack/v1"
    const val REQUEST = "/traintime_pda_wear_os/request/v1"
    const val PAYMENT_REQUEST = "/traintime_pda_wear_os/payment/request/v1"
    const val PAYMENT_RESPONSE = "/traintime_pda_wear_os/payment/response/v1"
    const val PREFS = "wear_companion_transport"
    const val PAIRED_PHONE_NODE_ID = "paired_phone_node_id"
    const val DIRECT_PAIRING_TTL_MS = 5 * 60 * 1000L
    const val SCHEMA_VERSION = 1
}

data class WearCredentialSyncPayload(
    val idsAccount: String,
    val idsPassword: String,
    val isPostGraduate: Boolean? = null,
    val currentSemester: String? = null,
)

data class WearScheduleSyncPayload(
    val classTable: ClassTableData,
    val otherExperiments: List<ExperimentData>? = null,
)

data class WearPaymentQrSyncPayload(
    val bytes: ByteArray,
    val fetchedAtEpochMs: Long,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is WearPaymentQrSyncPayload) return false
        return fetchedAtEpochMs == other.fetchedAtEpochMs && bytes.contentEquals(other.bytes)
    }

    override fun hashCode(): Int = 31 * bytes.contentHashCode() + fetchedAtEpochMs.hashCode()
}

data class WearCompanionSyncEnvelope(
    val sessionId: String,
    val credentials: WearCredentialSyncPayload,
    val schedule: WearScheduleSyncPayload,
    val paymentQr: WearPaymentQrSyncPayload? = null,
    val directPairing: Boolean = false,
    val generatedAtEpochMs: Long? = null,
) {
    companion object {
        fun decode(payload: String): WearCompanionSyncEnvelope =
            fromJson(JSONObject(payload))

        fun fromJson(json: JSONObject): WearCompanionSyncEnvelope {
            val version = json.optInt("schemaVersion", -1)
            if (version != WearCompanionPaths.SCHEMA_VERSION) {
                throw WearSyncFormatException("Unsupported Wear sync schema version.")
            }
            val sessionId = json.optString("sessionId", "")
            if (sessionId.isEmpty()) {
                throw WearSyncFormatException("Wear sync session is missing.")
            }
            return WearCompanionSyncEnvelope(
                sessionId = sessionId,
                credentials = parseCredentials(json.optJSONObject("credentials")),
                schedule = parseSchedule(json.optJSONObject("schedule")),
                paymentQr = parsePaymentQr(json.optJSONObject("paymentQr")),
                directPairing = json.optBoolean("directPairing", false),
                generatedAtEpochMs = if (json.has("generatedAtEpochMs")) {
                    json.getLong("generatedAtEpochMs")
                } else {
                    null
                },
            )
        }

        private fun parseCredentials(json: JSONObject?): WearCredentialSyncPayload {
            if (json == null) {
                throw WearSyncFormatException("Wear sync credentials are required.")
            }
            val account = json.optString("idsAccount", "")
            val password = json.optString("idsPassword", "")
            if (account.isEmpty() || password.isEmpty()) {
                throw WearSyncFormatException("Wear sync credentials are invalid.")
            }
            val isPostGraduate = if (json.has("isPostGraduate") && !json.isNull("isPostGraduate")) {
                json.getBoolean("isPostGraduate")
            } else {
                null
            }
            val semester = json.optString("currentSemester", "").ifEmpty { null }
            return WearCredentialSyncPayload(
                idsAccount = account,
                idsPassword = password,
                isPostGraduate = isPostGraduate,
                currentSemester = semester,
            )
        }

        private fun parseSchedule(json: JSONObject?): WearScheduleSyncPayload {
            if (json == null) {
                throw WearSyncFormatException("Wear sync schedule is required.")
            }
            val classTableJson = json.optJSONObject("classTable")
                ?: throw WearSyncFormatException("Wear sync class table is required.")
            val experimentsJson = json.optJSONArray("otherExperiments")
            val experiments = experimentsJson?.let { ExperimentData.listFromJsonArray(it) }
            return WearScheduleSyncPayload(
                classTable = ClassTableData.fromJson(classTableJson),
                otherExperiments = experiments,
            )
        }

        private fun parsePaymentQr(json: JSONObject?): WearPaymentQrSyncPayload? {
            if (json == null) return null
            val encoded = json.optString("pngBase64", "")
            if (encoded.isEmpty() || !json.has("fetchedAtEpochMs")) {
                throw WearSyncFormatException("Wear sync payment QR is invalid.")
            }
            return try {
                WearPaymentQrSyncPayload(
                    bytes = Base64.getDecoder().decode(encoded),
                    fetchedAtEpochMs = json.getLong("fetchedAtEpochMs"),
                )
            } catch (_: IllegalArgumentException) {
                throw WearSyncFormatException("Wear sync payment QR is invalid.")
            }
        }
    }
}

class WearSyncFormatException(message: String) : Exception(message)

/** Response from the phone payment proxy. */
data class WearPaymentQrResponse(
    val ok: Boolean,
    val pngBytes: ByteArray? = null,
    val fetchedAtEpochMs: Long? = null,
    val error: String? = null,
) {
    companion object {
        fun decode(payload: String): WearPaymentQrResponse {
            val json = JSONObject(payload)
            val ok = json.optBoolean("ok", false)
            if (!ok) {
                return WearPaymentQrResponse(
                    ok = false,
                    error = json.optString("error", "phone_payment_request_failed"),
                )
            }
            val encoded = json.optString("pngBase64", "")
            val fetchedAt = json.optLong("fetchedAtEpochMs", -1L)
            if (encoded.isEmpty() || fetchedAt < 0) {
                return WearPaymentQrResponse(ok = false, error = "invalid_payment_qr_response")
            }
            return WearPaymentQrResponse(
                ok = true,
                pngBytes = Base64.getDecoder().decode(encoded),
                fetchedAtEpochMs = fetchedAt,
            )
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is WearPaymentQrResponse) return false
        return ok == other.ok &&
            fetchedAtEpochMs == other.fetchedAtEpochMs &&
            error == other.error &&
            (pngBytes?.contentEquals(other.pngBytes ?: ByteArray(0)) ?: (other.pngBytes == null))
    }

    override fun hashCode(): Int {
        var result = ok.hashCode()
        result = 31 * result + (pngBytes?.contentHashCode() ?: 0)
        result = 31 * result + (fetchedAtEpochMs?.hashCode() ?: 0)
        result = 31 * result + (error?.hashCode() ?: 0)
        return result
    }
}
