import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../models/overlay_result.dart';

/// Service for processing and merging images with templates
class ImageProcessingService {
  /// Merge user photo with template using screenshot approach
  /// This captures the rendered widget as an image
  Future<OverlayResult> mergeImagesFromWidget({
    required GlobalKey repaintBoundaryKey,
    String? fileName,
  }) async {
    try {
      // Get the RenderRepaintBoundary from the key
      final RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Convert to image
      final ui.Image image = await boundary.toImage(
        pixelRatio: 3.0, // High quality output
      );

      // Convert to byte data
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        return OverlayResult.failure(
          errorMessage: 'Failed to convert image to bytes',
        );
      }

      // Get bytes
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temporary file
      final String name = fileName ?? 'merged_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = await _saveBytesToFile(pngBytes, name);

      return OverlayResult.success(
        file: file,
        filePath: file.path,
      );
    } catch (e) {
      print('Error merging images: $e');
      return OverlayResult.failure(
        errorMessage: 'Failed to merge images: ${e.toString()}',
      );
    }
  }

  /// Save bytes to a temporary file
  Future<File> _saveBytesToFile(Uint8List bytes, String fileName) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$fileName';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Alternative method: Merge images using image package
  /// This provides more control over the merging process
  Future<OverlayResult> mergeImagesManually({
    required File userPhoto,
    required File templateFile,
    String? fileName,
  }) async {
    try {
      // Read both images
      final Uint8List userPhotoBytes = await userPhoto.readAsBytes();
      final Uint8List templateBytes = await templateFile.readAsBytes();

      // Decode images
      final img.Image? userImage = img.decodeImage(userPhotoBytes);
      final img.Image? templateImage = img.decodeImage(templateBytes);

      if (userImage == null || templateImage == null) {
        return OverlayResult.failure(
          errorMessage: 'Failed to decode images',
        );
      }

      // Resize user image to match template size
      final img.Image resizedUserImage = img.copyResize(
        userImage,
        width: templateImage.width,
        height: templateImage.height,
      );

      // Create a new image with the same dimensions as template
      final img.Image mergedImage = img.Image(
        width: templateImage.width,
        height: templateImage.height,
      );

      // Copy user image to merged image
      img.compositeImage(
        mergedImage,
        resizedUserImage,
        dstX: 0,
        dstY: 0,
      );

      // Overlay template on top
      img.compositeImage(
        mergedImage,
        templateImage,
        dstX: 0,
        dstY: 0,
      );

      // Encode to PNG
      final Uint8List mergedBytes = Uint8List.fromList(
        img.encodePng(mergedImage),
      );

      // Save to file
      final String name = fileName ?? 'merged_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = await _saveBytesToFile(mergedBytes, name);

      return OverlayResult.success(
        file: file,
        filePath: file.path,
      );
    } catch (e) {
      print('Error merging images manually: $e');
      return OverlayResult.failure(
        errorMessage: 'Failed to merge images: ${e.toString()}',
      );
    }
  }

  /// Resize image to specific dimensions
  Future<File?> resizeImage({
    required File imageFile,
    required int width,
    required int height,
  }) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) return null;

      final img.Image resized = img.copyResize(
        image,
        width: width,
        height: height,
      );

      final Uint8List resizedBytes = Uint8List.fromList(
        img.encodePng(resized),
      );

      final String fileName = 'resized_${DateTime.now().millisecondsSinceEpoch}.png';
      return await _saveBytesToFile(resizedBytes, fileName);
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }

  /// Get image dimensions
  Future<Size?> getImageDimensions(File imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) return null;

      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      print('Error getting image dimensions: $e');
      return null;
    }
  }
}
