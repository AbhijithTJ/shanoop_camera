import 'dart:io';
import 'package:share_plus/share_plus.dart';

/// Service for sharing images
class ShareService {
  /// Share an image file
  /// Returns true if sharing was initiated successfully
  Future<bool> shareImage({
    required File file,
    String? text,
    String? subject,
  }) async {
    try {
      final XFile xFile = XFile(file.path);
      
      await Share.shareXFiles(
        [xFile],
        text: text ?? 'Check out my photo with template overlay!',
        subject: subject,
      );
      
      return true;
    } catch (e) {
      print('Error sharing image: $e');
      return false;
    }
  }

  /// Share multiple images
  Future<bool> shareMultipleImages({
    required List<File> files,
    String? text,
    String? subject,
  }) async {
    try {
      final List<XFile> xFiles = files.map((file) => XFile(file.path)).toList();
      
      await Share.shareXFiles(
        xFiles,
        text: text ?? 'Check out my photos!',
        subject: subject,
      );
      
      return true;
    } catch (e) {
      print('Error sharing multiple images: $e');
      return false;
    }
  }

  /// Share text only
  Future<bool> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
      
      return true;
    } catch (e) {
      print('Error sharing text: $e');
      return false;
    }
  }
}
