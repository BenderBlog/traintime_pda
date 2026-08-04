// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request
import org.jsoup.Jsoup
import java.util.concurrent.TimeUnit

class PasswordWrongException(message: String) : Exception(message)
class LoginFailedException(message: String) : Exception(message)

/**
 * Minimal IDS session used only for the school-card payment QR path.
 * Class table / experiments stay cache-only and never call this.
 */
open class IdsSession(
    protected val cookieJar: PersistentCookieJar,
    protected val username: String,
    protected val password: String,
) {
    protected val client: OkHttpClient = OkHttpClient.Builder()
        .cookieJar(cookieJar)
        .followRedirects(false)
        .followSslRedirects(false)
        .connectTimeout(20, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    private val lock = Mutex()

    suspend fun checkAndLogin(
        target: String,
        sliderCaptcha: suspend (String) -> Unit,
    ): String = lock.withLock {
        val loginUrl =
            "https://ids.xidian.edu.cn/authserver/login?service=${urlEncode(target)}&type=userNameLogin"
        val first = executeGet(loginUrl)
        if (first.code == 401) {
            throw PasswordWrongException(parsePasswordWrongMsg(first.body))
        }
        if (first.code == 301 || first.code == 302) {
            return first.location
                ?: throw LoginFailedException("登录重定向缺少 Location")
        }

        val continueForm = Jsoup.parse(first.body).select("form#continue")
        if (continueForm.isNotEmpty()) {
            val fields = mutableMapOf<String, String>()
            for (input in continueForm[0].select("input")) {
                val name = input.attr("name")
                if (name.isNotEmpty()) fields[name] = input.attr("value")
            }
            val cont = executePost(
                "https://ids.xidian.edu.cn/authserver/login",
                fields,
            )
            if (cont.code == 301 || cont.code == 302) {
                return cont.location
                    ?: throw LoginFailedException("继续登录缺少 Location")
            }
        }

        return login(
            username = username,
            password = password,
            target = target,
            sliderCaptcha = sliderCaptcha,
        )
    }

    suspend fun login(
        username: String,
        password: String,
        target: String?,
        sliderCaptcha: suspend (String) -> Unit,
    ): String {
        val query = buildString {
            append("type=userNameLogin")
            if (target != null) append("&service=").append(urlEncode(target))
        }
        val page = executeGet("https://ids.xidian.edu.cn/authserver/login?$query")
        val doc = Jsoup.parse(page.body)
        val hiddenInputs = doc.select("input[type=hidden]")

        val salt = hiddenInputs.firstOrNull { it.id() == "pwdEncryptSalt" }?.attr("value")
            ?: throw LoginFailedException("未找到密码加密盐")
        val execution = hiddenInputs.firstOrNull {
            it.attr("name") == "execution" || it.id() == "execution"
        }?.attr("value")
            ?: throw LoginFailedException("未找到 execution")

        val cookieHeader = cookieJar.loadForRequest(
            okhttp3.HttpUrl.Builder()
                .scheme("https")
                .host("ids.xidian.edu.cn")
                .addPathSegment("authserver")
                .build(),
        ).joinToString("; ") { "${it.name}=${it.value}" }

        try {
            sliderCaptcha(cookieHeader)
        } catch (_: CaptchaSolveFailedException) {
            throw LoginFailedException("验证码校验失败")
        }

        val payload = IdsCrypto.buildUsernameLoginPayload(
            username = username,
            password = password,
            salt = salt,
            execution = execution,
        )
        val postUrl = if (target != null) {
            "https://ids.xidian.edu.cn/authserver/login?service=${urlEncode(target)}"
        } else {
            "https://ids.xidian.edu.cn/authserver/login"
        }
        val data = executePost(postUrl, payload)
        val location = data.location
        if (location != null &&
            (data.code == 301 || data.code == 302 || hasCastgcCookie())
        ) {
            return location
        }

        val contForm = Jsoup.parse(data.body).select("form#continue")
        if (contForm.isNotEmpty()) {
            val fields = mutableMapOf<String, String>()
            for (input in contForm[0].select("input")) {
                val name = input.attr("name")
                if (name.isNotEmpty()) fields[name] = input.attr("value")
            }
            val cont = executePost(
                "https://ids.xidian.edu.cn/authserver/login",
                fields,
            )
            val contLocation = cont.location
            if (contLocation != null &&
                (cont.code == 301 || cont.code == 302 || hasCastgcCookie())
            ) {
                return contLocation
            }
        }
        if (data.code == 401) {
            throw PasswordWrongException(parsePasswordWrongMsg(data.body))
        }
        throw LoginFailedException("登录失败，响应状态码：${data.code}。")
    }

    fun clearCookieJar() {
        cookieJar.clear()
    }

    protected fun executeGet(url: String): HttpResult {
        val request = Request.Builder().url(url).get().build()
        client.newCall(request).execute().use { response ->
            return HttpResult(
                code = response.code,
                body = response.body?.string().orEmpty(),
                location = response.header("Location"),
            )
        }
    }

    protected fun executePost(url: String, fields: Map<String, String>): HttpResult {
        val form = FormBody.Builder().also { builder ->
            fields.forEach { (k, v) -> builder.add(k, v) }
        }.build()
        val request = Request.Builder().url(url).post(form).build()
        client.newCall(request).execute().use { response ->
            return HttpResult(
                code = response.code,
                body = response.body?.string().orEmpty(),
                location = response.header("Location"),
            )
        }
    }

    protected fun hasCastgcCookie(): Boolean =
        cookieJar.hasCookie("CASTGC")

    private fun parsePasswordWrongMsg(html: String): String {
        val form = Jsoup.parse(html).getElementById("showErrorTip")
        var msg = form?.text()?.ifBlank { null } ?: "登录遇到问题"
        if (msg.contains(Regex("(用户名|密码).*误"))) {
            msg = "用户名或密码有误"
        }
        return msg
    }

    private fun urlEncode(value: String): String =
        java.net.URLEncoder.encode(value, Charsets.UTF_8.name())

    data class HttpResult(
        val code: Int,
        val body: String,
        val location: String?,
    )

    companion object {
        private const val TAG = "IdsSession"
    }
}

/** Absolute-resolve a relative Location against the IDS host. */
fun resolveIdsLocation(location: String, base: String = "https://ids.xidian.edu.cn"): String {
    return java.net.URI(base).resolve(location).toString()
}

fun isReAuthChallenge(location: String): Boolean {
    val uri = java.net.URI(resolveIdsLocation(location))
    return uri.host == "ids.xidian.edu.cn" &&
        uri.path == "/authserver/reAuthCheck/reAuthLoginView.do"
}
