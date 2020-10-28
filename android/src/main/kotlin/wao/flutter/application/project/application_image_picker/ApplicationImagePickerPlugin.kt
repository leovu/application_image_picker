package wao.flutter.application.project.application_image_picker

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

/** ApplicationImagePickerPlugin */
class ApplicationImagePickerPlugin: FlutterPlugin, MethodCallHandler , ActivityAware , PluginRegistry.RequestPermissionsResultListener{

  private val RequestPermissionChannel = "flutter.io/requestPermission"
  private val CheckPermissionChannel = "flutter.io/checkPermission"

  private lateinit var pendingResult: MethodChannel.Result

  private val REQUEST_PERMISSION = 100
  private val REQUEST_CAMERA_PERMISSION = 101
  private val REQUEST_LOCATION_PERMISSION = 102
  private val REQUEST_RECORD_AUDIO_PERMISSION = 103
  private val REQUEST_STORAGE_PERMISSION = 104

  private lateinit var requestChannel : MethodChannel
  private lateinit var checkChannel : MethodChannel

  private lateinit var context: Context
  private lateinit var activity: Activity

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    requestChannel = MethodChannel(flutterPluginBinding.binaryMessenger, RequestPermissionChannel)
    requestChannel.setMethodCallHandler { call, result ->
      pendingResult = result
      when (call.method) {
        "camera" -> {
          handlePermission(result, arrayOf(Manifest.permission.CAMERA), REQUEST_CAMERA_PERMISSION)
        }
        "location" -> {
          handlePermission(result, arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION), REQUEST_LOCATION_PERMISSION)
        }
        "record_audio" -> {
          handlePermission(result, arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_RECORD_AUDIO_PERMISSION)
        }
        "storage" -> {
          handlePermission(result, arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), REQUEST_STORAGE_PERMISSION)
        }
      }
    }
    checkChannel = MethodChannel(flutterPluginBinding.binaryMessenger, CheckPermissionChannel)
    checkChannel.setMethodCallHandler { call, result ->
      when (call.method) {
        "camera" -> {
          handlePermission(result, arrayOf(Manifest.permission.CAMERA), 0)
        }
        "location" -> {
          handlePermission(result, arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION), 0)
        }
        "record_audio" -> {
          handlePermission(result, arrayOf(Manifest.permission.RECORD_AUDIO), 0)
        }
        "storage" -> {
          handlePermission(result, arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), 0)
        }
      }
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {}

  private fun handlePermission(result: MethodChannel.Result, permissions: Array<String>, keyRequest: Int){
    var granted = true
    for(it: String in permissions){
      if (ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED) {
        granted = false
        break
      }
    }
    if (granted) {
      result.success(1)
    }
    else{
      if(keyRequest == 0){
        result.success(0)
      }
      else{
        ActivityCompat.requestPermissions(activity,
                permissions,
                keyRequest)
      }
    }
  }
  private fun handleRequestPermissionsResult(permissions: Array<String>, grantResults: IntArray, isLocation: Boolean){
    val permissionGranted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
    if (!permissionGranted) {
      var shouldShowRequest = true
      for(it: String in permissions){
        if (!ActivityCompat.shouldShowRequestPermissionRationale(activity, it)) {
          shouldShowRequest = false
          break
        }
      }
      if(shouldShowRequest)
        pendingResult.success(0)
      else
        pendingResult.success(-1)
    }
    else{
      pendingResult.success(1)
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
    when (requestCode) {
      REQUEST_LOCATION_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION), grantResults, true)
      }
      REQUEST_CAMERA_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.CAMERA), grantResults, false)
      }
      REQUEST_RECORD_AUDIO_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.RECORD_AUDIO), grantResults, false)
      }
      REQUEST_STORAGE_PERMISSION -> {
        handleRequestPermissionsResult(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE), grantResults, false)
      }
    }
    return false
  }

  override fun onDetachedFromActivity() {
//    TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//    TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
//    TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    checkChannel.setMethodCallHandler(null)
    requestChannel.setMethodCallHandler(null)
  }
}
