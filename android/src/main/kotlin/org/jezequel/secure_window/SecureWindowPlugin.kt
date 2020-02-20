package org.jezequel.secure_window

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.view.WindowManager.LayoutParams;

/** SecureWindowPlugin */
public class SecureWindowPlugin: FlutterPlugin, MethodCallHandler {
  private final Activity activity;

  private MyPlugin(Activity activity) {
    this.activity = activity;
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "secure_window")
    channel.setMethodCallHandler(SecureWindowPlugin(registrar.activity()));
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "secure_window")
      channel.setMethodCallHandler(SecureWindowPlugin(registrar.activity()))
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "secure") {
      getWindow().addFlags(LayoutParams.FLAG_SECURE)
      result.success(true)
    } else if (call.method == "open") {
      getWindow().removeFlags(LayoutParams.FLAG_SECURE)
      result.success(true)
    } else {
      result.success(true)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
