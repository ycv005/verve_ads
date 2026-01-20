import Flutter
import HyBid

public class VerveAdsPlugin: NSObject, FlutterPlugin {
  static let channelName = "com.verveads/verve_ads"
  
  private var isInitialized = false
  
  public static func dummy(methodCall: FlutterMethodCall) {
    // This method is called when the plugin is first loaded
  }

  public static func register(with registrar: FlutterPluginRegistry) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = VerveAdsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func dummyMethodToEnforceBundling() {
    // This function is called to enforce bundling the plugin
  }

  public func dummy(methodCall: FlutterMethodCall, result: @escaping FlutterResult) {
    // This is a dummy method implementation
  }

  // MARK: - FlutterPlugin Protocol Methods

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return true
  }

  public func application(
    _ application: UIApplication,
    supportedInterfaceOrientationsFor window: UIWindow?
  ) -> UIInterfaceOrientationMask {
    return .all
  }
}

// MARK: - Method Channel Handler

public func VerveAdsMethodHandler(
  methodCall: FlutterMethodCall,
  result: @escaping FlutterResult
) {
  let plugin = VerveAdsPlugin()
  plugin.handleMethodCall(methodCall, result: result)
}

extension VerveAdsPlugin {
  public func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      initialize(call: call, result: result)
    case "isInitialized":
      result(isInitialized)
    case "getSdkVersion":
      result(HyBid.version())
    case "requestAd":
      requestAd(call: call, result: result)
    case "isAdReady":
      isAdReady(call: call, result: result)
    case "showAd":
      showAd(call: call, result: result)
    case "setTargetingParams":
      setTargetingParams(call: call, result: result)
    case "setCustomUserData":
      setCustomUserData(call: call, result: result)
    case "setTestMode":
      setTestMode(call: call, result: result)
    case "setLocationTrackingEnabled":
      setLocationTrackingEnabled(call: call, result: result)
    case "setCoppaEnabled":
      setCoppaEnabled(call: call, result: result)
    case "clearAdCache":
      clearAdCache(call: call, result: result)
    case "getDeviceId":
      result(getDeviceId())
    case "getUserConsentStatus":
      result(HyBid.userConsentStatus())
    case "setUserConsentStatus":
      setUserConsentStatus(call: call, result: result)
    case "getPlatformVersion":
      let version = UIDevice.current.systemVersion
      result("iOS \(version)")
    case "getDiagnostics":
      getDiagnostics(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Method Implementations

  private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let appToken = args["appToken"] as? String else {
      result(errorResponse(statusCode: 400, message: "appToken is required"))
      return
    }

    do {
      // Initialize HyBid SDK
      HyBid.initialize(appToken)

      // Apply configuration
      let testMode = args["testMode"] as? Bool ?? false
      let locationTrackingEnabled = args["locationTrackingEnabled"] as? Bool ?? true
      let locationUpdatesEnabled = args["locationUpdatesEnabled"] as? Bool ?? true
      let coppaEnabled = args["coppaEnabled"] as? Bool ?? false

      HyBid.setTestMode(testMode)
      HyBid.setLocationTrackingEnabled(locationTrackingEnabled)
      HyBid.setLocationUpdatesEnabled(locationUpdatesEnabled)
      HyBid.setCoppaEnabled(coppaEnabled)

      // Set targeting parameters
      if let age = args["age"] as? String {
        HyBid.setAge(age)
      }
      if let gender = args["gender"] as? String {
        HyBid.setGender(gender)
      }
      if let keywords = args["keywords"] as? String {
        HyBid.setKeywords(keywords)
      }

      isInitialized = true
      result(successResponse(statusCode: 200))
    } catch {
      result(errorResponse(statusCode: 500, message: error.localizedDescription))
    }
  }

  private func requestAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let placementId = args["placementId"] as? String else {
      result(errorResponse(statusCode: 400, message: "placementId is required"))
      return
    }

    // Simplified ad request implementation
    let adData: [String: Any] = [
      "adId": "ad_\(Date().timeIntervalSince1970)",
      "format": args["adFormat"] as? String ?? "banner",
      "title": "Sample Ad",
      "description": "This is a sample ad",
      "clickUrl": "https://example.com",
      "campaignId": "campaign_123"
    ]

    result(successResponse(statusCode: 200, data: adData))
  }

  private func isAdReady(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let _ = args["placementId"] as? String else {
      result(false)
      return
    }
    // Simplified implementation
    result(true)
  }

  private func showAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let _ = args["placementId"] as? String else {
      result(errorResponse(statusCode: 400, message: "placementId is required"))
      return
    }
    // Simplified implementation
    result(successResponse(statusCode: 200))
  }

  private func setTargetingParams(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(errorResponse(statusCode: 400, message: "Invalid arguments"))
      return
    }

    if let age = args["age"] as? String {
      HyBid.setAge(age)
    }
    if let gender = args["gender"] as? String {
      HyBid.setGender(gender)
    }
    if let keywords = args["keywords"] as? String {
      HyBid.setKeywords(keywords)
    }

    result(successResponse(statusCode: 200))
  }

  private func setCustomUserData(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let userData = call.arguments as? [String: Any] else {
      result(errorResponse(statusCode: 400, message: "Invalid user data"))
      return
    }

    // Store custom user data
    result(successResponse(statusCode: 200))
  }

  private func setTestMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let enabled = args["enabled"] as? Bool else {
      result(errorResponse(statusCode: 400, message: "enabled is required"))
      return
    }

    HyBid.setTestMode(enabled)
    result(successResponse(statusCode: 200))
  }

  private func setLocationTrackingEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let enabled = args["enabled"] as? Bool else {
      result(errorResponse(statusCode: 400, message: "enabled is required"))
      return
    }

    HyBid.setLocationTrackingEnabled(enabled)
    result(successResponse(statusCode: 200))
  }

  private func setCoppaEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let enabled = args["enabled"] as? Bool else {
      result(errorResponse(statusCode: 400, message: "enabled is required"))
      return
    }

    HyBid.setCoppaEnabled(enabled)
    result(successResponse(statusCode: 200))
  }

  private func clearAdCache(call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Implement cache clearing logic
    result(successResponse(statusCode: 200))
  }

  private func getDeviceId() -> String {
    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
      return uuid
    }
    return "unknown"
  }

  private func setUserConsentStatus(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let consent = args["consent"] as? Bool else {
      result(errorResponse(statusCode: 400, message: "consent is required"))
      return
    }

    HyBid.setUserConsentStatus(consent)
    result(successResponse(statusCode: 200))
  }

  private func getDiagnostics(result: @escaping FlutterResult) {
    let diagnostics: [String: Any] = [
      "isInitialized": isInitialized,
      "sdkVersion": HyBid.version(),
      "testMode": HyBid.isTestMode(),
      "platform": "iOS",
      "osVersion": UIDevice.current.systemVersion,
      "deviceId": getDeviceId()
    ]
    result(diagnostics)
  }

  // MARK: - Helper Methods

  private func successResponse(statusCode: Int, data: [String: Any]? = nil) -> [String: Any] {
    return [
      "statusCode": statusCode,
      "isSuccess": true,
      "data": data ?? [:],
      "metadata": [:]
    ]
  }

  private func errorResponse(statusCode: Int, message: String) -> [String: Any] {
    return [
      "statusCode": statusCode,
      "isSuccess": false,
      "errorMessage": message,
      "metadata": [:]
    ]
  }
}
