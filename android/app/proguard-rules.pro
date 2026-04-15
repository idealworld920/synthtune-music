# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Google Sign In
-keep class com.google.android.gms.** { *; }

# Mailer
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Google Play Core (deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
