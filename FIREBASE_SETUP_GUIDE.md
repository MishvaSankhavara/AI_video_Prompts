# Firebase Setup Guide for AI Video Prompts

This guide outlines the steps required to configure and connect your Firebase project with this Flutter application.

---

## Method 1: Using FlutterFire CLI (Recommended)

The easiest way to configure Firebase is using the official **FlutterFire CLI**. This automatically downloads the necessary native config files and generates `lib/firebase_options.dart`.

### Prerequisites
1. Install the [Firebase CLI](https://firebase.google.com/docs/cli#install_cli_tools) on your machine.
2. Log in to your Firebase account:
   ```bash
   firebase login
   ```
3. Ensure you have the Flutter SDK installed and available in your PATH.

### Configuration Steps
1. Run the following command in the project root directory to activate the FlutterFire CLI globally:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Run the configuration tool:
   ```bash
   flutterfire configure
   ```
3. Select your Firebase project from the list (or create a new one).
4. Select the platforms you want to support (Android and iOS).
5. The CLI will automatically:
   - Create a Firebase project app for each platform.
   - Generate `lib/firebase_options.dart` with all credentials.
   - Configure native files (`google-services.json` for Android and build settings/plist files for iOS).

Once completed, update your `lib/main.dart` to use the generated options:
```dart
import 'firebase_options.dart';

// Inside main()
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

---

## Method 2: Manual Configuration

If you prefer to configure Android and iOS manually from the Firebase Console:

### Step 1: Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** and follow the prompts.

### Step 2: Configure Android
1. In your Firebase project settings, add an **Android app**.
2. Enter your Android Package Name: `com.example.aivideoprompt` (or your customized package name).
3. Download the `google-services.json` file.
4. Move this file into the `android/app/` directory of this project.
5. In `android/build.gradle`, verify that the Google services dependency is present:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.1' // or latest
   }
   ```
6. In `android/app/build.gradle`, verify that the Google services plugin is applied:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### Step 3: Configure iOS
1. In your Firebase project settings, add an **iOS app**.
2. Enter your iOS Bundle ID (typically the same as your package name).
3. Download the `GoogleService-Info.plist` file.
4. Open the iOS project in Xcode (`ios/Runner.xcworkspace`).
5. Right-click the `Runner` folder in Xcode, select **Add Files to "Runner"**, and select the `GoogleService-Info.plist` file. Ensure "Copy items if needed" is checked.
