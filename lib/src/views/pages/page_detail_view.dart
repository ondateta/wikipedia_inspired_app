import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gap/gap.dart';
import 'package:template/src/design_system/app_theme.dart';
import 'package:template/src/design_system/responsive_wrapper.dart';
import 'package:template/src/models/comment.dart';
import 'package:template/src/models/page.dart';
import 'package:template/src/services/local_storage_service.dart';
import 'package:template/src/views/pages/edit_page_view.dart';

class PageDetailView extends StatefulWidget {
  final String pageId;

  const PageDetailView({super.key, required this.pageId});

  @override
  State<PageDetailView> createState() => _PageDetailViewState();
}

class _PageDetailViewState extends State<PageDetailView> with SingleTickerProviderStateMixin {
  final LocalStorageService _storageService = LocalStorageService();
  final TextEditingController _commentController = TextEditingController();
  Map<String, dynamic>? _pageData;
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPageData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pageData = await _storageService.getPage(widget.pageId);
      final comments = await _storageService.getPageComments(widget.pageId);
      
      setState(() {
        _pageData = pageData;
        _comments = List<Map<String, dynamic>>.from(comments);
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load page: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      final user = await _storageService.getCurrentUser();
      if (user != null) {
        await _storageService.addComment(
          pageId: widget.pageId,
          content: _commentController.text,
          authorId: user['username'] ?? 'Anonymous',
        );
        
        _commentController.clear();
        _loadPageData();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to add comment: ${e.toString()}";
      });
    }
  }

  void _navigateToEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPageView(pageId: widget.pageId),
      ),
    ).then((_) => _loadPageData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_pageData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Text(_errorMessage ?? 'The requested page could not be found.'),
        ),
      );
    }

    try {
      final WikiPage page = WikiPage.fromMap(_pageData!);
      final List<PageVersion> versions = page.versions;

      return Scaffold(
        appBar: AppBar(
          title: Text(page.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditPage,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Content'),
              Tab(text: 'Comments'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              child: ResponsiveWrapper(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.title,
                        style: theme.textTheme.titleLarge,
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          Text(
                            'Created by: ${page.authorId}',
                            style: theme.textTheme.bodySmall,
                          ),
                          const Spacer(),
                          Text(
                            'Last updated: ${page.updatedAt.toString().substring(0, 16)}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const Divider(),
                      const Gap(8),
                      MarkdownBody(
                        data: page.content,
                        selectable: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            ResponsiveWrapper(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: _comments.isEmpty
                          ? Center(
                              child: Text(
                                'No comments yet. Be the first to comment!',
                                style: theme.textTheme.bodyLarge,
                              ),
                            )
                          : ListView.builder(
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                final comment = Comment.fromMap(_comments[index]);
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment.authorId,
                                              style: theme.textTheme.titleSmall,
                                            ),
                                            const Spacer(),
                                            Text(
                                              comment.createdAt.toString().substring(0, 16),
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                        const Divider(),
                                        Text(comment.content),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Gap(8),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                              ),
                            ),
                          ),
                        ),
                        const Gap(8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            ResponsiveWrapper(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: versions.isEmpty
                    ? Center(
                        child: Text(
                          'No version history available.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: versions.length,
                        itemBuilder: (context, index) {
                          final version = versions[versions.length - 1 - index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Version ${version.versionId}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Updated by: ${version.authorId}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    'Date: ${version.timestamp.toString().substring(0, 16)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Version ${version.versionId}'),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: SingleChildScrollView(
                                        child: MarkdownBody(
                                          data: version.content,
                                          selectable: true,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error loading page: ${e.toString()}'),
        ),
      );
    }
  }
}