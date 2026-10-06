# Flutter / Firebase / OneSignal keep rules for release minify.

-keep class com.google.firebase.** { *; }
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**
-dontwarn com.google.firebase.**
