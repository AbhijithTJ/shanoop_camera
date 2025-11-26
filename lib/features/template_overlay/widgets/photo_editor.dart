import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Widget for displaying and manipulating the user's photo with zoom and pan
class PhotoEditor extends StatefulWidget {
  final File imageFile;
  final ValueChanged<Matrix4>? onPhotoChanged;
  final TransformationController? controller;
  final Color backgroundColor;

  const PhotoEditor({
    super.key,
    required this.imageFile,
    this.onPhotoChanged,
    this.controller,
    this.backgroundColor = Colors.black,
  });

  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  late TransformationController _controller;
  double _currentScale = 1.0;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TransformationController();
      _isInternalController = true;
    }
    _controller.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _controller.value.getMaxScaleOnAxis();
    if (scale != _currentScale) {
      setState(() {
        _currentScale = scale;
      });
    }
    widget.onPhotoChanged?.call(_controller.value);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformationChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _resetView() {
    _controller.value = Matrix4.identity();
  }

  void _zoomIn() {
    final Matrix4 matrix = _controller.value.clone();
    matrix.scale(1.2);
    _controller.value = matrix;
  }

  void _zoomOut() {
    final Matrix4 matrix = _controller.value.clone();
    matrix.scale(0.8);
    _controller.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Interactive viewer for free pan/zoom
        Container(
          color: widget.backgroundColor,
          child: InteractiveViewer(
            transformationController: _controller,
            boundaryMargin: const EdgeInsets.all(double.infinity), // Allow moving anywhere
            minScale: 0.1,
            maxScale: 5.0,
            child: SizedBox.expand(
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain, // Show full image, user can zoom to cover
              ),
            ),
          ),
        ),
        
        // Control buttons overlay
        Positioned(
          right: AppConstants.spacingMedium,
          bottom: AppConstants.spacingMedium,
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
        
        // Scale indicator
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
              '${(_currentScale * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

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
