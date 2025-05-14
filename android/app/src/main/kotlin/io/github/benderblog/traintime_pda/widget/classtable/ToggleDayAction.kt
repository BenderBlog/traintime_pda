// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda.widget.classtable

import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.util.Log
import androidx.core.content.edit
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.state.updateAppWidgetState
import io.github.benderblog.traintime_pda.model.ClassTableWidgetKeys

class ToggleDayAction : ActionCallback {

    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        Log.d("[PDA ClassTableWidget][ToggleDayAction]", "ToggleDayAction triggered for $glanceId")

        updateAppWidgetState(
            context,
            HomeWidgetGlanceStateDefinition(),
            glanceId
        ) { prefs ->
            val currentIsShowToday = prefs.preferences
                .getBoolean(ClassTableWidgetKeys.SHOW_TODAY, true)
            Log.d("[PDA ClassTableWidget][ToggleDayAction]", "Current showToday value: $currentIsShowToday")

            val newIsShowToday = !currentIsShowToday
            Log.d("[PDA ClassTableWidget][ToggleDayAction]", "New showToday value: $newIsShowToday")

            prefs.preferences.edit {
                putBoolean(ClassTableWidgetKeys.SHOW_TODAY, newIsShowToday)
            }
            Log.d("[PDA ClassTableWidget][ToggleDayAction]", "Set showToday value to: $newIsShowToday")

            prefs
        }

        ClassTableWidget().update(context, glanceId)
    }
}