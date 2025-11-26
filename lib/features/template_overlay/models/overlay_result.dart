import 'dart:io';

/// Result model for overlay operations
/// Encapsulates success/failure states and resulting file
class OverlayResult {
  final bool success;
  final File? file;
  final String? errorMessage;
  final String? filePath;

  const OverlayResult({
    required this.success,
    this.file,
    this.errorMessage,
    this.filePath,
  });

  /// Factory constructor for successful result
  factory OverlayResult.success({
    required File file,
    required String filePath,
  }) {
    return OverlayResult(
      success: true,
      file: file,
      filePath: filePath,
    );
  }

  /// Factory constructor for failed result
  factory OverlayResult.failure({
    required String errorMessage,
  }) {
    return OverlayResult(
      success: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'OverlayResult.success(filePath: $filePath)';
    } else {
      return 'OverlayResult.failure(error: $errorMessage)';
    }
  }
}
