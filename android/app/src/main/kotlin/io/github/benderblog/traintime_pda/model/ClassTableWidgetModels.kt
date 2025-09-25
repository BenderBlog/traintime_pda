// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.model

enum class ClassTableWidgetLoadState {
    LOADING,
    ERROR_COURSE,
    ERROR_COURSE_USER_DEFINED,
    ERROR_EXPERIMENT,
    ERROR_EXAM,
    ERROR_OTHER,
    FINISHED,
}