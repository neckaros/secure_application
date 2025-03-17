package org.jezequel.secure_application

import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.view.WindowManager.LayoutParams;
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent


/** SecureApplicationPlugin */
public class SecureApplicationPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, LifecycleObserver {
  private var activity: Activity? = null
  lateinit var instance: SecureApplicationPlugin

  override fun onDetachedFromActivity() {
    // not used for now but might be used to add some features in the future
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    if (::instance.isInitialized)
      instance.activity = binding.activity
    else
      this.activity = binding.activity
    val lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding) as Lifecycle
    lifecycle.addObserver(this)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    if (::instance.isInitialized)
      instance.activity = binding.activity
    else
      this.activity = binding.activity
    val lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding) as Lifecycle
    lifecycle.addObserver(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // not used for now but might be used to add some features in the future
  }


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    instance = SecureApplicationPlugin()
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "secure_application")
    channel.setMethodCallHandler(instance)
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
  fun connectListener() {
    // not used for now but might be used to add some features in the future
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "secure") {
      activity?.window?.addFlags(LayoutParams.FLAG_SECURE)
      result.success(true)
    } else if (call.method == "open") {
      activity?.window?.clearFlags(LayoutParams.FLAG_SECURE)
        result.success(true)
    } else {
      result.success(true)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
