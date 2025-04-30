# OneSignal SDK ProGuard Rules

-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**

# Gson uses reflection, keep model classes
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Required to prevent stripping of OS background classes
-keep class com.onesignal.NotificationOpenedReceiver { *; }
-keep class com.onesignal.NotificationExtenderService { *; }
-keep class com.onesignal.OneSignal$StateChangeObserver { *; }
