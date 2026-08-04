// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

import android.util.Log
import okhttp3.Request
import org.jsoup.Jsoup
import java.net.URI
import java.util.Base64
import java.util.concurrent.TimeUnit

/**
 * School-card virtual QR. Only network path allowed on the watch besides Data Layer.
 */
class SchoolCardSession(
    cookieJar: PersistentCookieJar,
    username: String,
    password: String,
) : IdsSession(cookieJar, username, password) {
    /**
     * Optional SMS re-auth handler. Returns the post-reauth location URI.
     * When null and re-auth is required, [WearIDSReAuthExpiredException] is thrown.
     */
    suspend fun authenticateWithStoredCredentials(
        reAuthHandler: (suspend (WearIDSReAuthClient) -> URI)? = null,
    ) {
        if (IdsLoginState.state == IdsLoginState.State.SUCCESS && isOpenIdValid) return

        IdsLoginState.state = IdsLoginState.State.REQUESTING
        try {
            // Reuse the persisted IDS cookie after process restarts. This avoids
            // a full password + slider + SMS flow for every payment-code refresh.
            if (hasCastgcCookie()) {
                try {
                    ensureOpenId(forceRefresh = true)
                    IdsLoginState.state = IdsLoginState.State.SUCCESS
                    return
                } catch (_: Exception) {
                    resetOpenId()
                }
            }
            clearCookieJar()
            val idsService = discoverIdsService()
            var location = checkAndLogin(
                target = idsService,
                sliderCaptcha = { cookie ->
                    SliderCaptchaClient(client, cookie).solveAutomatically()
                },
            )
            val redirectUri = URI(resolveIdsLocation(location))
            if (isReAuthChallenge(location)) {
                val handler = reAuthHandler
                    ?: throw WearIDSReAuthExpiredException("需要短信二次认证")
                val reAuthClient = WearIDSReAuthClient(
                    client = client,
                    challengeUri = redirectUri,
                    username = username,
                    service = idsService,
                )
                location = handler(reAuthClient).toString()
            }
            var response = executeGet(resolveIdsLocation(location))
            var current = resolveIdsLocation(location)
            while (!response.location.isNullOrEmpty()) {
                current = URI(current).resolve(response.location!!).toString()
                response = executeGet(current)
            }
            captureOpenId(response.body)
            IdsLoginState.state = IdsLoginState.State.SUCCESS
        } catch (e: PasswordWrongException) {
            IdsLoginState.state = IdsLoginState.State.PASSWORD_WRONG
            throw e
        } catch (e: Exception) {
            IdsLoginState.state = IdsLoginState.State.FAIL
            throw e
        }
    }

    fun getQRCode(): ByteArray = withOpenIdRetry {
        val homeUrl = "https://v8scan.xidian.edu.cn/home/openHomePage?openid=$openid"
        val homeBody = executeGetFollow(homeUrl)
        val homeDoc = Jsoup.parse(homeBody)
        var id: String? = null
        for (a in homeDoc.select("a")) {
            val href = a.attr("href")
            if (href.contains("/virtualcard/openVirtualcard") && href.contains("id=")) {
                val uri = URI(href.replace("&amp;", "&"))
                // href may be relative
                val query = uri.rawQuery ?: URI("https://v8scan.xidian.edu.cn$href")
                    .rawQuery
                id = query?.split('&')
                    ?.map { it.split('=', limit = 2) }
                    ?.firstOrNull { it.size == 2 && it[0] == "id" }
                    ?.get(1)
                if (!id.isNullOrEmpty()) break
            }
        }
        if (id.isNullOrEmpty()) throw Exception("aTag id not found.")

        val qrUrl =
            "https://v8scan.xidian.edu.cn/virtualcard/openVirtualcard?" +
                "openid=$openid&displayflag=1&id=$id"
        val qrBody = executeGetFollow(qrUrl)
        val qrDoc = Jsoup.parse(qrBody)
        val img = qrDoc.getElementById("qrcode")
            ?: throw Exception("QR image not found.")
        var src = img.attr("src")
        val base64Data = src
            .replace("data:image/png;base64,", "")
            .replace("\n", "")
        if (base64Data.isEmpty()) throw Exception("QR data is empty.")
        Base64.getDecoder().decode(base64Data)
    }

    private fun withOpenIdRetry(action: () -> ByteArray): ByteArray {
        ensureOpenId()
        return try {
            action()
        } catch (e: Exception) {
            Log.w(TAG, "Request failed, retry with refreshed openid.", e)
            ensureOpenId(forceRefresh = true)
            action()
        }
    }

    private fun ensureOpenId(forceRefresh: Boolean = false) {
        if (!forceRefresh && isOpenIdValid) return
        resetOpenId()
        var response = executeGetFollowResult(OPEN_OAUTH_URL)
        // follow already done; capture from final HTML
        captureOpenId(response)
    }

    private fun captureOpenId(html: String) {
        val inputs = Jsoup.parse(html).select("input")
        for (input in inputs) {
            if (input.id() == "openid" && input.attr("type") == "hidden") {
                openid = input.attr("value")
                break
            }
        }
        if (openid.isEmpty()) throw Exception("School card openid not found.")
        openidFetchedAt = System.currentTimeMillis()
    }

    private fun discoverIdsService(): String {
        // Use a no-cookie client to discover the service URL without polluting session.
        val probe = OkHttpNoCookie()
        var currentUrl = OPEN_OAUTH_URL
        var response = probe.get(currentUrl)
        repeat(10) {
            val nextHeader = response.location ?: return@repeat
            val nextUrl = URI(currentUrl).resolve(nextHeader).toString()
            val nextUri = URI(nextUrl)
            if (nextUri.host == "ids.xidian.edu.cn" &&
                nextUri.path.endsWith("/authserver/login")
            ) {
                val service = nextUri.query
                    ?.split('&')
                    ?.map { it.split('=', limit = 2) }
                    ?.firstOrNull { it.size == 2 && it[0] == "service" }
                    ?.get(1)
                    ?.let { java.net.URLDecoder.decode(it, Charsets.UTF_8.name()) }
                if (!service.isNullOrEmpty()) return service
            }
            currentUrl = nextUrl
            response = probe.get(currentUrl)
        }
        throw Exception("School card IDS service not found.")
    }

    private fun executeGetFollow(url: String): String {
        var current = url
        var response = executeGet(current)
        var hops = 0
        while (!response.location.isNullOrEmpty() && hops < 15) {
            current = URI(current).resolve(response.location!!).toString()
            response = executeGet(current)
            hops++
        }
        return response.body
    }

    private fun executeGetFollowResult(url: String): String = executeGetFollow(url)

    private class OkHttpNoCookie {
        private val client = okhttp3.OkHttpClient.Builder()
            .followRedirects(false)
            .followSslRedirects(false)
            .connectTimeout(20, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build()

        fun get(url: String): HttpResult {
            val request = Request.Builder().url(url).get().build()
            client.newCall(request).execute().use { response ->
                return HttpResult(
                    code = response.code,
                    body = response.body?.string().orEmpty(),
                    location = response.header("Location"),
                )
            }
        }
    }

    companion object {
        private const val TAG = "SchoolCardSession"
        private const val OPEN_OAUTH_URL =
            "https://v8scan.xidian.edu.cn/home/openXDOAuth2Page"
        private const val OPENID_VALID_MS = 5 * 60 * 1000L

        @Volatile
        var openid: String = ""
            private set

        @Volatile
        private var openidFetchedAt: Long? = null

        val isOpenIdValid: Boolean
            get() = openid.isNotEmpty() &&
                openidFetchedAt != null &&
                System.currentTimeMillis() - openidFetchedAt!! < OPENID_VALID_MS

        fun resetOpenId() {
            openid = ""
            openidFetchedAt = null
        }
    }
}
