import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '../models/template_model.dart';
import '../services/image_picker_service.dart';
import '../services/gallery_saver_service.dart';
import '../services/share_service.dart';
import '../services/image_processing_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/photo_editor.dart';
import '../utils/constants.dart';

/// Main screen for template overlay feature
/// Allows users to select a photo, adjust it with zoom/pan, and merge with template
class TemplateOverlayScreen extends StatefulWidget {
  final TemplateModel template;

  const TemplateOverlayScreen({
    super.key,
    required this.template,
  });

  @override
  State<TemplateOverlayScreen> createState() => _TemplateOverlayScreenState();
}

class _TemplateOverlayScreenState extends State<TemplateOverlayScreen> {
  // Services
  final ImagePickerService _imagePickerService = ImagePickerService();
  final GallerySaverService _gallerySaverService = GallerySaverService();
  final ShareService _shareService = ShareService();
  final ImageProcessingService _imageProcessingService = ImageProcessingService();
  
  // Screenshot controller for capturing the merged result
  final ScreenshotController _screenshotController = ScreenshotController();
  
  // State
  File? _selectedImage;
  bool _isProcessing = false;
  bool _isSaving = false;
  bool _isSharing = false;
  
  // Global key for RepaintBoundary (alternative to screenshot package)
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Automatically prompt to select image when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImage();
    });
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final File? image = await _imagePickerService.pickImageFromGallery();
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  /// Capture and save the merged image
  Future<void> _saveImage() async {
    if (_selectedImage == null) {
      _showErrorSnackBar(AppConstants.msgSelectImage);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Capture screenshot using screenshot package
      final imageBytes = await _screenshotController.capture(
        pixelRatio: AppConstants.screenshotPixelRatio,
      );

      if (imageBytes == null) {
        _showErrorSnackBar('Failed to capture image');
        return;
      }

      // Save to gallery
      final String? savedPath = await _gallerySaverService.saveImageToGallery(
        imageBytes: imageBytes,
        name: '${AppConstants.defaultFilePrefix}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (savedPath != null) {
        _showSuccessSnackBar(AppConstants.msgImageSaved);
      } else {
        _showErrorSnackBar('Failed to save image to gallery');
      }
    } catch (e) {
      _showErrorSnackBar('Error saving image: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Share the merged image
  Future<void> _shareImage() async {
    if (_selectedImage == null) {
      _showErrorSnackBar(AppConstants.msgSelectImage);
      return;
    }

    setState(() {
      _isSharing = true;
    });

    try {
      // Capture screenshot
      final imageBytes = await _screenshotController.capture(
        pixelRatio: AppConstants.screenshotPixelRatio,
      );

      if (imageBytes == null) {
        _showErrorSnackBar('Failed to capture image');
        return;
      }

      // Save to temporary file
      final tempFile = File(
        '${Directory.systemTemp.path}/temp_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await tempFile.writeAsBytes(imageBytes);

      // Share
      final success = await _shareService.shareImage(
        file: tempFile,
        text: 'Check out my photo with template overlay!',
      );

      if (success) {
        _showSuccessSnackBar(AppConstants.msgImageShared);
      }
    } catch (e) {
      _showErrorSnackBar('Error sharing image: ${e.toString()}');
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.template.name),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Change photo button
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.photo_library),
              tooltip: 'Change Photo',
              onPressed: _pickImage,
            ),
        ],
      ),
      body: _selectedImage == null
          ? _buildEmptyState()
          : _buildEditorView(),
      bottomNavigationBar: _selectedImage != null
          ? _buildBottomBar()
          : null,
    );
  }

  /// Build empty state when no image is selected
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Text(
            'No Image Selected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            'Tap the button below to select a photo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXLarge),
          CustomButton(
            text: 'Select Photo',
            icon: Icons.photo_library,
            onPressed: _pickImage,
            width: 200,
          ),
        ],
      ),
    );
  }

  /// Build the main editor view with photo and template overlay
  Widget _buildEditorView() {
    return Column(
      children: [
        // Instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          color: AppConstants.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: AppConstants.iconSizeSmall,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: Text(
                  'Pinch to zoom, drag to move your photo. The template will overlay on top.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppConstants.primaryColor.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Editor area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(AppConstants.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
              child: Screenshot(
                controller: _screenshotController,
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // User's photo with zoom and pan (bottom layer)
                      PhotoEditor(
                        imageFile: _selectedImage!,
                      ),
                      
                      // Template overlay (top layer)
                      // Template overlay (top layer) - Wrapped in IgnorePointer to allow gestures to pass through
                      IgnorePointer(
                        child: widget.template.isCustom && widget.template.filePath != null
                            ? Image.file(
                                File(widget.template.filePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        'Error loading template',
                                        style: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Image.asset(
                                widget.template.assetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.transparent,
                                    child: Center(
                                      child: Text(
                                        'Template not found',
                                        style: TextStyle(
                                          color: Colors.red.shade300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build bottom action bar
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Save button
            Expanded(
              child: CustomButton(
                text: 'Save to Gallery',
                icon: Icons.save_alt,
                onPressed: _isSaving || _isSharing ? null : _saveImage,
                isLoading: _isSaving,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            
            // Share button
            Expanded(
              child: CustomButton(
                text: 'Share',
                icon: Icons.share,
                onPressed: _isSaving || _isSharing ? null : _shareImage,
                isLoading: _isSharing,
                backgroundColor: AppConstants.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
