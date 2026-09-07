import 'dart:io';

enum MediaType { photo, audio }

class MediaItemModel {
  final String id;
  final String filePath;
  final MediaType type;
  final DateTime createdAt;

  MediaItemModel({
    required this.id,
    required this.filePath,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MediaItemModel.fromMap(Map<String, dynamic> map) {
    return MediaItemModel(
      id: map['id'],
      filePath: map['file_path'],
      type: MediaType.values.byName(map['type']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  File get file => File(filePath);
}
