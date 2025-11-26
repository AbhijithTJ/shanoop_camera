import 'package:flutter/material.dart';

/// Model for image color filters
class ImageFilter {
  final String name;
  final ColorFilter? colorFilter;
  final IconData icon;

  const ImageFilter({
    required this.name,
    required this.colorFilter,
    required this.icon,
  });

  /// No filter - original image
  static const ImageFilter none = ImageFilter(
    name: 'Original',
    colorFilter: null,
    icon: Icons.image,
  );

  /// Brightness filter - makes image brighter
  static const ImageFilter bright = ImageFilter(
    name: 'Bright',
    colorFilter: ColorFilter.mode(
      Color.fromARGB(40, 255, 255, 255),
      BlendMode.lighten,
    ),
    icon: Icons.brightness_high,
  );

  /// Dark filter - makes image darker
  static const ImageFilter dark = ImageFilter(
    name: 'Dark',
    colorFilter: ColorFilter.mode(
      Color.fromARGB(40, 0, 0, 0),
      BlendMode.darken,
    ),
    icon: Icons.brightness_low,
  );

  /// Cool filter - adds blue tint
  static const ImageFilter cool = ImageFilter(
    name: 'Cool',
    colorFilter: ColorFilter.mode(
      Color.fromARGB(50, 100, 150, 255),
      BlendMode.overlay,
    ),
    icon: Icons.ac_unit,
  );

  /// Warm filter - adds orange/yellow tint
  static const ImageFilter warm = ImageFilter(
    name: 'Warm',
    colorFilter: ColorFilter.mode(
      Color.fromARGB(50, 255, 180, 100),
      BlendMode.overlay,
    ),
    icon: Icons.wb_sunny,
  );

  /// Vintage filter - sepia tone
  static const ImageFilter vintage = ImageFilter(
    name: 'Vintage',
    colorFilter: ColorFilter.mode(
      Color.fromARGB(80, 180, 140, 100),
      BlendMode.overlay,
    ),
    icon: Icons.camera_alt,
  );

  /// Black and White filter
  static const ImageFilter blackWhite = ImageFilter(
    name: 'B&W',
    colorFilter: ColorFilter.matrix(<double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    icon: Icons.filter_b_and_w,
  );

  /// Vivid filter - increases saturation
  static const ImageFilter vivid = ImageFilter(
    name: 'Vivid',
    colorFilter: ColorFilter.mode(
      Color.fromARGB(30, 255, 100, 150),
      BlendMode.saturation,
    ),
    icon: Icons.colorize,
  );

  /// List of all available filters
  static const List<ImageFilter> allFilters = [
    none,
    bright,
    dark,
    cool,
    warm,
    vintage,
    blackWhite,
    vivid,
  ];
}
