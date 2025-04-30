package com.aboutyou.dart_packages.sign_in_with_apple

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.Log

val TAG = "SignInWithApple"

class SignInWithApplePlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
    private val CUSTOM_TABS_REQUEST_CODE = 1001
    private var channel: MethodChannel? = null
    private var binding: ActivityPluginBinding? = null

    companion object {
        var lastAuthorizationRequestResult: Result? = null
        var triggerMainActivityToHideChromeCustomTab: (() -> Unit)? = null
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.aboutyou.dart_packages.sign_in_with_apple")
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isAvailable" -> result.success(true)
            "performAuthorizationRequest" -> {
                val activity = binding?.activity
                if (activity == null) {
                    result.error("MISSING_ACTIVITY", "Plugin is not attached to an activity", call.arguments)
                    return
                }

                val url: String? = call.argument("url")
                if (url == null) {
                    result.error("MISSING_ARG", "Missing 'url' argument", call.arguments)
                    return
                }

                lastAuthorizationRequestResult?.error(
                    "NEW_REQUEST",
                    "A new request came in while this was still pending. The previous request (this one) was then cancelled.",
                    null
                )

                triggerMainActivityToHideChromeCustomTab?.invoke()

                lastAuthorizationRequestResult = result
                triggerMainActivityToHideChromeCustomTab = {
                    val notificationIntent = activity.packageManager.getLaunchIntentForPackage(activity.packageName)
                    notificationIntent?.setPackage(null)
                    notificationIntent?.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
                    activity.startActivity(notificationIntent)
                }

                val builder = CustomTabsIntent.Builder()
                val customTabsIntent = builder.build()
                customTabsIntent.intent.data = Uri.parse(url)

                activity.startActivityForResult(
                    customTabsIntent.intent,
                    CUSTOM_TABS_REQUEST_CODE,
                    customTabsIntent.startAnimationBundle
                )
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
        binding.addActivityResultListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        binding?.removeActivityResultListener(this)
        binding = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == CUSTOM_TABS_REQUEST_CODE) {
            lastAuthorizationRequestResult?.error(
                "authorization-error/canceled",
                "The user closed the Custom Tab",
                null
            )
            lastAuthorizationRequestResult = null
            triggerMainActivityToHideChromeCustomTab = null
        }
        return false
    }
}

class SignInWithAppleCallback : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val lastResult = SignInWithApplePlugin.lastAuthorizationRequestResult
        if (lastResult != null) {
            lastResult.success(intent?.data?.toString())
            SignInWithApplePlugin.lastAuthorizationRequestResult = null
        } else {
            SignInWithApplePlugin.triggerMainActivityToHideChromeCustomTab = null
            Log.e(TAG, "Received Sign in with Apple callback, but 'lastAuthorizationRequestResult' was null")
        }

        SignInWithApplePlugin.triggerMainActivityToHideChromeCustomTab?.let {
            it()
            SignInWithApplePlugin.triggerMainActivityToHideChromeCustomTab = null
        } ?: Log.e(TAG, "Received Sign in with Apple callback, but 'triggerMainActivityToHideChromeCustomTab' was null")

        finish()
    }
}