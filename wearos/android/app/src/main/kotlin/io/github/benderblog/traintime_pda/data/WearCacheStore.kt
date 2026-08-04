// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.data

import android.content.Context
import io.github.benderblog.traintime_pda.domain.ClassTableData
import io.github.benderblog.traintime_pda.domain.ExperimentData
import org.json.JSONArray
import java.io.File

/**
 * Local schedule / payment caches under [Context.getFilesDir], matching the
 * Flutter Wear paths (`ClassTable.json`, `OtherExperiment.json`, `WearPaymentQr.png`).
 */
class WearCacheStore(private val root: File) {
    constructor(context: Context) : this(context.applicationContext.filesDir)

    val classTableFile: File get() = File(root, CLASS_TABLE_FILE)
    val experimentFile: File get() = File(root, EXPERIMENT_FILE)
    val paymentQrFile: File get() = File(root, PAYMENT_QR_FILE)
    val cookieDir: File get() = File(root, "cookie/general")

    fun writeClassTable(data: ClassTableData, rawJson: String? = null) {
        // Prefer the original phone JSON when available to avoid re-serialization drift.
        if (rawJson != null) {
            writeClassTableRaw(rawJson)
        } else {
            // Minimal write — phone always sends full JSON; used mainly in tests.
            writeClassTableRaw(
                org.json.JSONObject()
                    .put("semesterLength", data.semesterLength)
                    .put("semesterCode", data.semesterCode)
                    .put("termStartDay", data.termStartDay)
                    .put("classDetail", org.json.JSONArray())
                    .put("userDefinedDetail", org.json.JSONArray())
                    .put("notArranged", org.json.JSONArray())
                    .put("timeArrangement", org.json.JSONArray())
                    .put("classChanges", org.json.JSONArray())
                    .toString(),
            )
        }
    }

    fun writeClassTableRaw(rawJson: String) {
        writeAtomically(classTableFile, rawJson.toByteArray())
    }

    fun readClassTable(): ClassTableData? {
        if (!classTableFile.exists()) return null
        return try {
            ClassTableData.fromJsonString(classTableFile.readText())
        } catch (_: Exception) {
            null
        }
    }

    fun writeExperimentsRaw(rawJson: String) {
        writeAtomically(experimentFile, rawJson.toByteArray())
    }

    fun writeExperiments(list: List<ExperimentData>) {
        // Tests / local writes only — phone import uses writeExperimentsRaw.
        val array = JSONArray()
        writeExperimentsRaw(array.toString())
    }

    fun readExperiments(): List<ExperimentData>? {
        if (!experimentFile.exists()) return null
        return try {
            ExperimentData.listFromJsonArray(JSONArray(experimentFile.readText()))
        } catch (_: Exception) {
            null
        }
    }

    fun writePaymentQr(bytes: ByteArray, fetchedAtEpochMs: Long) {
        writeAtomically(paymentQrFile, bytes)
        paymentQrFile.setLastModified(fetchedAtEpochMs)
    }

    fun readPaymentQr(): Pair<ByteArray, Long>? {
        if (!paymentQrFile.exists()) return null
        return try {
            paymentQrFile.readBytes() to paymentQrFile.lastModified()
        } catch (_: Exception) {
            null
        }
    }

    fun clearPaymentQr() {
        if (paymentQrFile.exists()) paymentQrFile.delete()
    }

    fun clearCampusCaches() {
        if (classTableFile.exists()) classTableFile.delete()
        if (experimentFile.exists()) experimentFile.delete()
    }

    fun clearIdsCookies() {
        if (cookieDir.exists()) cookieDir.deleteRecursively()
    }

    fun classTableExists(): Boolean = classTableFile.exists()

    private fun writeAtomically(target: File, bytes: ByteArray) {
        target.parentFile?.mkdirs()
        val temporary = File(target.parentFile, ".${target.name}.tmp")
        temporary.outputStream().use { stream ->
            stream.write(bytes)
            stream.flush()
            stream.fd.sync()
        }
        if (!temporary.renameTo(target)) {
            target.delete()
            check(temporary.renameTo(target)) { "Unable to replace ${target.name}" }
        }
    }

    companion object {
        const val CLASS_TABLE_FILE = "ClassTable.json"
        const val EXPERIMENT_FILE = "OtherExperiment.json"
        const val PAYMENT_QR_FILE = "WearPaymentQr.png"
    }
}
