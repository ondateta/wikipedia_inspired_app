import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:template/src/design_system/app_theme.dart';
import 'package:template/src/design_system/responsive_values.dart';
import 'package:template/src/design_system/responsive_wrapper.dart';
import 'package:template/src/models/page.dart';
import 'package:template/src/services/local_storage_service.dart';

class EditPageView extends StatefulWidget {
  final String pageId;

  const EditPageView({super.key, required this.pageId});

  @override
  State<EditPageView> createState() => _EditPageViewState();
}

class _EditPageViewState extends State<EditPageView> with SingleTickerProviderStateMixin {
  final LocalStorageService _storageService = LocalStorageService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  WikiPage? _page;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadPageData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pageData = await _storageService.getPage(widget.pageId);
      if (pageData != null) {
        final page = WikiPage.fromMap(pageData);
        
        setState(() {
          _page = page;
          _titleController.text = page.title;
          _contentController.text = page.content;
        });
        _animationController.forward();
      } else {
        setState(() {
          _errorMessage = "Page not found";
        });
      }
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

  Future<void> _savePage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
        _errorMessage = null;
      });

      try {
        final user = await _storageService.getCurrentUser();
        if (user != null) {
          await _storageService.updatePage(
            pageId: widget.pageId,
            title: _titleController.text,
            content: _contentController.text,
            authorId: user['username'] ?? 'Anonymous',
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Page updated successfully!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage = "User not found. Please login again.";
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = "Failed to update page: ${e.toString()}";
        });
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showVersionsDialog() {
    if (_page == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Version History'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: ListView.builder(
            itemCount: _page!.versions.length,
            itemBuilder: (context, index) {
              final version = _page!.versions[_page!.versions.length - 1 - index];
              return ListTile(
                title: Text('Version ${version.versionId}'),
                subtitle: Text('${version.timestamp.toString().substring(0, 16)} by ${version.authorId}'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _contentController.text = version.content;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reverted to version ${version.versionId}')),
                  );
                },
              );
            },
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Page')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _page == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(_errorMessage!),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Page'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showVersionsDialog,
            tooltip: 'View Version History',
          ),
          TextButton.icon(
            onPressed: _isSaving ? null : _savePage,
            icon: _isSaving 
                ? SizedBox(
                    height: 16, 
                    width: 16, 
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : Icon(
                    Icons.save_outlined,
                    color: theme.colorScheme.primary,
                  ),
            label: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(_animation),
          child: SingleChildScrollView(
            child: ResponsiveWrapper(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: responsiveValue<EdgeInsets>(
                    context,
                    mobile: () => const EdgeInsets.all(12.0),
                    orElse: () => const EdgeInsets.all(20.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 0,
                        color: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: responsiveValue<EdgeInsets>(
                            context,
                            mobile: () => const EdgeInsets.all(12.0),
                            orElse: () => const EdgeInsets.all(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Page Title',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const Gap(8),
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: 'Enter a clear, descriptive title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                                    borderSide: BorderSide(color: theme.colorScheme.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                                    borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary, 
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                                    borderSide: BorderSide(color: theme.colorScheme.error),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  prefixIcon: Icon(
                                    Icons.title,
                                    color: theme.colorScheme.primary.withOpacity(0.7),
                                  ),
                                ),
                                style: theme.textTheme.titleMedium,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      Card(
                        elevation: 0,
                        color: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: responsiveValue<EdgeInsets>(
                            context,
                            mobile: () => const EdgeInsets.all(12.0),
                            orElse: () => const EdgeInsets.all(16.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'Page Content',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              Text(
                                'Markdown is supported',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                              const Gap(16),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: responsiveValue<EdgeInsets>(
                                        context,
                                        mobile: () => const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                        orElse: () => const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(AppTheme.borderRadiusRegular - 1),
                                          topRight: Radius.circular(AppTheme.borderRadiusRegular - 1),
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.format_bold),
                                              tooltip: 'Bold',
                                              onPressed: () {
                                                final text = _contentController.text;
                                                final selection = _contentController.selection;
                                                final selectedText = text.substring(selection.start, selection.end);
                                                final newText = text.replaceRange(selection.start, selection.end, '**$selectedText**');
                                                _contentController.text = newText;
                                                _contentController.selection = TextSelection.collapsed(offset: selection.start + 2);
                                              },
                                              iconSize: responsiveValue<double>(
                                                context,
                                                mobile: () => 18,
                                                orElse: () => 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Gap(responsiveValue<double>(
                                              context,
                                              mobile: () => 10,
                                              orElse: () => 16,
                                            )),
                                            IconButton(
                                              icon: const Icon(Icons.format_italic),
                                              tooltip: 'Italic',
                                              onPressed: () {
                                                final text = _contentController.text;
                                                final selection = _contentController.selection;
                                                final selectedText = text.substring(selection.start, selection.end);
                                                final newText = text.replaceRange(selection.start, selection.end, '*$selectedText*');
                                                _contentController.text = newText;
                                                _contentController.selection = TextSelection.collapsed(offset: selection.start + 1);
                                              },
                                              iconSize: responsiveValue<double>(
                                                context,
                                                mobile: () => 18,
                                                orElse: () => 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Gap(responsiveValue<double>(
                                              context,
                                              mobile: () => 10,
                                              orElse: () => 16,
                                            )),
                                            IconButton(
                                              icon: const Icon(Icons.format_list_bulleted),
                                              tooltip: 'Bulleted list',
                                              onPressed: () {
                                                final text = _contentController.text;
                                                final selection = _contentController.selection;
                                                final selectedText = text.substring(selection.start, selection.end);
                                                final newText = text.replaceRange(selection.start, selection.end, '- $selectedText');
                                                _contentController.text = newText;
                                                _contentController.selection = TextSelection.collapsed(offset: selection.start + 2);
                                              },
                                              iconSize: responsiveValue<double>(
                                                context,
                                                mobile: () => 18,
                                                orElse: () => 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Gap(responsiveValue<double>(
                                              context,
                                              mobile: () => 10,
                                              orElse: () => 16,
                                            )),
                                            IconButton(
                                              icon: const Icon(Icons.title),
                                              tooltip: 'Heading',
                                              onPressed: () {
                                                final text = _contentController.text;
                                                final selection = _contentController.selection;
                                                final selectedText = text.substring(selection.start, selection.end);
                                                final newText = text.replaceRange(selection.start, selection.end, '## $selectedText');
                                                _contentController.text = newText;
                                                _contentController.selection = TextSelection.collapsed(offset: selection.start + 3);
                                              },
                                              iconSize: responsiveValue<double>(
                                                context,
                                                mobile: () => 18,
                                                orElse: () => 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Gap(responsiveValue<double>(
                                              context,
                                              mobile: () => 10,
                                              orElse: () => 16,
                                            )),
                                            IconButton(
                                              icon: const Icon(Icons.link),
                                              tooltip: 'Link',
                                              onPressed: () {
                                                final text = _contentController.text;
                                                final selection = _contentController.selection;
                                                final selectedText = text.substring(selection.start, selection.end);
                                                final newText = text.replaceRange(selection.start, selection.end, '[$selectedText](url)');
                                                _contentController.text = newText;
                                                _contentController.selection = TextSelection.collapsed(offset: selection.start + selectedText.length + 2);
                                              },
                                              iconSize: responsiveValue<double>(
                                                context,
                                                mobile: () => 18,
                                                orElse: () => 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _contentController,
                                      decoration: InputDecoration(
                                        hintText: "Start writing your page content here...",
                                        border: InputBorder.none,
                                        contentPadding: responsiveValue<EdgeInsets>(
                                          context,
                                          mobile: () => const EdgeInsets.all(12),
                                          orElse: () => const EdgeInsets.all(16),
                                        ),
                                        filled: true,
                                        fillColor: theme.colorScheme.surface,
                                      ),
                                      maxLines: responsiveValue<int>(
                                        context,
                                        mobile: () => 10,
                                        orElse: () => 15,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter content';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const Gap(16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusRegular),
                            border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Gap(24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _savePage,
                          icon: _isSaving 
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.save),
                          label: Text(
                            _isSaving ? 'Saving...' : 'Save Changes',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}