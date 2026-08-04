// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

package io.github.benderblog.traintime_pda

import android.content.Context
import io.github.benderblog.traintime_pda.data.WearCacheStore
import io.github.benderblog.traintime_pda.data.WearPreferences
import io.github.benderblog.traintime_pda.data.WearSyncImporter
import io.github.benderblog.traintime_pda.sync.WearCompanionClient

/** Process-scoped services for the Wear app. */
class WearAppContainer(context: Context) {
    private val appContext = context.applicationContext

    val preferences = WearPreferences(appContext)
    val cache = WearCacheStore(appContext)
    val importer = WearSyncImporter(preferences, cache)
    val companionClient = WearCompanionClient(appContext, importer)

    fun needsPairing(): Boolean = !companionClient.isCompanionPaired()
}
