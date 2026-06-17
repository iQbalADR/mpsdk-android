# consumer-rules.pro — shipped INSIDE the AAR; applied automatically in
# every app that consumes the Mini Program SDK.

# --- Public SDK API: consumers call these by name; never rename/strip ---
-keep public class com.example.miniprogramsdk.** { public *; }
-keep public interface com.example.miniprogramsdk.** { *; }

# --- WebView JS bridge: R8 strips @JavascriptInterface methods otherwise,
#     silently breaking every native call from mini-program JS. ---
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class com.example.miniprogramsdk.MiniProgramBridge { *; }
-keep class com.example.miniprogramsdk.debug.** { *; }

# --- Delegates / callbacks invoked reflectively or from JS ---
-keep interface com.example.miniprogramsdk.MiniProgramBridgeDelegate { *; }
-keep interface com.example.miniprogramsdk.ActivityMirror { *; }

# --- Gson models: keep field names + @SerializedName for (de)serialization ---
-keepattributes Signature, *Annotation*, InnerClasses, EnclosingMethod
-keepclassmembers,allowobfuscation class com.example.miniprogramsdk.** {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class * extends com.google.gson.reflect.TypeToken

# --- Kotlin metadata ---
-keep class kotlin.Metadata { *; }
