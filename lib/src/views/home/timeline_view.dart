import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:template/src/design_system/app_theme.dart';
import 'package:template/src/design_system/responsive_wrapper.dart';
import 'package:template/src/models/page.dart';
import 'package:template/src/services/local_storage_service.dart';
import 'package:template/src/views/pages/create_page_view.dart';
import 'package:template/src/views/pages/page_detail_view.dart';

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> with SingleTickerProviderStateMixin {
  final LocalStorageService _storageService = LocalStorageService();
  List<Map<String, dynamic>> _pages = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadPages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pages = await _storageService.getAllPages();
      setState(() {
        _pages = pages;
      });
      _animationController.forward();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading pages: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToCreatePage() async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const CreatePageView())
    );

    if (result == true) {
      _animationController.reset();
      _loadPages();
    }
  }

  void _navigateToPageDetail(String pageId) {
    if (pageId.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageDetailView(pageId: pageId),
      ),
    ).then((_) {
      _animationController.reset();
      _loadPages();
    });
  }

  List<Map<String, dynamic>> get _filteredPages {
    if (_searchQuery.isEmpty) return _pages;
    return _pages.where((page) {
      final title = page['title']?.toString().toLowerCase() ?? '';
      final content = page['content']?.toString().toLowerCase() ?? '';
      final author = page['authorId']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || content.contains(query) || author.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _PageSearchDelegate(_pages, _navigateToPageDetail),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPages,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingShimmer(theme)
          : RefreshIndicator(
              onRefresh: _loadPages,
              color: theme.colorScheme.primary,
              child: ResponsiveWrapper(
                child: _pages.isEmpty
                    ? _buildEmptyState(theme)
                    : _buildPagesList(theme),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePage,
        icon: const Icon(Icons.add),
        label: const Text('New Page'),
        elevation: 4,
      ),
    );
  }

  Widget _buildLoadingShimmer(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceVariant,
      highlightColor: theme.colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const Gap(16),
          Text(
            'No Pages Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Create your first page by tapping the + button below',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(24),
          ElevatedButton.icon(
            onPressed: _navigateToCreatePage,
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Page'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagesList(ThemeData theme) {
    final List<Map<String, dynamic>> displayPages = _pages.isEmpty
        ? [
            {
              'id': '-1',
              'title': 'Welcome to Local Wikipedia',
              'content': 'This is a local Wikipedia clone where you can create and manage your own pages.',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
              'authorId': 'system',
              'versions': []
            },
            {
              'id': '-2',
              'title': 'Getting Started',
              'content': 'Click the + button to create your first page.',
              'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
              'updatedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
              'authorId': 'system',
              'versions': []
            },
          ]
        : _filteredPages;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: child,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: displayPages.length,
        itemBuilder: (context, index) {
          final page = displayPages[index];
          final pageId = page['id']?.toString() ?? '';
          final isPlaceholder = pageId.startsWith('-');
          final versions = page['versions'] is List ? page['versions'] as List : [];
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = _animation.value > delay 
                  ? (_animation.value - delay) / (1 - delay)
                  : 0.0;
              
              return Transform.translate(
                offset: Offset(0, 20 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: child,
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shadowColor: theme.shadowColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                side: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                ),
              ),
              child: InkWell(
                onTap: isPlaceholder ? null : () => _navigateToPageDetail(pageId),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: isPlaceholder
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : _getColorFromTitle(page['title']?.toString() ?? ''),
                            child: Icon(
                              isPlaceholder ? Icons.info_outline : Icons.article_outlined,
                              color: isPlaceholder
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onPrimary,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  page['title']?.toString() ?? 'Untitled',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap(4),
                                Text(
                                  'By ${page['authorId']?.toString() ?? 'Unknown'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Divider(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      const Gap(8),
                      Text(
                        _getContentPreview(page['content']),
                        style: theme.textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(16),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                          const Gap(4),
                          Text(
                            _formatDate(DateTime.tryParse(page['createdAt']?.toString() ?? '') ?? DateTime.now()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                          ),
                          const Spacer(),
                          if (!isPlaceholder && versions.isNotEmpty) ...[
                            Icon(
                              Icons.history,
                              size: 14,
                              color: theme.colorScheme.onBackground.withOpacity(0.6),
                            ),
                            const Gap(4),
                            Text(
                              '${versions.length} versions',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getContentPreview(dynamic content) {
    if (content == null) return 'No content';
    
    final contentStr = content.toString();
    return contentStr.length > 150 ? '${contentStr.substring(0, 150)}...' : contentStr;
  }

  Color _getColorFromTitle(String title) {
    final colors = [
      Colors.blue[700]!,
      Colors.green[700]!,
      Colors.red[700]!,
      Colors.orange[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
    ];
    
    int hashCode = title.hashCode.abs();
    return colors[hashCode % colors.length];
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class _PageSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> pages;
  final Function(String) onPageSelected;

  _PageSearchDelegate(this.pages, this.onPageSelected);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    final filteredPages = pages.where((page) {
      final title = page['title']?.toString().toLowerCase() ?? '';
      final content = page['content']?.toString().toLowerCase() ?? '';
      final author = page['authorId']?.toString().toLowerCase() ?? '';
      final queryLower = query.toLowerCase();
      return title.contains(queryLower) || content.contains(queryLower) || author.contains(queryLower);
    }).toList();

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const Gap(16),
            Text(
              'Enter a search term.',
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPages.length,
      itemBuilder: (context, index) {
        final page = filteredPages[index];
        final pageId = page['id']?.toString() ?? '';
        return ListTile(
          title: Text(page['title']?.toString() ?? 'Untitled'),
          subtitle: Text(page['content']?.toString() ?? 'No content'),
          onTap: () {
            context.go('/page/$pageId');
            close(context, pageId);
          },
        );
      },
    );
  }
}