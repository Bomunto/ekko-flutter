package com.bomunto.ekko_flutter

import android.app.Activity
import android.app.Application
import android.content.Context
import android.net.Uri
import com.bomunto.ekko.Ekko
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** Routes the three ekko calls to the native Android SDK. */
class EkkoFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var activity: Activity? = null

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "bomunto.ekko")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "configure" -> {
        val publicKey = call.argument<String>("publicKey")
        if (publicKey == null) {
          result.error("args", "publicKey manquante", null)
          return
        }
        val baseUrl = call.argument<String>("baseUrl") ?: "https://ekko.bomunto.com"
        Ekko.configure(context.applicationContext as Application, publicKey, baseUrl, activity)
        result.success(null)
      }
      "present" -> {
        Ekko.present()
        result.success(null)
      }
      "identifyTester" -> {
        call.argument<String>("token")?.let { Ekko.identifyTester(it) }
        result.success(null)
      }
      "handle" -> {
        val url = call.argument<String>("url")
        result.success(if (url == null) false else Ekko.handle(Uri.parse(url)))
      }
      "screen" -> {
        call.argument<String>("name")?.let { Ekko.screen(it) }
        result.success(null)
      }
      "log" -> {
        val message = call.argument<String>("message")
        if (message != null) Ekko.log(message, call.argument<String>("level") ?: "info")
        result.success(null)
      }
      "recordRequest" -> {
        val method = call.argument<String>("method")
        val url = call.argument<String>("url")
        if (method != null && url != null) {
          Ekko.recordRequest(method, url, call.argument<Int>("status"), call.argument<Int>("durationMs"))
        }
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
