import 'dart:io';
import 'package:flutter/material.dart';
import '../models/template_model.dart';
import '../widgets/template_card.dart';
import '../utils/constants.dart';
import 'template_overlay_screen.dart';
import '../services/image_picker_service.dart';

/// Screen for selecting a template before editing
class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  TemplateModel? _selectedTemplate;
  final ImagePickerService _imagePickerService = ImagePickerService();

  // Sample templates - In production, this would come from a database or API
  final List<TemplateModel> _templates = const [
    TemplateModel(
      id: '1',
      name: 'Classic Frame',
      assetPath: 'assets/templates/template_1.png',
      description: 'Simple elegant frame',
    ),
    TemplateModel(
      id: '2',
      name: 'Modern Border',
      assetPath: 'assets/templates/template_2.png',
      description: 'Contemporary design',
    ),
    TemplateModel(
      id: '3',
      name: 'Vintage Style',
      assetPath: 'assets/templates/template_3.png',
      description: 'Retro aesthetic',
    ),
  ];

  void _selectTemplate(TemplateModel template) {
    setState(() {
      _selectedTemplate = template;
    });
  }

  Future<void> _importTemplate() async {
    try {
      final File? image = await _imagePickerService.pickImageFromGallery();
      
      if (image != null) {
        final customTemplate = TemplateModel(
          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          name: 'Custom Template',
          assetPath: '', // Not used for custom
          filePath: image.path,
          description: 'Imported from gallery',
          isCustom: true,
        );
        
        setState(() {
          _selectedTemplate = customTemplate;
        });
        
        // Auto-continue for custom template
        _continueToEditor();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import template: $e'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  void _continueToEditor() {
    if (_selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a template first'),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateOverlayScreen(
          template: _selectedTemplate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Select Template'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose Your Template',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSmall),
                Text(
                  'Select a template or import your own PNG',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Template grid
          Expanded(
            child: _buildTemplateGrid(),
          ),

          // Continue button
          if (_selectedTemplate != null)
            Container(
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continueToEditor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spacingMedium,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Continue with ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            _selectedTemplate!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.spacingMedium,
        mainAxisSpacing: AppConstants.spacingMedium,
        childAspectRatio: 0.75,
      ),
      // Add 1 for the "Import" card
      itemCount: _templates.length + 1,
      itemBuilder: (context, index) {
        // First item is Import Card
        if (index == 0) {
          return _buildImportCard();
        }
        
        final template = _templates[index - 1];
        return TemplateCard(
          template: template,
          isSelected: _selectedTemplate?.id == template.id,
          onTap: () => _selectTemplate(template),
        );
      },
    );
  }

  Widget _buildImportCard() {
    final isSelected = _selectedTemplate?.isCustom == true;
    
    return GestureDetector(
      onTap: _importTemplate,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            const Text(
              'Import Template',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select PNG from Gallery',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
