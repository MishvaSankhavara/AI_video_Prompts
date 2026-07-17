# Flutter ProGuard Rules
# Add project specific ProGuard rules here.

# Keep WorkManager and Room Database classes to prevent crashes in release mode
-keep class androidx.work.** { *; }
-keep class * extends androidx.room.RoomDatabase
-keep class androidx.work.impl.WorkDatabase_Impl { *; }

# Don't warn about missing dependencies in androidx.work
-dontwarn androidx.work.**
