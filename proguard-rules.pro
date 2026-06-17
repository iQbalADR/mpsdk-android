# proguard-rules.pro — applied when shrinking the SDK module itself.
# Most keep-rules live in consumer-rules.pro so consuming apps inherit them;
# this file only carries module-build specifics.

-keepattributes SourceFile,LineNumberTable      # readable crash traces
-renamesourcefileattribute SourceFile

# Quiet warnings for optional/absent transitive deps (adjust as needed).
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
