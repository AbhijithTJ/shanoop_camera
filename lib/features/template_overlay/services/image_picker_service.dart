import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Service for handling image selection from gallery
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from the device gallery
  /// Returns a File object if successful, null otherwise
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Maximum quality for best results
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery (for future enhancements)
  Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 100,
      );

      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
}
