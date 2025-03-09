class Comment {
  final int id;
  final int pageId;
  final String content;
  final String authorId;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.pageId,
    required this.content,
    required this.authorId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pageId': pageId,
      'content': content,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      pageId: map['pageId'] is int ? map['pageId'] : int.tryParse(map['pageId'].toString()) ?? 0,
      content: map['content'],
      authorId: map['authorId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}