import 'package:flutter/material.dart';

/// App-wide constants for the template overlay feature
class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF6200EE);
  static const Color primaryVariant = Color(0xFF3700B3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Image Quality
  static const int imageQuality = 100;
  static const double screenshotPixelRatio = 3.0;
  
  // File Names
  static const String defaultFilePrefix = 'template_overlay';
  
  // Messages
  static const String msgSelectImage = 'Please select an image first';
  static const String msgImageSaved = 'Image saved to gallery successfully!';
  static const String msgImageShared = 'Image shared successfully!';
  static const String msgPermissionDenied = 'Storage permission denied';
  static const String msgErrorOccurred = 'An error occurred. Please try again.';
  static const String msgProcessing = 'Processing...';
  static const String msgSaving = 'Saving to gallery...';
  static const String msgSharing = 'Sharing...';
}
