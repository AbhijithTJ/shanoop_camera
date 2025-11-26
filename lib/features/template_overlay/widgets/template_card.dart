import 'dart:io';
import 'package:flutter/material.dart';
import '../models/template_model.dart';
import '../utils/constants.dart';

/// Widget for displaying a template card in the template selection screen
class TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final VoidCallback onTap;
  final bool isSelected;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Template preview
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadiusMedium),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Template image
                    template.isCustom && template.filePath != null
                        ? Image.file(
                            File(template.filePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            template.assetPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                    
                    // Selected indicator
                    if (isSelected)
                      Positioned(
                        top: AppConstants.spacingSmall,
                        right: AppConstants.spacingSmall,
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.spacingXSmall),
                          decoration: const BoxDecoration(
                            color: AppConstants.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Template info
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (template.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      template.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
