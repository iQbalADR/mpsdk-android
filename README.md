# MPSDK for Android — `miniprogramsdk-release.aar`

Binary distribution of the Mini Program SDK for Android, shipped as a
release `.aar`.

> **One AAR covers both emulator and physical devices.** Unlike iOS
> (where an XCFramework carries separate device/simulator slices), an
> Android `.aar` is architecture-independent for pure JVM/Kotlin code —
> the same artifact runs on emulators and real devices. (If native `.so`
> libraries are ever added, enable ABI splits then.)

> **Proprietary software.** © 2026 iQbalADR (iqbal.adr@gmail.com). All rights
> reserved. Use is subject to a separate written agreement. See `LICENSE`.

---

## Requirements

- `minSdk` 24+, `compileSdk` 35
- AndroidX, Kotlin

## Installation

Drop the AAR into your app and depend on it:

```kotlin
// app/build.gradle.kts
dependencies {
    implementation(files("libs/miniprogramsdk-release.aar"))
    // transitive deps the AAR expects (not bundled):
    implementation("androidx.webkit:webkit:1.x")
    implementation("com.google.code.gson:gson:2.x")
}
```

```kotlin
import com.example.miniprogramsdk.MiniProgramSDK
// MiniProgramSDK.start(...) etc.
```

Public entry points: `MiniProgramSDK`, `MiniProgramBridge`,
`MiniProgramSecureClient`, `MiniProgramDebugger`,
`MiniProgramBridgeDelegate`.

> **Note:** the module's package is currently `com.example.miniprogramsdk`.
> Consider renaming to a real reverse-DNS namespace (e.g.
> `id.adr.mpsdk`) before public release — `com.example.*` is a placeholder
> and will be rejected by some distribution channels.

---

## ProGuard / R8 configuration

Two files ship with this SDK:

- [`consumer-rules.pro`](consumer-rules.pro) — packaged **inside** the AAR;
  every app that consumes the SDK gets these rules automatically. This is
  where the keep-rules that protect the SDK's runtime contract live.
- [`proguard-rules.pro`](proguard-rules.pro) — applied when shrinking the
  **SDK module itself** at build time.

### `consumer-rules.pro` (the important one)

```proguard
# --- Public SDK API: consumers call these by name; never rename/strip ---
-keep public class com.example.miniprogramsdk.** { public *; }
-keep public interface com.example.miniprogramsdk.** { *; }

# --- WebView JS bridge: R8 strips @JavascriptInterface methods otherwise,
#     which silently breaks every native call from mini-program JS. ---
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
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# --- Kotlin metadata (needed for reflection / coroutines interop) ---
-keep class kotlin.Metadata { *; }
```

### `proguard-rules.pro` (SDK module shrink)

```proguard
# Keep enough to keep the public contract + bridge intact while the SDK's
# internals are obfuscated. Most rules live in consumer-rules.pro so apps
# inherit them; this file only adds module-build specifics.
-keepattributes SourceFile,LineNumberTable      # readable crash traces
-renamesourcefileattribute SourceFile
-dontwarn org.bouncycastle.**                   # if optional crypto deps absent
```

### SDK-specific gotchas

1. **`@JavascriptInterface` is the #1 footgun.** Without the
   `-keepclassmembers ... @android.webkit.JavascriptInterface` rule, R8
   removes the bridge methods the WebView JS calls — the SDK loads but
   every `native.*` call no-ops. The consumer rules above cover it.
2. **Gson reflection.** Any model serialized by Gson needs its fields kept
   (or `@SerializedName` on every field). Don't rely on field names
   surviving obfuscation.
3. **Public keep is broad on purpose.** `-keep public class …{ public *; }`
   keeps the public API but still lets R8 obfuscate non-public internals.
4. **NFC / security classes** referenced via `Class.forName` or manifest
   must be kept by name — add explicit `-keep` if you wire any
   reflectively.

Reference: <https://developer.android.com/build/shrink-code> ·
<https://www.guardsquare.com/manual/configuration/usage> (ProGuard) ·
DexGuard (the hardened counterpart to iXGuard) for production obfuscation.
