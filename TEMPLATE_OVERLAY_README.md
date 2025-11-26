# Photo Template Overlay Feature

A complete, production-ready Flutter feature for overlaying PNG templates on user photos with zoom, pan, crop, save, and share capabilities.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Usage](#usage)
- [File Structure](#file-structure)
- [Platform Configuration](#platform-configuration)

The feature follows clean architecture principles with clear separation of concerns:

```
lib/features/template_overlay/
├── models/           # Data models
├── services/         # Business logic & external integrations
├── screens/          # UI screens
├── widgets/          # Reusable UI components
└── utils/            # Constants & helper functions
```

### Key Components

1. **Models**: Data structures for templates and results
2. **Services**: 
   - `ImagePickerService`: Gallery image selection
   - `GallerySaverService`: Save images with permissions
   - `ShareService`: Share functionality
   - `ImageProcessingService`: Image manipulation
3. **Screens**: 
   - `TemplateSelectionScreen`: Choose template
   - `TemplateOverlayScreen`: Edit and export
4. **Widgets**: Reusable components (buttons, cards, photo editor)

## 📦 Installation

### 1. Dependencies

All required dependencies are already added to `pubspec.yaml`:

```yaml
dependencies:
  image_picker: ^1.0.7          # Gallery selection
  photo_view: ^0.14.0           # Zoom & pan
  screenshot: ^2.3.0            # Capture merged image
  image_gallery_saver: ^2.0.3   # Save to gallery
  share_plus: ^7.2.2            # Share functionality
  path_provider: ^2.1.2         # File operations
  permission_handler: ^11.3.0   # Permissions
  image: ^4.1.7                 # Image manipulation
```

### 2. Install Packages

```bash
flutter pub get
```

### 3. Platform Configuration

#### Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <!-- Permissions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    
    <application>
        <!-- ... -->
    </application>
</manifest>
```

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34  // or higher
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### iOS Configuration

Add to `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Photo Library Access -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need access to your photo library to select images for template overlay</string>
    
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>We need permission to save your edited photos to the gallery</string>
</dict>
```

## 🚀 Usage

### Basic Usage

The feature is integrated into `main.dart`. Simply run the app:

```bash
flutter run
```

### Navigation Flow

1. **Home Screen** → Tap "Get Started"
2. **Template Selection** → Choose a template
3. **Template Overlay Editor** → 
   - Select photo from gallery
   - Zoom/pan to adjust
   - Save to gallery or share

### Programmatic Usage

```dart
// Navigate to template selection
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TemplateSelectionScreen(),
  ),
);

// Or directly to editor with a specific template
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TemplateOverlayScreen(
      template: TemplateModel(
        id: '1',
        name: 'Classic Frame',
        assetPath: 'assets/templates/template_1.png',
        description: 'Simple elegant frame',
      ),
    ),
  ),
);
```

## 📁 File Structure

```
lib/features/template_overlay/
│
├── models/
│   ├── template_model.dart        # Template data model
│   └── overlay_result.dart        # Result wrapper
│
├── services/
│   ├── image_picker_service.dart  # Gallery selection
│   ├── gallery_saver_service.dart # Save to gallery
│   ├── share_service.dart         # Share functionality
│   └── image_processing_service.dart # Image manipulation
│
├── screens/
│   ├── template_selection_screen.dart # Template chooser
│   └── template_overlay_screen.dart   # Main editor
│
├── widgets/
│   ├── custom_button.dart         # Reusable button
│   ├── photo_editor.dart          # Zoom/pan widget
│   └── template_card.dart         # Template preview card
│
└── utils/
    └── constants.dart             # App constants

