// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

import com.google.common.truth.Truth.assertThat
import org.junit.Test

class IdsCryptoTest {
    @Test
    fun passwordEncryptionMatchesGoIdsLoginPayload() {
        assertThat(IdsCrypto.aesEncrypt("secret", "1234567890abcdef"))
            .isEqualTo(
                "Y2fkMlmY/KyUHnWiA9lVrnC8HHWUFePOo/JLpbpV/XfZ/zE6Tk2WrZMyCYY1f9ael+nb8OZB4B2EmFM6G18SWNpKTmuSEP0PjuxgVXBdI90=",
            )
    }

    @Test
    fun usernameLoginPayloadMatchesGoIdsFields() {
        val payload = IdsCrypto.buildUsernameLoginPayload(
            username = "2200000000",
            password = "secret",
            salt = "1234567890abcdef",
            execution = "exec-token",
        )
        assertThat(payload).containsExactlyEntriesIn(
            mapOf(
                "username" to "2200000000",
                "password" to
                    "Y2fkMlmY/KyUHnWiA9lVrnC8HHWUFePOo/JLpbpV/XfZ/zE6Tk2WrZMyCYY1f9ael+nb8OZB4B2EmFM6G18SWNpKTmuSEP0PjuxgVXBdI90=",
                "rememberMe" to "true",
                "cllt" to "userNameLogin",
                "dllt" to "generalLogin",
                "_eventId" to "submit",
                "captcha" to "",
                "lt" to "",
                "execution" to "exec-token",
            ),
        )
    }

    @Test
    fun captchaPayloadEncryptionMatchesGoShape() {
        val key = "1234567890abcdef".toByteArray(Charsets.UTF_8)
        val payload =
            """{"canvasLength":280,"moveLength":42,"tracks":[{"a":0,"b":0,"c":0},{"a":42,"b":0,"c":900}]}"""
        assertThat(IdsCrypto.encryptCaptchaPayload(payload, key)).isEqualTo(
            "Y2fkMlmY/KyUHnWiA9lVrnC8HHWUFePOo/JLpbpV/XfZ/zE6Tk2WrZMyCYY1f9ael+nb8OZB4B2EmFM6G18SWMo6nGxXZr4TTOiHUUTFXkeQQVaF2RoG1CsaDxyrQkchEx7YVCH+3fSUlX8CKpybb7jJnIbccr2rP1538MId2OLPck1g1XaCwAOtLK+LyyKILKYdFAT061XHTpBZZfvJOg==",
        )
    }
}
