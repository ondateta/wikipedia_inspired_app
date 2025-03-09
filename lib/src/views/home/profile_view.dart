import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:template/src/design_system/responsive_wrapper.dart';
import 'package:template/src/services/local_storage_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final LocalStorageService _storageService = LocalStorageService();
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _userPages = [];
  int _commentsCount = 0;
  int _versionsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _storageService.getCurrentUser();
      if (user != null) {
        final userPages = await _storageService.getUserPages(user['username']);
        final commentsCount = await _storageService.getCommentCount(user['username']);
        final versionsCount = await _storageService.getTotalVersionsCount(user['username']);
        
        setState(() {
          _user = Map<String, dynamic>.from(user);
          _userPages = userPages;
          _commentsCount = commentsCount;
          _versionsCount = versionsCount;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _storageService.logoutUser();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteUserAccount();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data'),
        content: const Text(
          'Are you sure you want to delete all local data? This includes all pages, comments, and settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteAllData();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deletePage(String pageId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Page'),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deletePage(pageId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Page "$title" deleted successfully')),
        );
        _loadUserData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting page: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveWrapper(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(theme),
                  const Gap(32),
                  _buildUserStats(theme),
                  const Gap(32),
                  _buildUserPages(theme),
                  const Gap(32),
                  _buildActions(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
          ),
          const Gap(16),
          Text(
            _user?['username'] ?? 'User',
            style: theme.textTheme.titleLarge,
          ),
          const Gap(4),
          Text(
            _user?['email'] ?? 'email@example.com',
            style: theme.textTheme.bodyLarge,
          ),
          const Gap(8),
          Text(
            'Member since: ${DateTime.parse(_user?['createdAt'] ?? DateTime.now().toIso8601String()).toString().substring(0, 10)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${_userPages.length}',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Gap(4),
                  Text(
                    'Pages',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$_commentsCount',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Gap(4),
                  Text(
                    'Comments',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$_versionsCount',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Gap(4),
                  Text(
                    'Versions',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPages(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Pages',
              style: theme.textTheme.titleMedium,
            ),
            if (_userPages.isNotEmpty)
              TextButton.icon(
                onPressed: () => context.push('/create-page'),
                icon: const Icon(Icons.add),
                label: const Text('Create New'),
              ),
          ],
        ),
        const Gap(16),
        _userPages.isEmpty
            ? Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 48,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const Gap(8),
                    Text(
                      'You haven\'t created any pages yet',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const Gap(16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/create-page'),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Your First Page'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userPages.length,
                itemBuilder: (context, index) {
                  final page = _userPages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(page['title']),
                      subtitle: Text(
                        'Last updated: ${DateTime.parse(page['updatedAt']).toString().substring(0, 16)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: const Icon(Icons.article),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              context.push('/page/${page['id']}');
                            },
                            tooltip: 'View or Edit',
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: theme.colorScheme.error),
                            onPressed: () => _deletePage(page['id'], page['title']),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                      onTap: () {
                        context.push('/page/${page['id']}');
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Actions',
          style: theme.textTheme.titleMedium,
        ),
        const Gap(16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.primary),
                title: const Text('Logout'),
                subtitle: const Text('Sign out from your account'),
                onTap: _logout,
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                title: const Text('Delete Account'),
                subtitle: const Text('Permanently remove your account data'),
                onTap: _deleteAccount,
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.cleaning_services, color: theme.colorScheme.error),
                title: const Text('Delete All Local Data'),
                subtitle: const Text('Clear all pages, comments, and settings'),
                onTap: _deleteAllData,
              ),
            ],
          ),
        ),
      ],
    );
  }
}