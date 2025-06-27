class LibraryDocument {
  final String libraryId;
  final String libraryName;
  final String? description;
  final String? file;
  final String? processId;
  final String? categoryId;

  LibraryDocument({
    required this.libraryId,
    required this.libraryName,
    this.description,
    this.file,
    this.processId,
    this.categoryId,
  });

  factory LibraryDocument.fromJson(Map<String, dynamic> json) {
    return LibraryDocument(
      libraryId: json['library_id']?.toString() ?? '',
      libraryName: json['library_name']?.toString() ?? '',
      description: json['description'],
      file: json['file'],
      processId: json['process_id'],
      categoryId: json['category_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'library_id': libraryId,
      'library_name': libraryName,
      'description': description,
      'file': file,
      'process_id': processId,
      'category_id': categoryId,
    };
  }

  LibraryDocument copyWith({
    String? libraryId,
    String? libraryName,
    String? description,
    String? file,
    String? processId,
    String? categoryId,
  }) {
    return LibraryDocument(
      libraryId: libraryId ?? this.libraryId,
      libraryName: libraryName ?? this.libraryName,
      description: description ?? this.description,
      file: file ?? this.file,
      processId: processId ?? this.processId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
