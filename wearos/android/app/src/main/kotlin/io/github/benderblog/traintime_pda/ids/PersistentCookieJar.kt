// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

import okhttp3.Cookie
import okhttp3.CookieJar
import okhttp3.HttpUrl
import java.io.File
import java.util.concurrent.ConcurrentHashMap

/**
 * Simple host-scoped cookie jar persisted under [storageDir].
 * Used only for the payment-code IDS session on the watch.
 */
class PersistentCookieJar(private val storageDir: File) : CookieJar {
    private val memory = ConcurrentHashMap<String, MutableList<Cookie>>()

    init {
        storageDir.mkdirs()
        loadFromDisk()
    }

    @Synchronized
    override fun saveFromResponse(url: HttpUrl, cookies: List<Cookie>) {
        val host = url.host
        val bucket = memory.getOrPut(host) { mutableListOf() }
        for (cookie in cookies) {
            bucket.removeAll { it.name == cookie.name && it.path == cookie.path }
            if (cookie.expiresAt > System.currentTimeMillis()) {
                bucket.add(cookie)
            }
        }
        persistHost(host)
    }

    @Synchronized
    override fun loadForRequest(url: HttpUrl): List<Cookie> {
        val now = System.currentTimeMillis()
        val result = mutableListOf<Cookie>()
        for ((host, cookies) in memory) {
            if (!url.host.endsWith(host) && host != url.host) continue
            val alive = cookies.filter { it.expiresAt > now && it.matches(url) }
            result += alive
        }
        return result
    }

    @Synchronized
    fun clear() {
        memory.clear()
        if (storageDir.exists()) {
            storageDir.listFiles()?.forEach { it.delete() }
        }
    }

    fun hasCookie(name: String, hostHint: String = "ids.xidian.edu.cn"): Boolean {
        val cookies = memory[hostHint] ?: return false
        return cookies.any { it.name == name && it.expiresAt > System.currentTimeMillis() }
    }

    private fun persistHost(host: String) {
        val file = File(storageDir, host.replace('.', '_') + ".cookies")
        val cookies = memory[host].orEmpty()
        file.writeText(
            cookies.joinToString("\n") { cookie ->
                listOf(
                    cookie.name,
                    cookie.value,
                    cookie.domain,
                    cookie.path,
                    cookie.expiresAt.toString(),
                    cookie.secure.toString(),
                    cookie.httpOnly.toString(),
                ).joinToString("\t")
            },
        )
    }

    private fun loadFromDisk() {
        val files = storageDir.listFiles() ?: return
        for (file in files) {
            try {
                val lines = file.readLines().filter { it.isNotBlank() }
                for (line in lines) {
                    val parts = line.split('\t')
                    if (parts.size < 7) continue
                    val builder = Cookie.Builder()
                        .name(parts[0])
                        .value(parts[1])
                        .domain(parts[2])
                        .path(parts[3])
                        .expiresAt(parts[4].toLong())
                    if (parts[5].toBoolean()) builder.secure()
                    if (parts[6].toBoolean()) builder.httpOnly()
                    val cookie = builder.build()
                    memory.getOrPut(parts[2]) { mutableListOf() }.add(cookie)
                }
            } catch (_: Exception) {
                // Ignore corrupt cookie files.
            }
        }
    }
}
