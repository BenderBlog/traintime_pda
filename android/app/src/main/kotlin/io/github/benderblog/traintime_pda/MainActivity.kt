package io.github.benderblog.traintime_pda

import android.os.Build
import android.os.Bundle
import android.view.RoundedCorner
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.github.benderblog.traintime_pda.liveupdate.CourseLiveUpdateChannel


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge display
        WindowCompat.enableEdgeToEdge(window)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // The physical corners of the screen are not part of the window insets,
        // so Flutter cannot know about them. Content sitting right at the edge
        // (e.g. the last row of the classtable) would be covered by the rounded
        // corner of the display.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DISPLAY_INSETS_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getRoundedCornerRadii" -> result.success(roundedCornerRadii())
                else -> result.notImplemented()
            }
        }

        // Live Updates (a.k.a. the "Super Island" of some vendors) for the
        // class which is going on.
        CourseLiveUpdateChannel.register(flutterEngine, applicationContext)
    }

    /// Radii of the four corners of the display, in logical pixels.
    ///
    /// A window which does not cover the whole screen — a floating window, a
    /// split screen — does not reach the corners of the display, so nothing
    /// there can cover the content of the app. Reporting the corners anyway
    /// would only take the little room such a window has.
    private fun roundedCornerRadii(): Map<String, Double> {
        val corners = mutableMapOf(
            "topLeft" to 0.0,
            "topRight" to 0.0,
            "bottomLeft" to 0.0,
            "bottomRight" to 0.0,
        )
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || isInMultiWindowMode) {
            return corners
        }

        val density = resources.displayMetrics.density.toDouble().takeIf { it > 0 } ?: 1.0
        val insets = window?.decorView?.rootWindowInsets ?: return corners

        fun radiusOf(position: Int): Double {
            val corner = insets.getRoundedCorner(position) ?: return 0.0
            val radius = corner.radius
            return if (radius > 0) radius / density else 0.0
        }

        corners["topLeft"] = radiusOf(RoundedCorner.POSITION_TOP_LEFT)
        corners["topRight"] = radiusOf(RoundedCorner.POSITION_TOP_RIGHT)
        corners["bottomLeft"] = radiusOf(RoundedCorner.POSITION_BOTTOM_LEFT)
        corners["bottomRight"] = radiusOf(RoundedCorner.POSITION_BOTTOM_RIGHT)
        return corners
    }

    companion object {
        private const val DISPLAY_INSETS_CHANNEL = "xdyou/display_insets"
    }
}
