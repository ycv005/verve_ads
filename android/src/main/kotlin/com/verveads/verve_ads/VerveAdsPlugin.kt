package com.verveads.verve_ads

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import net.pubnative.lite.sdk.HyBid
import net.pubnative.lite.sdk.interstitial.HyBidInterstitialAd
import net.pubnative.lite.sdk.rewarded.HyBidRewardedAd
import net.pubnative.lite.sdk.HyBidError

/**
 * Verve Ads Flutter Plugin - Android Implementation
 * Wrapper for HyBid SDK on Android platform
 * 
 * Supported Ad Formats:
 * - Interstitial: Full-screen ads using HyBidInterstitialAd
 * - Rewarded: Rewarded video ads using HyBidRewardedAd
 * - Banner/MRect/Leaderboard: View-based ads (require PlatformView - see BannerAdViewFactory)
 * 
 * Architecture:
 * - MethodChannel for request/response operations
 * - EventChannel for streaming ad events (impression, click, reward, etc.)
 * - Zone ID is the primary identifier for all ad operations
 */
class VerveAdsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  companion object {
    const val METHOD_CHANNEL = "com.verveads/verve_ads"
    const val EVENT_CHANNEL = "com.verveads/verve_ads_events"
    const val TAG = "VerveAdsPlugin"
    const val SDK_VERSION = "3.7.1"
  }

  // ==================== Error Code Constants ====================
  // Real HyBid SDK error codes (1–25) from HyBidErrorCode.java:
  //   https://github.com/pubnative/pubnative-hybid-android-sdk/blob/main/
  //   hybid.sdk/src/main/java/net/pubnative/lite/sdk/HyBidErrorCode.java
  //
  // Plugin-level codes (100+) for errors originating in our layer.

  object VerveErrorCode {
    // ── HyBid SDK error codes (1–25) ────────────────────────────
    const val NO_FILL = 1
    const val PARSER_ERROR = 2
    const val SERVER_ERROR = 3
    const val INVALID_ASSET = 4
    const val UNSUPPORTED_ASSET = 5
    const val NULL_AD = 6
    const val INVALID_AD = 7
    const val INVALID_ZONE_ID = 8
    const val INVALID_SIGNAL_DATA = 9   // also OUT_OF_MEMORY, INVALID_VIEW_BINDER
    const val NOT_INITIALISED = 10
    const val AUCTION_NO_AD = 11
    const val ERROR_RENDERING_BANNER = 12
    const val ERROR_RENDERING_INTERSTITIAL = 13
    const val ERROR_RENDERING_REWARDED = 14
    const val MRAID_PLAYER_ERROR = 15
    const val VAST_PLAYER_ERROR = 16
    const val ERROR_TRACKING_URL = 17
    const val ERROR_TRACKING_JS = 18
    const val INVALID_URL = 19
    const val INTERNAL_ERROR = 20
    const val UNKNOWN_ERROR = 21
    const val DISABLED_FORMAT = 22
    const val DISABLED_RENDERING_ENGINE = 23
    const val EXPIRED_AD = 24
    const val ERROR_LOADING_FEEDBACK = 25

    // ── Plugin-level error codes (100+) ─────────────────────────
    const val MISSING_REQUIRED_PARAMETER = 100
    const val UNSUPPORTED_AD_FORMAT = 101
    const val ACTIVITY_NOT_AVAILABLE = 102
    const val AD_NOT_READY = 103
    const val APPLICATION_CONTEXT_UNAVAILABLE = 104
    const val PLUGIN_EXCEPTION = 105
    const val UNKNOWN = 999

    /**
     * Extract the real HyBid error code from a load-failure [Throwable].
     *
     * The HyBid SDK passes [HyBidError] instances (which wrap [HyBidErrorCode])
     * to the onLoadFailed callbacks. We cast to [HyBidError] and read
     * [HyBidErrorCode.getCode()] to get the native integer.
     *
     * Falls back to [UNKNOWN_ERROR] if the throwable is not a [HyBidError].
     */
    fun extractFromThrowable(error: Throwable?): Int {
      if (error is HyBidError) {
        return error.errorCode?.code ?: UNKNOWN_ERROR
      }
      // Fallback: not a HyBidError, return generic unknown
      return UNKNOWN_ERROR
    }
  }

  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel
  private lateinit var context: Context
  private var activity: Activity? = null
  private var isInitialized = false
  private var userConsentStatus = false
  private var eventSink: EventChannel.EventSink? = null
  private val mainHandler = Handler(Looper.getMainLooper())

  // Store loaded ads by zone ID
  private val interstitialAds = mutableMapOf<String, HyBidInterstitialAd>()
  private val rewardedAds = mutableMapOf<String, HyBidRewardedAd>()

  // ==================== Flutter Plugin Lifecycle ====================

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    
    // Setup Method Channel
    methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
    methodChannel.setMethodCallHandler(this)
    
    // Setup Event Channel for ad events
    eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
      }
      override fun onCancel(arguments: Any?) {
        eventSink = null
      }
    })
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    destroyAllAds()
  }

  // ==================== Activity Lifecycle ====================

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    // Do NOT null out activity here.
    // When HyBid's MraidInterstitialActivity launches, it triggers
    // a config change detach. Nulling activity here causes the
    // onInterstitialDismissed event to be silently dropped because
    // sendAdEvent uses activity?.runOnUiThread which becomes a no-op.
    // The activity reference will be updated in onReattachedToActivity.
    Log.d(TAG, "Activity detached for config changes (keeping reference)")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
    destroyAllAds()
  }

  // ==================== Method Handling ====================

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      // SDK Lifecycle
      "initialize" -> initialize(call, result)
      "isInitialized" -> result.success(isInitialized)
      "getSdkVersion" -> result.success(SDK_VERSION)
      
      // Ad Operations
      "requestAd" -> requestAd(call, result)
      "isAdReady" -> isAdReady(call, result)
      "showAd" -> showAd(call, result)
      "destroyAd" -> destroyAd(call, result)
      
      // Targeting & Configuration
      "setTargetingParams" -> setTargetingParams(call, result)
      "setCustomUserData" -> setCustomUserData(call, result)
      "setTestMode" -> setTestMode(call, result)
      "setLocationTrackingEnabled" -> setLocationTrackingEnabled(call, result)
      "setCoppaEnabled" -> setCoppaEnabled(call, result)
      
      // Cache & Device
      "clearAdCache" -> clearAdCache(result)
      "getDeviceId" -> getDeviceId(result)
      
      // Privacy
      "getUserConsentStatus" -> result.success(userConsentStatus)
      "setUserConsentStatus" -> setUserConsentStatus(call, result)
      
      // Diagnostics
      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      "getDiagnostics" -> getDiagnostics(result)
      
      else -> result.notImplemented()
    }
  }

  // ==================== Event Helpers ====================

  /**
   * Send ad event to Flutter via EventChannel
   * Events are structured as: { "type": "...", "zoneId": "...", "data": {...} }
   */
  private fun sendAdEvent(type: String, zoneId: String, data: Map<String, Any?>? = null) {
    val event = mutableMapOf<String, Any?>(
      "type" to type,
      "zoneId" to zoneId,
      "timestamp" to System.currentTimeMillis()
    )
    if (data != null) {
      event["data"] = data
    }

    // Use activity.runOnUiThread if available, otherwise fall back to
    // mainHandler.post to guarantee delivery even when the Flutter
    // activity has been temporarily detached (e.g. during MRAID
    // interstitial activity transitions).
    val runnable = Runnable {
      eventSink?.success(event)
    }
    val currentActivity = activity
    if (currentActivity != null) {
      currentActivity.runOnUiThread(runnable)
    } else {
      mainHandler.post(runnable)
    }
    Log.d(TAG, "Ad event: $type for zone: $zoneId")
  }

  // Ad Event Types
  object AdEventType {
    const val LOADED = "loaded"
    const val LOAD_FAILED = "loadFailed"
    const val IMPRESSION = "impression"
    const val CLICK = "click"
    const val OPENED = "opened"
    const val CLOSED = "closed"
    const val DISMISSED = "dismissed"
    const val REWARD = "reward"
  }

  // ==================== SDK Initialization ====================

  private fun initialize(call: MethodCall, result: Result) {
    try {
      val appToken = call.argument<String>("appToken") ?: run {
        result.success(errorResponse(400, "appToken is required", VerveErrorCode.MISSING_REQUIRED_PARAMETER))
        return
      }

      val application = context.applicationContext as? Application ?: run {
        result.success(errorResponse(500, "Could not get Application context", VerveErrorCode.APPLICATION_CONTEXT_UNAVAILABLE))
        return
      }

      // Initialize HyBid SDK
      HyBid.initialize(appToken, application)

      // Apply configuration
      call.argument<Boolean>("testMode")?.let { HyBid.setTestMode(it) }
      call.argument<Boolean>("locationTrackingEnabled")?.let { HyBid.setLocationTrackingEnabled(it) }
      call.argument<Boolean>("locationUpdatesEnabled")?.let { HyBid.setLocationUpdatesEnabled(it) }
      call.argument<Boolean>("coppaEnabled")?.let { HyBid.setCoppaEnabled(it) }

      // Set targeting if provided
      call.argument<String>("age")?.let { HyBid.setAge(it) }
      call.argument<String>("gender")?.let { HyBid.setGender(it) }
      call.argument<String>("keywords")?.let { HyBid.setKeywords(it) }

      isInitialized = true
      result.success(successResponse(200))
      Log.d(TAG, "HyBid SDK initialized successfully")
    } catch (e: Exception) {
      Log.e(TAG, "Initialization error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Unknown initialization error", VerveErrorCode.PLUGIN_EXCEPTION))
    }
  }

  // ==================== Ad Request ====================

  private fun requestAd(call: MethodCall, result: Result) {
    try {
      val zoneId = call.argument<String>("zoneId") ?: run {
        result.success(errorResponse(400, "zoneId is required", VerveErrorCode.MISSING_REQUIRED_PARAMETER))
        return
      }

      val adFormat = call.argument<String>("adFormat") ?: "banner"
      val currentActivity = activity ?: run {
        result.success(errorResponse(500, "Activity not available", VerveErrorCode.ACTIVITY_NOT_AVAILABLE))
        return
      }

      when (adFormat) {
        "interstitial" -> loadInterstitialAd(zoneId, currentActivity, result)
        "rewarded" -> loadRewardedAd(zoneId, currentActivity, result)
        "banner", "medium_rectangle", "leaderboard", "native" -> {
          // Banner-type ads require PlatformView implementation
          // Return info about how to use them
          val adData = mapOf(
            "adId" to "${adFormat}_$zoneId",
            "format" to adFormat,
            "zoneId" to zoneId,
            "title" to "${adFormat.replaceFirstChar { it.uppercase() }} Ad",
            "description" to "Use HyBidBannerView widget for banner display",
            "requiresPlatformView" to true,
            "clickUrl" to "",
            "campaignId" to ""
          )
          result.success(successResponse(200, adData))
          Log.d(TAG, "$adFormat ad request for zone: $zoneId - requires PlatformView")
        }
        else -> {
          result.success(errorResponse(400, "Unsupported ad format: $adFormat", VerveErrorCode.UNSUPPORTED_AD_FORMAT))
        }
      }
    } catch (e: Exception) {
      Log.e(TAG, "Ad request error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Ad request failed", VerveErrorCode.PLUGIN_EXCEPTION))
    }
  }

  private fun loadInterstitialAd(zoneId: String, activity: Activity, result: Result) {
    // Destroy any existing ad for this zone
    interstitialAds[zoneId]?.destroy()
    interstitialAds.remove(zoneId)

    val interstitialAd = HyBidInterstitialAd(activity, zoneId,
      object : HyBidInterstitialAd.Listener {
        override fun onInterstitialLoaded() {
          Log.d(TAG, "Interstitial loaded for zone: $zoneId")
          val adData = createAdResponseData(zoneId, "interstitial", isReady = true)
          result.success(successResponse(200, adData))
          sendAdEvent(AdEventType.LOADED, zoneId)
        }

        override fun onInterstitialLoadFailed(error: Throwable?) {
          val errCode = VerveErrorCode.extractFromThrowable(error)
          Log.e(TAG, "Interstitial load failed for zone $zoneId [errorCode=$errCode]: ${error?.message}")
          interstitialAds.remove(zoneId)
          result.success(errorResponse(500, error?.message ?: "Interstitial load failed", errCode))
          sendAdEvent(AdEventType.LOAD_FAILED, zoneId, mapOf("error" to error?.message, "errorCode" to errCode))
        }

        override fun onInterstitialImpression() {
          Log.d(TAG, "Interstitial impression for zone: $zoneId")
          sendAdEvent(AdEventType.IMPRESSION, zoneId)
        }

        override fun onInterstitialClick() {
          Log.d(TAG, "Interstitial click for zone: $zoneId")
          sendAdEvent(AdEventType.CLICK, zoneId)
        }

        override fun onInterstitialDismissed() {
          Log.d(TAG, "Interstitial dismissed for zone: $zoneId")
          // Send the dismissed event FIRST, before any cleanup.
          // This ensures the Flutter side receives the event and can
          // resume its UI flow (dismiss the loading indicator).
          sendAdEvent(AdEventType.DISMISSED, zoneId)

          // Defer cleanup to allow the HyBid SDK to finish its own
          // internal teardown of the MRAID WebView / interstitial
          // activity. Removing the ad reference immediately during
          // this callback can cause premature GC of the native ad
          // object, leading to "webview is destroyed" errors and
          // leaving the Flutter UI stuck on a loading spinner.
          mainHandler.postDelayed({
            interstitialAds.remove(zoneId)?.destroy()
            Log.d(TAG, "Deferred cleanup complete for zone: $zoneId")
          }, 500)
        }
      })

    interstitialAds[zoneId] = interstitialAd
    interstitialAd.load()
    Log.d(TAG, "Loading interstitial for zone: $zoneId")
  }

  private fun loadRewardedAd(zoneId: String, activity: Activity, result: Result) {
    // Destroy any existing ad for this zone
    rewardedAds[zoneId]?.destroy()
    rewardedAds.remove(zoneId)

    val rewardedAd = HyBidRewardedAd(activity, zoneId,
      object : HyBidRewardedAd.Listener {
        override fun onRewardedLoaded() {
          Log.d(TAG, "Rewarded loaded for zone: $zoneId")
          val adData = createAdResponseData(zoneId, "rewarded", isReady = true)
          result.success(successResponse(200, adData))
          sendAdEvent(AdEventType.LOADED, zoneId)
        }

        override fun onRewardedLoadFailed(error: Throwable?) {
          val errCode = VerveErrorCode.extractFromThrowable(error)
          Log.e(TAG, "Rewarded load failed for zone $zoneId [errorCode=$errCode]: ${error?.message}")
          rewardedAds.remove(zoneId)
          result.success(errorResponse(500, error?.message ?: "Rewarded load failed", errCode))
          sendAdEvent(AdEventType.LOAD_FAILED, zoneId, mapOf("error" to error?.message, "errorCode" to errCode))
        }

        override fun onRewardedOpened() {
          Log.d(TAG, "Rewarded opened for zone: $zoneId")
          sendAdEvent(AdEventType.OPENED, zoneId)
        }

        override fun onRewardedClosed() {
          Log.d(TAG, "Rewarded closed for zone: $zoneId")
          rewardedAds.remove(zoneId)
          sendAdEvent(AdEventType.CLOSED, zoneId)
        }

        override fun onRewardedClick() {
          Log.d(TAG, "Rewarded click for zone: $zoneId")
          sendAdEvent(AdEventType.CLICK, zoneId)
        }

        override fun onReward() {
          Log.d(TAG, "Reward earned for zone: $zoneId")
          // Send reward event with any available reward data
          sendAdEvent(AdEventType.REWARD, zoneId, mapOf(
            "rewardType" to "default",
            "rewardAmount" to 1
          ))
        }
      })

    rewardedAds[zoneId] = rewardedAd
    rewardedAd.load()
    Log.d(TAG, "Loading rewarded for zone: $zoneId")
  }

  private fun createAdResponseData(zoneId: String, format: String, isReady: Boolean): Map<String, Any> {
    return mapOf(
      "adId" to "${format}_$zoneId",
      "format" to format,
      "zoneId" to zoneId,
      "title" to "${format.replaceFirstChar { it.uppercase() }} Ad",
      "description" to if (isReady) "Ad loaded and ready to show" else "Ad not ready",
      "isReady" to isReady,
      "clickUrl" to "",
      "campaignId" to ""
    )
  }

  // ==================== Ad Ready Check ====================

  private fun isAdReady(call: MethodCall, result: Result) {
    try {
      val zoneId = call.argument<String>("zoneId") ?: run {
        result.success(false)
        return
      }

      val interstitialReady = interstitialAds[zoneId]?.isReady == true
      val rewardedReady = rewardedAds[zoneId]?.isReady == true

      result.success(interstitialReady || rewardedReady)
    } catch (e: Exception) {
      Log.e(TAG, "isAdReady error: ${e.message}", e)
      result.success(false)
    }
  }

  // ==================== Show Ad ====================

  private fun showAd(call: MethodCall, result: Result) {
    try {
      val zoneId = call.argument<String>("zoneId") ?: run {
        result.success(errorResponse(400, "zoneId is required", VerveErrorCode.MISSING_REQUIRED_PARAMETER))
        return
      }

      // Try to show interstitial
      interstitialAds[zoneId]?.let { ad ->
        if (ad.isReady) {
          ad.show()
          result.success(successResponse(200, mapOf("shown" to true, "format" to "interstitial")))
          Log.d(TAG, "Showing interstitial for zone: $zoneId")
          return
        }
      }

      // Try to show rewarded
      rewardedAds[zoneId]?.let { ad ->
        if (ad.isReady) {
          ad.show()
          result.success(successResponse(200, mapOf("shown" to true, "format" to "rewarded")))
          Log.d(TAG, "Showing rewarded for zone: $zoneId")
          return
        }
      }

      result.success(errorResponse(404, "No ready ad found for zone: $zoneId", VerveErrorCode.AD_NOT_READY))
    } catch (e: Exception) {
      Log.e(TAG, "showAd error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to show ad", VerveErrorCode.PLUGIN_EXCEPTION))
    }
  }

  // ==================== Destroy Ad ====================

  private fun destroyAd(call: MethodCall, result: Result) {
    try {
      val zoneId = call.argument<String>("zoneId") ?: run {
        result.success(errorResponse(400, "zoneId is required", VerveErrorCode.MISSING_REQUIRED_PARAMETER))
        return
      }

      var destroyed = false

      interstitialAds[zoneId]?.let {
        it.destroy()
        interstitialAds.remove(zoneId)
        destroyed = true
      }

      rewardedAds[zoneId]?.let {
        it.destroy()
        rewardedAds.remove(zoneId)
        destroyed = true
      }

      if (destroyed) {
        result.success(successResponse(200, mapOf("destroyed" to true)))
        Log.d(TAG, "Destroyed ads for zone: $zoneId")
      } else {
        result.success(successResponse(200, mapOf("destroyed" to false, "message" to "No ads found for zone")))
      }
    } catch (e: Exception) {
      Log.e(TAG, "destroyAd error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to destroy ad", VerveErrorCode.PLUGIN_EXCEPTION))
    }
  }

  // ==================== Targeting & Settings ====================

  private fun setTargetingParams(call: MethodCall, result: Result) {
    try {
      call.argument<String>("age")?.let { HyBid.setAge(it) }
      call.argument<String>("gender")?.let { HyBid.setGender(it) }
      call.argument<String>("keywords")?.let { HyBid.setKeywords(it) }

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
      
      // Custom user data can be stored for analytics or passed to ad server
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

  // ==================== Cache & Device ====================

  private fun clearAdCache(result: Result) {
    try {
      destroyAllAds()
      result.success(successResponse(200))
      Log.d(TAG, "Ad cache cleared")
    } catch (e: Exception) {
      Log.e(TAG, "clearAdCache error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to clear cache"))
    }
  }

  private fun destroyAllAds() {
    interstitialAds.values.forEach { it.destroy() }
    interstitialAds.clear()
    rewardedAds.values.forEach { it.destroy() }
    rewardedAds.clear()
    Log.d(TAG, "All ads destroyed")
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
      result.success(successResponse(200))
      Log.d(TAG, "User consent set to: $consent")
    } catch (e: Exception) {
      Log.e(TAG, "setUserConsentStatus error: ${e.message}", e)
      result.success(errorResponse(500, e.message ?: "Failed to set consent"))
    }
  }

  // ==================== Diagnostics ====================

  private fun getDiagnostics(result: Result) {
    try {
      val diagnostics = mapOf(
        "isInitialized" to isInitialized,
        "sdkVersion" to SDK_VERSION,
        "testMode" to HyBid.isTestMode(),
        "platform" to "Android",
        "osVersion" to android.os.Build.VERSION.RELEASE,
        "loadedAds" to mapOf(
          "interstitials" to interstitialAds.keys.toList(),
          "rewarded" to rewardedAds.keys.toList()
        ),
        "adCount" to mapOf(
          "interstitials" to interstitialAds.size,
          "rewarded" to rewardedAds.size,
          "total" to (interstitialAds.size + rewardedAds.size)
        ),
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

  // ==================== Response Helpers ====================

  private fun successResponse(statusCode: Int, data: Any? = null): Map<String, Any> {
    return mapOf(
      "statusCode" to statusCode,
      "isSuccess" to true,
      "data" to (data ?: emptyMap<String, Any>()),
      "metadata" to emptyMap<String, Any>()
    )
  }

  private fun errorResponse(statusCode: Int, errorMessage: String?, errorCode: Int = VerveErrorCode.UNKNOWN): Map<String, Any> {
    return mapOf(
      "statusCode" to statusCode,
      "isSuccess" to false,
      "errorMessage" to (errorMessage ?: "Unknown error"),
      "errorCode" to errorCode,
      "metadata" to emptyMap<String, Any>()
    )
  }
}
