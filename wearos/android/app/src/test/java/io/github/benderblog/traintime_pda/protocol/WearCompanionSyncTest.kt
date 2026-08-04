// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.protocol

import com.google.common.truth.Truth.assertThat
import io.github.benderblog.traintime_pda.data.WearCacheStore
import io.github.benderblog.traintime_pda.domain.ClassDetail
import io.github.benderblog.traintime_pda.domain.ClassTableData
import io.github.benderblog.traintime_pda.domain.Source
import io.github.benderblog.traintime_pda.domain.TimeArrangement
import io.github.benderblog.traintime_pda.domain.WearAgendaBuilder
import io.github.benderblog.traintime_pda.ids.SchoolCardSession
import org.json.JSONArray
import org.json.JSONObject
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.time.LocalDateTime
import java.util.Base64

class WearCompanionSyncTest {
    @get:Rule
    val tempFolder = TemporaryFolder()

    @Test
    fun rejectsMalformedNativeSyncPayloads() {
        val missingCredentials = JSONObject()
            .put("schemaVersion", 1)
            .put("sessionId", "session-123")
            .put(
                "schedule",
                JSONObject().put("classTable", classTableJson("缺少凭据")),
            )
        try {
            WearCompanionSyncEnvelope.fromJson(missingCredentials)
            throw AssertionError("expected WearSyncFormatException")
        } catch (_: WearSyncFormatException) {
            // expected
        }

        val missingSchedule = JSONObject()
            .put("schemaVersion", 1)
            .put("sessionId", "session-123")
            .put(
                "credentials",
                JSONObject()
                    .put("idsAccount", "2200000002")
                    .put("idsPassword", "secret"),
            )
        try {
            WearCompanionSyncEnvelope.fromJson(missingSchedule)
            throw AssertionError("expected WearSyncFormatException")
        } catch (_: WearSyncFormatException) {
            // expected
        }
    }

    @Test
    fun decodesBundledNativeSyncPayload() {
        val table = classTableJson("扫码同步课程")
        val envelope = WearCompanionSyncEnvelope.fromJson(
            JSONObject()
                .put("schemaVersion", 1)
                .put("sessionId", "session-123")
                .put(
                    "credentials",
                    JSONObject()
                        .put("idsAccount", "2200000002")
                        .put("idsPassword", "synced-secret")
                        .put("isPostGraduate", false)
                        .put("currentSemester", "fallback-term"),
                )
                .put("schedule", JSONObject().put("classTable", table))
                .put(
                    "paymentQr",
                    JSONObject()
                        .put("pngBase64", Base64.getEncoder().encodeToString(byteArrayOf(1, 2, 3)))
                        .put("fetchedAtEpochMs", 1785816000000L),
                ),
        )

        assertThat(envelope.credentials.idsAccount).isEqualTo("2200000002")
        assertThat(envelope.credentials.idsPassword).isEqualTo("synced-secret")
        assertThat(envelope.schedule.classTable.classDetail.single().name).isEqualTo("扫码同步课程")
        assertThat(envelope.paymentQr!!.bytes.toList()).containsExactly(1.toByte(), 2.toByte(), 3.toByte())
    }

    @Test
    fun cacheImportAndHomeLoadRoundTrip() {
        val root = tempFolder.newFolder("files")
        val cache = WearCacheStore(root)
        SchoolCardSession.resetOpenId()

        val table = ClassTableData(
            semesterLength = 1,
            semesterCode = "2026-1",
            termStartDay = "2026-05-18 00:00:00",
            classDetail = listOf(ClassDetail(name = "同步课程")),
            timeArrangement = listOf(
                TimeArrangement(
                    index = 0,
                    weekList = listOf(true),
                    teacher = "赵老师",
                    day = 2,
                    start = 3,
                    stop = 4,
                    source = Source.SCHOOL,
                    classroom = "A-301",
                ),
            ),
        )
        val classTableRaw = classTableJson("同步课程").toString()
        cache.writeClassTableRaw(classTableRaw)
        assertThat(cache.readClassTable()!!.classDetail.single().name).isEqualTo("同步课程")

        val home = WearAgendaBuilder.loadHomeData(
            semesterCode = "2026-1",
            classTable = cache.readClassTable(),
            experiments = null,
            now = LocalDateTime.of(2026, 5, 19, 8, 0),
        )
        assertThat(home.todayItems.map { it.title }).contains("同步课程")

        cache.writePaymentQr(byteArrayOf(9, 8, 7), 1_700_000_000_000L)
        val qr = cache.readPaymentQr()!!
        assertThat(qr.first.toList()).containsExactly(9.toByte(), 8.toByte(), 7.toByte())
        assertThat(qr.second).isEqualTo(1_700_000_000_000L)

        cache.clearCampusCaches()
        cache.clearPaymentQr()
        SchoolCardSession.resetOpenId()
        assertThat(cache.classTableExists()).isFalse()
        assertThat(cache.readPaymentQr()).isNull()
        assertThat(SchoolCardSession.openid).isEmpty()
    }

