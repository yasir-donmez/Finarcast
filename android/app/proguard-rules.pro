# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# RevenueCat (purchases_flutter)
-keep class com.revenuecat.purchases.** { *; }

# Gson Proguard Rules (required by flutter_local_notifications)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Ignore missing Play Core classes (deferred components/splits not used)
-dontwarn com.google.android.play.core.**

