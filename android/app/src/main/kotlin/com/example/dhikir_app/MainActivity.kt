package com.example.dhikir_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private val alarmMethodChannel = AlarmMethodChannel(this)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        alarmMethodChannel.attach(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        alarmMethodChannel.detach()
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