    @Test
    fun importerWritesCredentialsScheduleAndPayment() {
        // Exercise protocol + cache side of import without Android SharedPreferences.
        val root = tempFolder.newFolder("import")
        val cache = WearCacheStore(root)
        val raw = JSONObject()
            .put("schemaVersion", 1)
            .put("sessionId", "session-import")
            .put(
                "credentials",
                JSONObject()
                    .put("idsAccount", "2200000001")
                    .put("idsPassword", "new-secret")
                    .put("isPostGraduate", true)
                    .put("currentSemester", "2026-1"),
            )
            .put(
                "schedule",
                JSONObject()
                    .put("classTable", classTableJson("导入课程"))
                    .put(
                        "otherExperiments",
                        JSONArray().put(
                            JSONObject()
                                .put("type", "others")
                                .put("name", "导入实验")
                                .put("classroom", "实验楼")
                                .put(
                                    "timeRanges",
                                    JSONArray().put(
                                        JSONObject()
                                            .put("\$1", "2026-05-19T10:00:00")
                                            .put("\$2", "2026-05-19T11:00:00"),
                                    ),
                                )
                                .put("teacher", "同步老师"),
                        ),
                    ),
            )
            .put(
                "paymentQr",
                JSONObject()
                    .put("pngBase64", Base64.getEncoder().encodeToString(byteArrayOf(1, 2, 3)))
                    .put("fetchedAtEpochMs", 1785816000000L),
            )
            .toString()

        val envelope = WearCompanionSyncEnvelope.decode(raw)
        // Prefer raw schedule JSON path used by WearSyncImporter.
        cache.writeClassTableRaw(
            JSONObject(raw).getJSONObject("schedule").getJSONObject("classTable").toString(),
        )
        cache.writeExperimentsRaw(
            JSONObject(raw).getJSONObject("schedule").getJSONArray("otherExperiments").toString(),
        )
        envelope.paymentQr?.let { cache.writePaymentQr(it.bytes, it.fetchedAtEpochMs) }

        assertThat(envelope.credentials.idsAccount).isEqualTo("2200000001")
        assertThat(cache.readClassTable()!!.classDetail.single().name).isEqualTo("导入课程")
        assertThat(cache.readExperiments()!!.single().name).isEqualTo("导入实验")
        assertThat(cache.readPaymentQr()!!.first.toList())
            .containsExactly(1.toByte(), 2.toByte(), 3.toByte())
    }

    private fun classTableJson(name: String): JSONObject =
        JSONObject()
            .put("semesterLength", 1)
            .put("semesterCode", "2026-1")
            .put("termStartDay", "2026-05-18 00:00:00")
            .put(
                "classDetail",
                JSONArray().put(JSONObject().put("name", name)),
            )
            .put("userDefinedDetail", JSONArray())
            .put("notArranged", JSONArray())
            .put(
                "timeArrangement",
                JSONArray().put(
                    JSONObject()
                        .put("index", 0)
                        .put("week_list", JSONArray().put(true))
                        .put("teacher", "赵老师")
                        .put("day", 2)
                        .put("start", 3)
                        .put("stop", 4)
                        .put("source", "school")
                        .put("classroom", "A-301"),
                ),
            )
            .put("classChanges", JSONArray())
}
