# Verve Ads Plugin - ProGuard Rules
# These rules are automatically applied to consuming apps

# HyBid SDK
-keepattributes Signature
-keep class net.pubnative.** { *; }
-keep class com.iab.omid.library.pubnativenet.** { *; }

# Keep HyBid SDK callbacks and interfaces
-keepclassmembers class * implements net.pubnative.lite.sdk.** {
    <methods>;
}

# Google Advertising ID
-keep class com.google.android.gms.ads.identifier.** { *; }

# Prevent R8 from stripping interfaces used for ad callbacks
-keep interface net.pubnative.** { *; }
