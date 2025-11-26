/// Model class representing a photo template
/// Contains template metadata and asset path information
class TemplateModel {
  final String id;
  final String name;
  final String assetPath;
  final String? filePath; // For custom imported templates
  final String description;
  final bool isCustom;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.assetPath,
    this.filePath,
    required this.description,
    this.isCustom = false,
  });

  /// Factory constructor for creating a TemplateModel from JSON
  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      assetPath: json['assetPath'] as String,
      filePath: json['filePath'] as String?,
      description: json['description'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  /// Convert TemplateModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assetPath': assetPath,
      'filePath': filePath,
      'description': description,
      'isCustom': isCustom,
    };
  }

  @override
  String toString() {
    return 'TemplateModel(id: $id, name: $name, isCustom: $isCustom)';
  }
}
