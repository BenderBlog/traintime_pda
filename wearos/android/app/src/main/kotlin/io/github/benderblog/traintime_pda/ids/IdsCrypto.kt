// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec

/**
 * IDS AES-CBC helpers matching the Go / Dart login payload:
 * 64-byte fixed prefix, fixed 16-dot IV, PKCS5/7 padding, Base64 output.
 */
object IdsCrypto {
    const val PASSWORD_PREFIX =
        "................................................................"
    const val FIXED_IV = "................"
    private const val CAPTCHA_KEY_SIZE = 16

    fun aesEncrypt(toEnc: String, key: String): String {
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        val keySpec = SecretKeySpec(key.toByteArray(Charsets.UTF_8), "AES")
        val ivSpec = IvParameterSpec(FIXED_IV.toByteArray(Charsets.UTF_8))
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec)
        val encrypted = cipher.doFinal((PASSWORD_PREFIX + toEnc).toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(encrypted)
    }

    fun encryptCaptchaPayload(payload: String, keyBytes: ByteArray): String {
        require(keyBytes.size >= CAPTCHA_KEY_SIZE) {
            "Captcha image is too short to contain AES key."
        }
        val key = keyBytes.copyOfRange(keyBytes.size - CAPTCHA_KEY_SIZE, keyBytes.size)
        val cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
        val keySpec = SecretKeySpec(key, "AES")
        val ivSpec = IvParameterSpec(FIXED_IV.toByteArray(Charsets.UTF_8))
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec)
        val encrypted = cipher.doFinal((PASSWORD_PREFIX + payload).toByteArray(Charsets.UTF_8))
        return Base64.getEncoder().encodeToString(encrypted)
    }

    fun buildUsernameLoginPayload(
        username: String,
        password: String,
        salt: String,
        execution: String,
    ): Map<String, String> = mapOf(
        "username" to username,
        "password" to aesEncrypt(password, salt),
        "rememberMe" to "true",
        "cllt" to "userNameLogin",
        "dllt" to "generalLogin",
        "_eventId" to "submit",
        "captcha" to "",
        "lt" to "",
        "execution" to execution,
    )
}
