# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Gson (Required by flutter_local_notifications)
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature
-keepattributes *Annotation*

# Keep sound resources
-keepclassmembers class **.R$raw {
    <fields>;
}
-keep class **.R$raw { *; }

# General Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core (Flutter deferred components)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

