package com.toads.toads_s_link.realwear.realwear_flutter

import android.content.Intent
import android.media.MediaScannerConnection
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File


class MainActivity: FlutterActivity(){
    
    private val CHANNEL = "ToadsSLink"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, mcResult ->
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
