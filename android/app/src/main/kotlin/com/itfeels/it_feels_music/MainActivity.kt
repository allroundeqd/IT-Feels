package com.itfeels.it_feels_music

import android.app.ActivityManager
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Intent
import android.media.audiofx.AudioEffect

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.itfeels.it_feels_music/device_info"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isLowRamDevice") {
                val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                result.success(activityManager.isLowRamDevice)
            } else if (call.method == "openSystemEqualizer") {
                val intent = Intent(AudioEffect.ACTION_DISPLAY_AUDIO_EFFECT_CONTROL_PANEL)
                val audioSessionId = call.argument<Int>("audioSessionId") ?: 0
                intent.putExtra(AudioEffect.EXTRA_AUDIO_SESSION, audioSessionId)
                intent.putExtra(AudioEffect.EXTRA_PACKAGE_NAME, packageName)
                intent.putExtra(AudioEffect.EXTRA_CONTENT_TYPE, AudioEffect.CONTENT_TYPE_MUSIC)
                
                try {
                    startActivityForResult(intent, 0)
                    result.success(true)
                } catch (e: Exception) {
                    // Not all devices have a system equalizer installed
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
