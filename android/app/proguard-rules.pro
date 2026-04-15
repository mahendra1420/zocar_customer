# Razorpay
-keepclassmembers class com.razorpay.** {
    *;
}
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep analytics
-keep class com.razorpay.AnalyticsUtil { *; }
-keepclassmembers class com.razorpay.AnalyticsUtil {
    public *;
}