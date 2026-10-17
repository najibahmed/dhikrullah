package com.bitbirds.simplymuslim

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private val alarmMethodChannel = AlarmMethodChannel(this)
    private val prayerWidgetMethodChannel = PrayerWidgetMethodChannel(this)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        alarmMethodChannel.attach(flutterEngine.dartExecutor.binaryMessenger)
        prayerWidgetMethodChannel.attach(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        prayerWidgetMethodChannel.notifyOpenRoute(intent)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        alarmMethodChannel.detach()
        prayerWidgetMethodChannel.detach()
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
