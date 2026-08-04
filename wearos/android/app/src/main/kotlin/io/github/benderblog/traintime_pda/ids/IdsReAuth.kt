// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.net.URI

class WearIDSProtocolException(message: String) : Exception(message)
class WearIDSReAuthCodeRejectedException(message: String) : Exception(message)
class WearIDSReAuthExpiredException(message: String) : Exception(message)
class WearIDSReAuthCancelledException : Exception("已取消短信认证")

data class WearIDSSmsDelivery(
    val message: String,
    val recipient: String?,
    val retryAfterSeconds: Int,
)

/**
 * IDS SMS multi-factor re-authentication for the payment path.
 */
class WearIDSReAuthClient(
    private val client: OkHttpClient,
    val challengeUri: URI,
    val username: String,
    val service: String,
) {
    var recipientDescription: String? = null
        private set

    private var prepared = false

    private val isMultifactor: String
        get() = challengeUri.query
            ?.split('&')
            ?.mapNotNull {
                val parts = it.split('=', limit = 2)
                if (parts.size == 2 && parts[0] == "isMultifactor") parts[1] else null
            }
            ?.firstOrNull()
            ?: "true"

    fun prepare() {
        if (prepared) return
        val challengeResponse = client.newCall(
            Request.Builder().url(challengeUri.toString()).get().build(),
        ).execute()
        challengeResponse.use {
            if (it.code != 200) {
                throw WearIDSReAuthExpiredException("二次认证已失效，请重新登录")
            }
        }
        val form = FormBody.Builder()
            .add("isMultifactor", isMultifactor)
            .add("reAuthType", "3")
            .add("service", service)
            .build()
        val response = client.newCall(
            Request.Builder()
                .url("https://ids.xidian.edu.cn/authserver/reAuthCheck/changeReAuthType.do")
                .post(form)
                .build(),
        ).execute()
        response.use {
            val json = responseJson(it.body?.string())
            if (json.optString("code") != "1") {
                throw WearIDSProtocolException(
                    json.optString("message").ifEmpty { "无法切换到短信二次认证" },
                )
            }
            val data = json.optJSONObject("data")
            recipientDescription = data?.optString("reAuthUserNameInput")?.ifEmpty { null }
        }
        prepared = true
    }

    fun sendSms(): WearIDSSmsDelivery {
        prepare()
        val form = FormBody.Builder()
            .add("userName", username)
            .add("authCodeTypeName", "reAuthDynamicCodeType")
            .build()
        val response = client.newCall(
            Request.Builder()
                .url(
                    "https://ids.xidian.edu.cn/authserver/dynamicCode/" +
                        "getDynamicCodeByReauth.do",
                )
                .post(form)
                .build(),
        ).execute()
        response.use {
            val json = responseJson(it.body?.string())
            val result = json.optString("res")
            if (result != "success" && result != "code_time_fail") {
                throw WearIDSProtocolException(
                    json.optString("returnMessage").ifEmpty { "短信验证码发送失败" },
                )
            }
            val rawSeconds = json.optString("codeTime").toIntOrNull() ?: 0
            val seconds = if (rawSeconds < 0) 0 else rawSeconds
            val mobile = json.optString("mobile").ifEmpty { null }
            return WearIDSSmsDelivery(
                message = json.optString("returnMessage").ifEmpty { "验证码已发送" },
                recipient = if (mobile.isNullOrEmpty()) {
                    recipientDescription
                } else {
                    maskPhoneNumber(mobile)
                },
                retryAfterSeconds = seconds,
            )
        }
    }

    fun submitSms(code: String, trustDevice: Boolean): URI {
        prepare()
        val normalized = code.trim()
        if (normalized.isEmpty()) {
            throw WearIDSReAuthCodeRejectedException("请输入短信验证码")
        }
        val form = FormBody.Builder()
            .add("service", service)
            .add("reAuthType", "3")
            .add("isMultifactor", isMultifactor)
            .add("password", "")
            .add("dynamicCode", normalized)
            .add("uuid", "")
            .add("answer1", "")
            .add("answer2", "")
            .add("otpCode", "")
            .add("skipTmpReAuth", trustDevice.toString())
            .build()
        val response = client.newCall(
            Request.Builder()
                .url("https://ids.xidian.edu.cn/authserver/reAuthCheck/reAuthSubmit.do")
                .post(form)
                .build(),
        ).execute()
        val json = response.use { responseJson(it.body?.string()) }
        when (json.optString("code")) {
            "reAuth_failed" -> throw WearIDSReAuthCodeRejectedException(
                json.optString("msg").ifEmpty { "验证码错误" },
            )
            "reAuth_unauthorized" -> throw WearIDSReAuthExpiredException(
                json.optString("msg").ifEmpty { "二次认证已失效" },
            )
            "reAuth_success" -> Unit
            else -> throw WearIDSProtocolException("统一认证返回了未知的二次认证状态")
        }

        val loginRequest = Request.Builder()
            .url(
                "https://ids.xidian.edu.cn/authserver/login?service=${
                    java.net.URLEncoder.encode(service, Charsets.UTF_8.name())
                }",
            )
            .get()
            .build()
        // Do not follow redirects so we can read Location.
        val loginClient = client.newBuilder()
            .followRedirects(false)
            .followSslRedirects(false)
            .build()
        loginClient.newCall(loginRequest).execute().use { loginResponse ->
            val location = loginResponse.header("Location")
            if ((loginResponse.code != 301 && loginResponse.code != 302) || location == null) {
                throw WearIDSProtocolException("二次认证成功，但没有收到业务系统登录票据")
            }
            val uri = URI("https://ids.xidian.edu.cn").resolve(location)
            if (uri.host == "ids.xidian.edu.cn" &&
                uri.path == "/authserver/reAuthCheck/reAuthLoginView.do"
            ) {
                throw WearIDSReAuthExpiredException("二次认证未完成，请重新登录")
            }
            return uri
        }
    }

    private fun responseJson(data: String?): JSONObject {
        if (data.isNullOrBlank()) {
            throw WearIDSProtocolException("统一认证返回了非 JSON 响应")
        }
        return try {
            JSONObject(data)
        } catch (_: Exception) {
            throw WearIDSProtocolException("统一认证返回了非 JSON 响应")
        }
    }

    companion object {
        fun maskPhoneNumber(value: String): String {
            if (value.length < 7) return "****"
            return value.take(3) + "****" + value.takeLast(4)
        }
    }
}
