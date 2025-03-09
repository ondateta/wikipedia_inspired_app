import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  Future<void> saveUser({
    required String username,
    required String password,
    required String email,
  }) async {
    final userBox = Hive.box('userData');
    await userBox.put('currentUser', {
      'username': username,
      'email': email,
      'password': password,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await userBox.put('isLoggedIn', true);
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final userBox = Hive.box('userData');
    final userData = userBox.get('currentUser');
    if (userData != null) {
      return Map<String, dynamic>.from(userData);
    }
    return null;
  }

  Future<bool> isUserLoggedIn() async {
    final userBox = Hive.box('userData');
    return userBox.get('isLoggedIn', defaultValue: false);
  }

  Future<void> logoutUser() async {
    final userBox = Hive.box('userData');
    await userBox.put('isLoggedIn', false);
  }

  Future<void> deleteUserAccount() async {
    final userBox = Hive.box('userData');
    await userBox.delete('currentUser');
    await userBox.put('isLoggedIn', false);
  }

  Future<Map<String, dynamic>> createPage({
    required String title,
    required String content,
    required String authorId,
  }) async {
    final pagesBox = Hive.box('pages');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final pageId = timestamp.toString();
    
    final pageData = {
      'id': pageId,
      'title': title,
      'content': content,
      'authorId': authorId,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'versions': [
        {
          'versionId': 1,
          'content': content,
          'timestamp': DateTime.now().toIso8601String(),
          'authorId': authorId,
        }
      ],
    };
    
    await pagesBox.put(pageId, pageData);
    
    return Map<String, dynamic>.from(pageData);
  }

  Future<void> updatePage({
    required String pageId,
    required String content,
    required String authorId,
    String? title,
  }) async {
    final pagesBox = Hive.box('pages');
    final pageData = pagesBox.get(pageId);
    
    if (pageData != null) {
      final page = Map<String, dynamic>.from(pageData);
      final List<dynamic> rawVersions = page['versions'] ?? [];
      final versions = rawVersions.map((v) => Map<String, dynamic>.from(v)).toList();
      
      final newVersionId = versions.length + 1;
      
      versions.add({
        'versionId': newVersionId,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'authorId': authorId,
      });
      
      final updatedPage = {
        ...page,
        'content': content,
        'title': title ?? page['title'],
        'updatedAt': DateTime.now().toIso8601String(),
        'versions': versions,
      };
      
      await pagesBox.put(pageId, updatedPage);
    }
  }

  Future<Map<String, dynamic>?> getPage(String pageId) async {
    final pagesBox = Hive.box('pages');
    final pageData = pagesBox.get(pageId);
    if (pageData != null) {
      return Map<String, dynamic>.from(pageData);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllPages() async {
    final pagesBox = Hive.box('pages');
    final result = <Map<String, dynamic>>[];
    
    for (var key in pagesBox.keys) {
      final page = pagesBox.get(key);
      if (page != null && page is Map) {
        result.add(Map<String, dynamic>.from(page));
      }
    }
    
    return result;
  }

  Future<List<Map<String, dynamic>>> getUserPages(String authorId) async {
    final pagesBox = Hive.box('pages');
    final result = <Map<String, dynamic>>[];
    
    for (var key in pagesBox.keys) {
      final page = pagesBox.get(key);
      if (page != null && page is Map && page['authorId'] == authorId) {
        result.add(Map<String, dynamic>.from(page));
      }
    }
    
    return result;
  }

  Future<void> deletePage(String pageId) async {
    final pagesBox = Hive.box('pages');
    await pagesBox.delete(pageId);
    
    final commentsBox = Hive.box('comments');
    final commentsToDelete = [];
    
    for (var key in commentsBox.keys) {
      final comment = commentsBox.get(key);
      if (comment != null && comment is Map && comment['pageId'] == pageId) {
        commentsToDelete.add(key);
      }
    }
        
    for (var commentId in commentsToDelete) {
      await commentsBox.delete(commentId);
    }
  }

  Future<void> addComment({
    required String pageId,
    required String content,
    required String authorId,
  }) async {
    final commentsBox = Hive.box('comments');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final commentId = timestamp.toString();
    
    await commentsBox.put(commentId, {
      'id': commentId,
      'pageId': pageId,
      'content': content,
      'authorId': authorId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPageComments(String pageId) async {
    final commentsBox = Hive.box('comments');
    final result = <Map<String, dynamic>>[];
    
    for (var key in commentsBox.keys) {
      final comment = commentsBox.get(key);
      if (comment != null && comment is Map) {
        final Map<String, dynamic> commentMap = Map<String, dynamic>.from(comment);
        final commentPageId = commentMap['pageId'];
        if (commentPageId == pageId) {
          result.add(commentMap);
        }
      }
    }
    
    return result;
  }
  
  Future<int> getCommentCount(String authorId) async {
    final commentsBox = Hive.box('comments');
    int count = 0;
    
    for (var key in commentsBox.keys) {
      final comment = commentsBox.get(key);
      if (comment != null && comment is Map && comment['authorId'] == authorId) {
        count++;
      }
    }
    
    return count;
  }
  
  Future<int> getTotalVersionsCount(String authorId) async {
    final pagesBox = Hive.box('pages');
    int totalVersions = 0;
    
    for (var key in pagesBox.keys) {
      final page = pagesBox.get(key);
      if (page != null && page is Map && page['authorId'] == authorId) {
        final versions = page['versions'];
        if (versions is List) {
          totalVersions += versions.length;
        }
      }
    }
    
    return totalVersions;
  }

  Future<void> deleteAllData() async {
    await Hive.box('userData').clear();
    await Hive.box('pages').clear();
    await Hive.box('comments').clear();
    await Hive.box('appSettings').clear();
  }
}