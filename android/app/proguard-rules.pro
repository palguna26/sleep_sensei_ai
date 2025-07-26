# ProGuard rules for TensorFlow Lite GPU delegate
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.** { *; }
-keep class com.google.protobuf.** { *; }
-dontwarn org.tensorflow.lite.**
-dontwarn org.tensorflow.**
-dontwarn com.google.protobuf.** 