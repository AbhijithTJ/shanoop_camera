import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
  List<File> _selectedImages = [];
  int _activeImageIndex = 0;
  List<TransformationController> _controllers = [];
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

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Pick images from gallery
  Future<void> _pickImage() async {
    try {
      final List<File> images = await _imagePickerService.pickMultipleImages();
      
      if (images.isNotEmpty) {
        setState(() {
          // If this is the first time, we replace the empty state
          // If we already have images, we append
          final int startIndex = _selectedImages.length;
          
          for (var image in images) {
            _selectedImages.add(image);
            _controllers.add(TransformationController());
          }
          
          // If we added new images, switch to the first new one
          if (_selectedImages.length == images.length) {
            _activeImageIndex = 0;
          } else {
            _activeImageIndex = startIndex;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: ${e.toString()}');
    }
  }

  /// Delete the image at the specified index
  Future<void> _deleteImage(int index) async {
    if (_selectedImages.isEmpty) return;
    
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to remove this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.errorColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _selectedImages.removeAt(index);
        _controllers[index].dispose();
        _controllers.removeAt(index);
        
        // Adjust active index if needed
        if (_selectedImages.isEmpty) {
          _activeImageIndex = 0;
        } else if (_activeImageIndex >= _selectedImages.length) {
          _activeImageIndex = _selectedImages.length - 1;
        } else if (index < _activeImageIndex) {
          _activeImageIndex--;
        }
      });
    }
  }

  /// Crop the currently active image
  Future<void> _cropImage() async {
    if (_selectedImages.isEmpty) return;
    
    final File activeImage = _selectedImages[_activeImageIndex];
    
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: activeImage.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppConstants.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImages[_activeImageIndex] = File(croppedFile.path);
          // Reset controller for this image as dimensions might have changed
          _controllers[_activeImageIndex].value = Matrix4.identity();
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to crop image: ${e.toString()}');
    }
  }

  /// Capture and save the merged image
  Future<void> _saveImage() async {
    if (_selectedImages.isEmpty) {
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
    if (_selectedImages.isEmpty) {
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

  /// Get the current scale of the active image
  double _getCurrentScale() {
    if (_selectedImages.isEmpty || _activeImageIndex >= _controllers.length) {
      return 1.0;
    }
    return _controllers[_activeImageIndex].value.getMaxScaleOnAxis();
  }

  /// Zoom in the active image
  void _zoomIn() {
    if (_selectedImages.isEmpty || _activeImageIndex >= _controllers.length) {
      return;
    }
    final Matrix4 matrix = _controllers[_activeImageIndex].value.clone();
    matrix.scale(1.2);
    setState(() {
      _controllers[_activeImageIndex].value = matrix;
    });
  }

  /// Zoom out the active image
  void _zoomOut() {
    if (_selectedImages.isEmpty || _activeImageIndex >= _controllers.length) {
      return;
    }
    final Matrix4 matrix = _controllers[_activeImageIndex].value.clone();
    matrix.scale(0.8);
    setState(() {
      _controllers[_activeImageIndex].value = matrix;
    });
  }

  /// Reset the active image view
  void _resetView() {
    if (_selectedImages.isEmpty || _activeImageIndex >= _controllers.length) {
      return;
    }
    setState(() {
      _controllers[_activeImageIndex].value = Matrix4.identity();
    });
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
          // Crop button
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.crop),
              tooltip: 'Crop Active Photo',
              onPressed: _cropImage,
            ),
          // Add photo button
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Add Photo',
            onPressed: _pickImage,
          ),
        ],
      ),
      body: _selectedImages.isEmpty
          ? _buildEmptyState()
          : _buildEditorView(),
      bottomNavigationBar: _selectedImages.isNotEmpty
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
                  'Select a photo below to edit. Pinch to zoom, drag to move.',
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
              child: Stack(
                children: [
                  // Screenshot area with images and template
                  Screenshot(
                    controller: _screenshotController,
                    child: RepaintBoundary(
                      key: _repaintBoundaryKey,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Render all images
                          ...List.generate(_selectedImages.length, (index) {
                            // If active, use PhotoEditor
                            if (index == _activeImageIndex) {
                              return PhotoEditor(
                                key: ValueKey('editor_$index'),
                                imageFile: _selectedImages[index],
                                controller: _controllers[index],
                                backgroundColor: Colors.transparent,
                              );
                            }
                            // If inactive, use Transform to show the image in its last edited state
                            return Container(
                              color: Colors.transparent,
                              child: Transform(
                                transform: _controllers[index].value,
                                alignment: Alignment.topLeft,
                                child: SizedBox.expand(
                                  child: Image.file(
                                    _selectedImages[index],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          }),
                          
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
                  
                  // Zoom Control buttons overlay (outside screenshot, on top of template)
                  Positioned(
                    right: AppConstants.spacingMedium,
                    top: AppConstants.spacingMedium,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zoom In
                        _buildControlButton(
                          icon: Icons.add,
                          onPressed: _zoomIn,
                          tooltip: 'Zoom In',
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        
                        // Zoom Out
                        _buildControlButton(
                          icon: Icons.remove,
                          onPressed: _zoomOut,
                          tooltip: 'Zoom Out',
                        ),
                        const SizedBox(height: AppConstants.spacingSmall),
                        
                        // Reset
                        _buildControlButton(
                          icon: Icons.refresh,
                          onPressed: _resetView,
                          tooltip: 'Reset',
                        ),
                      ],
                    ),
                  ),
                  
                  // Scale indicator (outside screenshot, on top of template)
                  Positioned(
                    left: AppConstants.spacingMedium,
                    bottom: AppConstants.spacingMedium,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMedium,
                        vertical: AppConstants.spacingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                      ),
                      child: Text(
                        '${(_getCurrentScale() * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Image Selector
        Container(
          height: 80,
          padding: const EdgeInsets.only(bottom: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _selectedImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final isSelected = index == _activeImageIndex;
              return GestureDetector(
                onTap: () => setState(() => _activeImageIndex = index),
                child: Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: isSelected 
                            ? Border.all(color: AppConstants.primaryColor, width: 3) 
                            : Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Delete button
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => _deleteImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppConstants.errorColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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

  /// Build a control button for zoom controls
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white,
              size: AppConstants.iconSizeMedium,
            ),
          ),
        ),
      ),
    );
  }
}
