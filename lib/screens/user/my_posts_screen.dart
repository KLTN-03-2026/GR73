import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:App_WRStudios/providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';
import '../../config/app_router.dart';
import '../../widgets/common/wr_logo.dart';

import '../../l10n/app_localizations.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

Future<void> _loadData() async {
  final postProvider = Provider.of<PostProvider>(context, listen: false);
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  if (authProvider.user != null) {
    await postProvider.fetchMyPosts(authProvider.user!.id); // Thêm userId
  }
}

  void _deletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePost),
        content: Text(AppLocalizations.of(context)!.confirmDeletePost),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final postProvider = Provider.of<PostProvider>(context, listen: false);
              try {
                await postProvider.deletePost(postId);
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.deleteSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppLocalizations.of(context)!.error}: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.myPosts),
        ]),
        actions: [
          IconButton(
            onPressed: () {
              final postProvider = Provider.of<PostProvider>(context, listen: false);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final userRole = authProvider.user?.role ?? 'user';
              final postCount = postProvider.myPosts.length;
              
              if (userRole == 'user' && postCount >= 3) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.postLimitReached(3)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.close),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRouter.membership);
                        },
                        child: Text(AppLocalizations.of(context)!.upgradeNow),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.pushNamed(context, AppRouter.createPost);
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: postProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bài đăng của bạn...',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final filteredPosts = postProvider.myPosts.where((p) {
                        return p.title.toLowerCase().contains(_searchQuery);
                      }).toList();

                      if (postProvider.myPosts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.post_add_outlined,
                                size: 80,
                                color: Theme.of(context).colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.noPostsYet,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.beTheFirstToPost,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRouter.createPost);
                                },
                                child: Text(AppLocalizations.of(context)!.createNewPost),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (filteredPosts.isEmpty) {
                         return const Center(child: Text('Không tìm thấy bài đăng nào'));
                      }

                      return RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = filteredPosts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PostCard(
                                post: post,
                                showActions: true,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.postDetail,
                                    arguments: post.id,
                                  );
                                },
                                onEdit: () {
                                  // TODO: Implement edit post
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.createPost,
                                    arguments: post,
                                  );
                                },
                                onDelete: () => _deletePost(post.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
