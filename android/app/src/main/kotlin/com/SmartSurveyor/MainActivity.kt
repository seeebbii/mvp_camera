package com.SmartSurveyor

import android.annotation.SuppressLint
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "camera-app"


    @SuppressLint("ObsoleteSdkInt")
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->

            if (call.method == "openMyFiles") {
                val path = call.argument<String>("path")


                val pathFromNative = if(Build.VERSION.SDK_INT >= 10){
                    (getExternalFilesDir("")?.path ?: "") + "/" + "$path" + "/"
                }else{
                    Environment.getExternalStorageDirectory().path + "/" + "$path" +  "/"
                }

                Log.d("PATHNATIVE", pathFromNative.toString() )
                Log.d("PATH",path.toString() )
                val uri = Uri.parse(pathFromNative)

                val intent = Intent(Intent.ACTION_GET_CONTENT)

//                var intent = Intent()
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//                    intent = Intent(Intent.CATEGORY_APP_FILES)
//                } else {
//                    TODO("VERSION.SDK_INT < Q")
//                    intent = context.packageManager.getLaunchIntentForPackage("com.sec.android.app.myfiles")!!
//                }
                intent.setDataAndType(uri, "*/*");

                startActivity(intent)
                result.success("Called native function $path")
            }

        }
    }


}
