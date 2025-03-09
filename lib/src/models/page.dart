class WikiPage {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PageVersion> versions;

  WikiPage({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.createdAt,
    required this.updatedAt,
    required this.versions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'versions': versions.map((v) => v.toMap()).toList(),
    };
  }

  factory WikiPage.fromMap(Map<String, dynamic> map) {
    return WikiPage(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      authorId: map['authorId']?.toString() ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      versions: List<PageVersion>.from(
        (map['versions'] is List ? map['versions'] : []).map(
          (v) => PageVersion.fromMap(v is Map<String, dynamic> ? v : <String, dynamic>{}),
        ),
      ),
    );
  }
}

class PageVersion {
  final int versionId;
  final String content;
  final DateTime timestamp;
  final String authorId;

  PageVersion({
    required this.versionId,
    required this.content,
    required this.timestamp,
    required this.authorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'versionId': versionId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'authorId': authorId,
    };
  }

  factory PageVersion.fromMap(Map<String, dynamic> map) {
    return PageVersion(
      versionId: map['versionId'] is int ? map['versionId'] : 1,
      content: map['content']?.toString() ?? '',
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      authorId: map['authorId']?.toString() ?? '',
    );
  }
}