assets/templates/
├── template_1.png                 # Classic frame
├── template_2.png                 # Modern border
└── template_3.png                 # Vintage style
```

## 🎨 Customization

### Adding New Templates

1. Add PNG template to `assets/templates/`
2. Update template list in `TemplateSelectionScreen`:

```dart
final List<TemplateModel> _templates = const [
  TemplateModel(
    id: '4',
    name: 'Your Template',
    assetPath: 'assets/templates/your_template.png',
    description: 'Description here',
  ),
  // ... other templates
];
```

### Customizing Colors

Edit `lib/features/template_overlay/utils/constants.dart`:

```dart
class AppConstants {
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color secondaryColor = Color(0xFF03DAC6);
  // ... other colors
}
```

### Adjusting Zoom Limits

Edit `PhotoEditor` widget:

```dart
PhotoView(
  minScale: PhotoViewComputedScale.contained * 0.5,  // Min zoom
  maxScale: PhotoViewComputedScale.covered * 4.0,    // Max zoom
  // ...
)
```

## 🔧 API Reference

### Services

#### ImagePickerService

```dart
final service = ImagePickerService();

// Pick single image
File? image = await service.pickImageFromGallery();

// Pick multiple images
List<File> images = await service.pickMultipleImages();
```

#### GallerySaverService

```dart
final service = GallerySaverService();

// Check permission
bool hasPermission = await service.isStoragePermissionGranted();

// Request permission
bool granted = await service.requestStoragePermission();

// Save image
String? path = await service.saveImageToGallery(
  imageBytes: bytes,
  name: 'my_image',
);
```

#### ShareService

```dart
final service = ShareService();

// Share image
bool success = await service.shareImage(
  file: imageFile,
  text: 'Check this out!',
);
```

#### ImageProcessingService

```dart
final service = ImageProcessingService();

// Merge using widget capture
OverlayResult result = await service.mergeImagesFromWidget(
  repaintBoundaryKey: key,
  fileName: 'merged.png',
);

// Manual merge
OverlayResult result = await service.mergeImagesManually(
  userPhoto: photoFile,
  templateFile: templateFile,
);
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Permission Denied

**Problem**: Can't save to gallery
**Solution**: 
- Check AndroidManifest.xml has correct permissions
- For Android 13+, ensure you're using scoped storage
- For iOS, verify Info.plist entries

#### 2. Template Not Showing

**Problem**: Template image not visible
**Solution**:
- Verify template path in assets
- Run `flutter pub get`
- Check `pubspec.yaml` assets section
- Ensure PNG has transparency

#### 3. Image Quality Issues

**Problem**: Exported image is blurry
**Solution**:
- Increase `pixelRatio` in ScreenshotController:
```dart
await _screenshotController.capture(
  pixelRatio: 3.0,  // Increase this value
);
```

#### 4. Build Errors

**Problem**: Compilation fails
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Platform-Specific Issues

#### Android

- **Gradle Build Fails**: Update `compileSdkVersion` to 34+
- **Permission Issues**: Check `minSdkVersion` is 21+

#### iOS

- **Pod Install Fails**: 
```bash
cd ios
pod deintegrate
pod install
```

## 📱 Testing

### Manual Testing Checklist

- [ ] Select image from gallery
- [ ] Zoom in/out on photo
- [ ] Pan photo around
- [ ] Reset photo position
- [ ] Save to gallery (check gallery app)
- [ ] Share image (verify share sheet)
- [ ] Change template
- [ ] Test on different screen sizes
- [ ] Test permission denial scenarios

## 🎯 Future Enhancements

Potential improvements:

1. **Multiple Photo Support**: Add multiple photos to one template
2. **Filters**: Apply Instagram-style filters
3. **Text Overlay**: Add custom text to images
4. **Stickers**: Add decorative stickers
5. **Cloud Templates**: Download templates from server
6. **History**: Save editing history
7. **Undo/Redo**: Add undo/redo functionality
8. **Crop Tool**: Advanced cropping options

## 📄 License

This feature is part of the shanoop_camera project.

## 👨‍💻 Author

Built with ❤️ using Flutter

---

**Need Help?** Check the troubleshooting section or review the inline code comments for detailed explanations.
