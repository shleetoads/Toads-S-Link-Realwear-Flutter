package com.toads.toads_s_link.realwear.realwear_flutter

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File


class MainActivity: FlutterActivity(){
    
    private val CHANNEL = "ToadsSLink"


    private val ACTION_SPEECH_EVENT = "com.realwear.wearhf.intent.action.SPEECH_EVENT"
    private val EXTRA_RESULT = "command"

    private lateinit var methodChannel: MethodChannel

    private val speechReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == ACTION_SPEECH_EVENT) {

                val command = intent.getStringExtra(EXTRA_RESULT)
                Log.d("recog", command.toString())

                methodChannel.invokeMethod("onReceive", mapOf("command" to command))

            }
        }
    }

    override fun onResume() {
        super.onResume()
        ContextCompat.registerReceiver(
            this, // context
            speechReceiver,
            IntentFilter(ACTION_SPEECH_EVENT),
            ContextCompat.RECEIVER_EXPORTED // 외부 브로드캐스트 수신
        )
    }

    override fun onPause() {
        super.onPause()
        // 브로드캐스트 리시버 해제
        unregisterReceiver(speechReceiver)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        )

        methodChannel.setMethodCallHandler { call, mcResult ->
            when (call.method){
                "refreshMedia" -> {
                    val path: String? = call.argument("path")
                    mcResult.success(refreshMedia((path)));
                }
                else -> {
                    mcResult.notImplemented();
                }
            }

        }
    }


    private fun refreshMedia(path: String?): String {
        return try {
            /// Throw NPE if path is empty/null
            if (path == null)
                throw NullPointerException()
            val file = File(path)
            /// Check if still using sendBroadcast or MediaScannerConnection
            if (android.os.Build.VERSION.SDK_INT < 29) {
                context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file)))
            } else {
                MediaScannerConnection.scanFile(context, arrayOf(file.toString()),
                    arrayOf(file.name), null)
            }
            Log.d("Media Scanner", "Success show image $path in Gallery")
            "Success show image $path in Gallery"  } catch (e: Exception) {
            Log.e("Media Scanner", e.toString())
            e.toString()
        }

    }

}
