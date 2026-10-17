package io.github.benderblog.traintime_pda

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.github.benderblog.traintime_pda.liveupdate.CourseLiveUpdateChannel


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Enable edge-to-edge display
        WindowCompat.enableEdgeToEdge(window)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Live Updates (a.k.a. the "Super Island" of some vendors) for the
        // class which is going on.
        CourseLiveUpdateChannel.register(flutterEngine, applicationContext)
    }
}
