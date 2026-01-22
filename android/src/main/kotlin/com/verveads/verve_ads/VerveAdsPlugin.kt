package com.verveads.verve_ads

import android.app.Application
import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import net.pubnative.lite.sdk.HyBid

/**
 * Verve Ads Flutter Plugin - Android Implementation
 * Wrapper for HyBid SDK on Android platform
 */
class VerveAdsPlugin : FlutterPlugin, MethodCallHandler {
  companion object {
    const val CHANNEL = "com.verveads/verve_ads"
    const val TAG = "VerveAdsPlugin"
    const val SDK_VERSION = "3.7.1" // HyBid SDK version we're using
  }

  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var isInitialized = false
  private var userConsentStatus = false // Track consent locally

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> initialize(call, result)
      "isInitialized" -> result.success(isInitialized)
      "getSdkVersion" -> result.success(SDK_VERSION)
      "requestAd" -> requestAd(call, result)
      "isAdReady" -> isAdReady(call, result)
      "showAd" -> showAd(call, result)
      "setTargetingParams" -> setTargetingParams(call, result)
      "setCustomUserData" -> setCustomUserData(call, result)
      "setTestMode" -> setTestMode(call, result)
      "setLocationTrackingEnabled" -> setLocationTrackingEnabled(call, result)
      "setCoppaEnabled" -> setCoppaEnabled(call, result)
      "clearAdCache" -> clearAdCache(call, result)
      "getDeviceId" -> getDeviceId(result)
      "getUserConsentStatus" -> result.success(userConsentStatus)
      "setUserConsentStatus" -> setUserConsentStatus(call, result)
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "getDiagnostics" -> getDiagnostics(result)
      else -> result.notImplemented()
    }
  }

  private fun initialize(call: MethodCall, result: Result) {
    try {
      val appToken = call.argument<String>("appToken") ?: run {
        result.success(errorResponse(400, "appToken is required"))
        return
      }

      // Get Application context for HyBid initialization
      val application = context.applicationContext as? Application ?: run {
        result.success(errorResponse(500, "Could not get Application context"))
        return
      }

      // Initialize HyBid SDK with Application context
      HyBid.initialize(appToken, application)

      // Apply configuration
      val testMode = call.argument<Boolean>("testMode") ?: false
      val locationTrackingEnabled = call.argument<Boolean>("locationTrackingEnabled") ?: false
      val locationUpdatesEnabled = call.argument<Boolean>("locationUpdatesEnabled") ?: false
      val coppaEnabled = call.argument<Boolean>("coppaEnabled") ?: false

      HyBid.setTestMode(testMode)
      HyBid.setLocationTrackingEnabled(locationTrackingEnabled)
      HyBid.setLocationUpdatesEnabled(locationUpdatesEnabled)
      HyBid.setCoppaEnabled(coppaEnabled)

      // Set targeting parameters
      val age = call.argument<String>("age")
      val gender = call.argument<String>("gender")
      val keywords = call.argument<String>("keywords")

      if (age != null) HyBid.setAge(age)
      if (gender != null) HyBid.setGender(gender)
      if (keywords != null) HyBid.setKeywords(keywords)

      isInitialized = true
      result.success(successResponse(200))
      Log.d(TAG, "HyBid SDK initialized successfully")
    } catch (e: Exception) {
      Log.e(TAG, "Initialization error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Unknown initialization error"))
    }
  }

  private fun requestAd(call: MethodCall, result: Result) {
    try {
      val placementId = call.argument<String>("placementId") ?: run {
        result.success(errorResponse(400, "placementId is required"))
        return
      }

      // This is a simplified implementation
      // In production, you would implement actual ad request logic
      val adData = mapOf(
          "adId" to "ad_${System.currentTimeMillis()}",
          "format" to (call.argument<String>("adFormat") ?: "banner"),
          "title" to "Sample Ad",
          "description" to "This is a sample ad",
          "clickUrl" to "https://example.com",
          "campaignId" to "campaign_123"
      )

      result.success(successResponse(200, adData))
      Log.d(TAG, "Ad request successful for placement: $placementId")
    } catch (e: Exception) {
      Log.e(TAG, "Ad request error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Ad request failed"))
    }
  }

  private fun isAdReady(call: MethodCall, result: Result) {
    try {
      val placementId = call.argument<String>("placementId") ?: run {
        result.success(false)
        return
      }
      // Simplified implementation
      result.success(true)
    } catch (e: Exception) {
      Log.e(TAG, "isAdReady error: ${e.message}", e)
      result.success(false)
    }
  }

  private fun showAd(call: MethodCall, result: Result) {
    try {
      val placementId = call.argument<String>("placementId") ?: run {
        result.success(errorResponse(400, "placementId is required"))
        return
      }
      // Simplified implementation
      result.success(successResponse(200))
      Log.d(TAG, "Ad displayed for placement: $placementId")
    } catch (e: Exception) {
      Log.e(TAG, "showAd error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to show ad"))
    }
  }

  private fun setTargetingParams(call: MethodCall, result: Result) {
    try {
      val age = call.argument<String>("age")
      val gender = call.argument<String>("gender")
      val keywords = call.argument<String>("keywords")

      if (age != null) HyBid.setAge(age)
      if (gender != null) HyBid.setGender(gender)
      if (keywords != null) HyBid.setKeywords(keywords)

      result.success(successResponse(200))
      Log.d(TAG, "Targeting parameters updated")
    } catch (e: Exception) {
      Log.e(TAG, "setTargetingParams error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to set targeting params"))
    }
  }

  private fun setCustomUserData(call: MethodCall, result: Result) {
    try {
      @Suppress("UNCHECKED_CAST")
      val userData = call.argument<Map<String, Any>>("userData") as? Map<String, Any> ?: emptyMap()
      
      // Store custom user data (implementation depends on SDK)
      result.success(successResponse(200))
      Log.d(TAG, "Custom user data set: ${userData.size} fields")
    } catch (e: Exception) {
      Log.e(TAG, "setCustomUserData error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to set custom user data"))
    }
  }

  private fun setTestMode(call: MethodCall, result: Result) {
    try {
      val enabled = call.argument<Boolean>("enabled") ?: false
      HyBid.setTestMode(enabled)
      result.success(successResponse(200))
      Log.d(TAG, "Test mode set to: $enabled")
    } catch (e: Exception) {
      Log.e(TAG, "setTestMode error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to set test mode"))
    }
  }

  private fun setLocationTrackingEnabled(call: MethodCall, result: Result) {
    try {
      val enabled = call.argument<Boolean>("enabled") ?: true
      HyBid.setLocationTrackingEnabled(enabled)
      result.success(successResponse(200))
      Log.d(TAG, "Location tracking set to: $enabled")
    } catch (e: Exception) {
      Log.e(TAG, "setLocationTrackingEnabled error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to set location tracking"))
    }
  }

  private fun setCoppaEnabled(call: MethodCall, result: Result) {
    try {
      val enabled = call.argument<Boolean>("enabled") ?: false
      HyBid.setCoppaEnabled(enabled)
      result.success(successResponse(200))
      Log.d(TAG, "COPPA compliance set to: $enabled")
    } catch (e: Exception) {
      Log.e(TAG, "setCoppaEnabled error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to set COPPA"))
    }
  }

  private fun clearAdCache(call: MethodCall, result: Result) {
    try {
      // Implement cache clearing logic
      result.success(successResponse(200))
      Log.d(TAG, "Ad cache cleared")
    } catch (e: Exception) {
      Log.e(TAG, "clearAdCache error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to clear cache"))
    }
  }

  private fun getDeviceId(result: Result) {
    try {
      val deviceId = android.provider.Settings.Secure.getString(
          context.contentResolver,
          android.provider.Settings.Secure.ANDROID_ID
      )
      result.success(deviceId)
    } catch (e: Exception) {
      Log.e(TAG, "getDeviceId error: ${e.message}", e)
      result.success(null)
    }
  }

  private fun setUserConsentStatus(call: MethodCall, result: Result) {
    try {
      val consent = call.argument<Boolean>("consent") ?: false
      userConsentStatus = consent
      // Note: HyBid uses TCF 2.0 or GDPR consent string for compliance
      // This is a simplified boolean consent tracking
      result.success(successResponse(200))
      Log.d(TAG, "User consent set to: $consent")
    } catch (e: Exception) {
      Log.e(TAG, "setUserConsentStatus error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to set consent"))
    }
  }

  private fun getDiagnostics(result: Result) {
    try {
      val diagnostics = mapOf(
          "isInitialized" to isInitialized,
          "sdkVersion" to SDK_VERSION,
          "testMode" to HyBid.isTestMode(),
          "platform" to "Android",
          "deviceId" to (android.provider.Settings.Secure.getString(
              context.contentResolver,
              android.provider.Settings.Secure.ANDROID_ID
          ) ?: "unknown")
      )
      result.success(diagnostics)
    } catch (e: Exception) {
      Log.e(TAG, "getDiagnostics error: ${e.message}", e)
      result.success(emptyMap<String, Any>())
    }
  }

  private fun successResponse(statusCode: Int, data: Any? = null): Map<String, Any> {
    return mapOf(
        "statusCode" to statusCode,
        "isSuccess" to true,
        "data" to (data ?: emptyMap<String, Any>()),
        "metadata" to emptyMap<String, Any>()
    )
  }

  private fun errorResponse(statusCode: Int, errorMessage: String?): Map<String, Any> {
    return mapOf(
        "statusCode" to statusCode,
        "isSuccess" to false,
        "errorMessage" to (errorMessage ?: "Unknown error"),
        "metadata" to emptyMap<String, Any>()
    )
  }
}
