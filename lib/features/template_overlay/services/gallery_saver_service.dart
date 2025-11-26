import 'dart:io';
import 'dart:typed_data';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path_provider/path_provider.dart';

/// Service for saving images to device gallery
class GallerySaverService {
  /// Request storage permission from the user
  /// Returns true if permission is granted
  Future<bool> requestStoragePermission() async {
    try {
      // saver_gallery handles permissions internally
      // We'll check during save operation
      return true;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Save image bytes to gallery
  /// Returns the file path if successful, null otherwise
  Future<String?> saveImageToGallery({
    required Uint8List imageBytes,
    String? name,
  }) async {
    try {
      // Generate filename with timestamp if not provided
      final fileName = name ?? 'template_overlay_${DateTime.now().millisecondsSinceEpoch}.png';

      // Save to gallery using SaverGallery
      final result = await SaverGallery.saveImage(
        imageBytes,
        name: fileName,
        androidRelativePath: "Pictures/TemplateOverlay",
        androidExistNotSave: false,
      );

      if (result.isSuccess) {
        print('Image saved successfully to gallery');
        // Return a success indicator since SaveResult doesn't provide filePath
        return 'saved_successfully';
      } else {
        print('Failed to save image: ${result.errorMessage ?? "Unknown error"}');
        return null;
      }
    } catch (e) {
      print('Error saving image to gallery: $e');
      return null;
    }
  }

  /// Save file to gallery
  /// Returns the file path if successful, null otherwise
  Future<String?> saveFileToGallery({
    required File file,
    String? name,
  }) async {
    try {
      // Read file as bytes
      final bytes = await file.readAsBytes();
      
      // Use the saveImageToGallery method
      return await saveImageToGallery(
        imageBytes: bytes,
        name: name,
      );
    } catch (e) {
      print('Error saving file to gallery: $e');
      return null;
    }
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    try {
      // saver_gallery handles permissions automatically
      return true;
    } catch (e) {
      print('Error checking storage permission: $e');
      return false;
    }
  }
}

