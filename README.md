# Shanoop Camera - Template Overlay App

A professional Flutter application for creating beautiful photos by overlaying PNG templates on user images.

## ✨ Features

- 📸 **Import Photos** - Select images from device gallery
- 🎨 **Template Overlay** - Apply beautiful PNG templates to your photos
- 🔍 **Zoom & Pan** - Adjust photos with intuitive controls
- 💾 **Save to Gallery** - Export high-quality merged images
- 📤 **Share** - Share your creations instantly
- 🎯 **Clean Architecture** - Production-ready, maintainable code

## 🚀 Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

**That's it!** The app is ready to use.

## 📖 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get started in 3 steps ⚡
- **[TEMPLATE_OVERLAY_README.md](TEMPLATE_OVERLAY_README.md)** - Complete feature guide 📚
- **[PLATFORM_SETUP.md](PLATFORM_SETUP.md)** - Android/iOS configuration 🔧
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - Technical details 💻
- **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Architecture & overview 🏗️
- **[CHECKLIST.md](CHECKLIST.md)** - Testing & deployment ✅

## 🎯 How It Works

1. **Select Template** - Choose from Classic, Modern, or Vintage frames
2. **Import Photo** - Pick an image from your gallery
3. **Adjust** - Zoom and pan to position perfectly
4. **Export** - Save to gallery or share with friends

## 🏗️ Project Structure

```
lib/features/template_overlay/
├── models/           # Data models
├── services/         # Business logic
├── screens/          # UI screens
├── widgets/          # Reusable components
└── utils/            # Constants & helpers

assets/templates/     # PNG template images
```

## 🛠️ Technology Stack

- **Flutter** 3.5.4+
- **Dart** (null-safe)
- **PhotoView** - Zoom & pan
- **Screenshot** - Image merging
- **Image Picker** - Gallery selection
- **Share Plus** - Sharing functionality

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ Permissions configured
- ✅ Production-ready

## 🎨 Screenshots

The app includes:
- Beautiful home screen with feature overview
- Template selection with grid view
- Photo editor with zoom/pan controls
- Save and share functionality

## 🔧 Customization

### Add New Templates
1. Add PNG file to `assets/templates/`
2. Update template list in `TemplateSelectionScreen`

### Change Colors
Edit `lib/features/template_overlay/utils/constants.dart`

### Adjust Zoom Range
Edit `lib/features/template_overlay/widgets/photo_editor.dart`

## 📦 Dependencies

All dependencies are included in `pubspec.yaml`:
- image_picker
- photo_view
- screenshot
- image_gallery_saver
- share_plus
- path_provider
- permission_handler
- image

## 🚢 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## ✅ Status

**Development**: ✅ Complete  
**Testing**: Ready for QA  
**Documentation**: ✅ Complete  
**Deployment**: Ready to ship  

## 📞 Need Help?

1. Check [QUICK_START.md](QUICK_START.md) for immediate issues
2. Review [TEMPLATE_OVERLAY_README.md](TEMPLATE_OVERLAY_README.md) for detailed info
3. See [PLATFORM_SETUP.md](PLATFORM_SETUP.md) for configuration
4. Read inline code comments

## 🎉 What's Included

- ✅ Complete working app
- ✅ 3 sample templates
- ✅ Full source code
- ✅ Comprehensive documentation
- ✅ Platform configuration
- ✅ Error handling
- ✅ Professional UI/UX

## 📄 License

This project is part of the Shanoop Camera application.

---

**Built with ❤️ using Flutter**  
**Version**: 1.0.0  
**Ready for Production** 🚀
