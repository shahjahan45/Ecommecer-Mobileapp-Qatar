# Android Emulator Note

If Flutter builds `app-debug.apk` but installation fails with:

- `cmd: Can't find service: activity`
- `cmd: Can't find service: package`

then the Flutter project compiled successfully and the Android emulator has not booted its core Android services correctly.

Recommended steps on Windows:

1. Stop the broken AVD in Android Studio Device Manager.
2. Cold Boot it once.
3. If it still fails, Wipe Data.
4. If it still fails, create a fresh Pixel 8 or Pixel 9 emulator using a stable Android 15/16 Google Play x86_64 image rather than the failing Android 17/API 37 image.
5. Wait for the Android home screen before running Flutter.
6. Check the device with `flutter devices`.
7. Run `flutter clean`, `flutter pub get`, `flutter analyze`, then `flutter run`.

ADB on the current Windows machine is typically located at:

`C:\Users\CyberOps\AppData\Local\Android\sdk\platform-tools\adb.exe`

This is an emulator/ADB environment problem, not a Dart source-code problem.
