/// Template Overlay Feature - Main Export File
/// 
/// This file provides easy access to all feature components.
/// Import this file to use the template overlay feature in your app.
/// 
/// Example usage:
/// ```dart
/// import 'package:shanoop_camera/features/template_overlay/template_overlay.dart';
/// 
/// // Navigate to template selection
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const TemplateSelectionScreen(),
///   ),
/// );
/// ```

library template_overlay;

// Models
export 'models/template_model.dart';
export 'models/overlay_result.dart';

// Services
export 'services/image_picker_service.dart';
export 'services/gallery_saver_service.dart';
export 'services/share_service.dart';
export 'services/image_processing_service.dart';

// Screens
export 'screens/template_selection_screen.dart';
export 'screens/template_overlay_screen.dart';

// Widgets
export 'widgets/custom_button.dart';
export 'widgets/photo_editor.dart';
export 'widgets/template_card.dart';

// Utils
export 'utils/constants.dart';
