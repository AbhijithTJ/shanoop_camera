# Platform Configuration Guide

## Android Setup

### 1. Update AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

Add these permissions inside the `<manifest>` tag:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Required Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- For Android 13+ (API 33+) -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    
    <application
        android:label="Template Overlay"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Your existing configuration -->
        
    </application>
</manifest>
```

### 2. Update build.gradle

File: `android/app/build.gradle`

```gradle
android {
    namespace "com.example.shanoop_camera"
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId "com.example.shanoop_camera"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}
```

### 3. Update gradle.properties (if needed)

File: `android/gradle.properties`

```properties
org.gradle.jvmargs=-Xmx1536M
android.useAndroidX=true
android.enableJetifier=true
```

---

## iOS Setup

### 1. Update Info.plist

File: `ios/Runner/Info.plist`

Add these entries inside the `<dict>` tag:

```xml
<dict>
    <!-- Existing keys... -->
    
    <!-- Photo Library Access -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need access to your photo library to select images for template overlay</string>
    
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>We need permission to save your edited photos to the gallery</string>
    
    <!-- Camera Access (if you add camera feature later) -->
    <key>NSCameraUsageDescription</key>
    <string>We need access to your camera to take photos</string>
</dict>
```

### 2. Update Podfile (if needed)

File: `ios/Podfile`

Ensure minimum iOS version is 12.0 or higher:

```ruby
platform :ios, '12.0'

# Uncomment this line if you have issues
# use_frameworks!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

### 3. Run Pod Install

```bash
cd ios
pod install
cd ..
```

---

## Quick Setup Script

### For Android

Run these commands in your terminal:

```bash
# No additional setup needed beyond manifest changes
flutter clean
flutter pub get
```

### For iOS

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

---

## Verification

After configuration, verify everything works:

```bash
# Check for issues
flutter doctor

# Run on device
flutter run

# Build for release (Android)
flutter build apk --release

# Build for release (iOS)
flutter build ios --release
```

---

## Common Issues

### Android

**Issue**: Permission denied when saving
**Fix**: Ensure all permissions are in AndroidManifest.xml and request at runtime

**Issue**: Gradle build fails
**Fix**: Update compileSdkVersion to 34 or higher

### iOS

**Issue**: Pod install fails
**Fix**: 
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
```

**Issue**: Permission denied
**Fix**: Verify Info.plist has all required usage descriptions

---

## Testing Permissions

Test the permission flow:

1. **First Launch**: App should request photo library permission
2. **Deny Permission**: App should show error message
3. **Grant Permission**: App should work normally
4. **Settings**: User can change permissions in device settings
