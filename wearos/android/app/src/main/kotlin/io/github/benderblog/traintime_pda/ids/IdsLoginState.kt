// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.ids

object IdsLoginState {
    enum class State {
        NONE,
        REQUESTING,
        SUCCESS,
        FAIL,
        PASSWORD_WRONG,
        MANUAL,
    }

    @Volatile
    var state: State = State.NONE

    val offline: Boolean
        get() = state != State.SUCCESS && state != State.MANUAL
}
