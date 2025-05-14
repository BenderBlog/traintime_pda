// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.widget.classtable

import HomeWidgetGlanceWidgetReceiver

class ClassTableWidgetReceiver : HomeWidgetGlanceWidgetReceiver<ClassTableWidget>() {
    override val glanceAppWidget = ClassTableWidget()
}