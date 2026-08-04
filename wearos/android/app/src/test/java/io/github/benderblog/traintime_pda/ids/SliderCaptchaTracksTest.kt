// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

import com.google.common.truth.Truth.assertThat
import org.junit.Test
import kotlin.random.Random

class SliderCaptchaTracksTest {
    @Test
    fun generateAutoTracksEndsAtTarget() {
        val tracks = SliderCaptchaClient.generateAutoTracks(42, Random(0))
        assertThat(tracks).isNotEmpty()
        assertThat(tracks.first().a).isEqualTo(0)
        assertThat(tracks.last().a).isEqualTo(42)
        assertThat(tracks.zipWithNext().all { (a, b) -> b.a >= a.a }).isTrue()
    }

    @Test
    fun maskPhoneNumberKeepsPrefixAndSuffix() {
        assertThat(WearIDSReAuthClient.maskPhoneNumber("13812345678"))
            .isEqualTo("138****5678")
        assertThat(WearIDSReAuthClient.maskPhoneNumber("12")).isEqualTo("****")
    }
}
