import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firebase_service.dart';
import '../../models/post.dart';
import '../../config/app_router.dart';
import '../../widgets/common/wr_logo.dart';
import '../../widgets/post_card.dart';

class AdminPostsScreen extends StatefulWidget {
  const AdminPostsScreen({super.key});

  @override
  State<AdminPostsScreen> createState() => _AdminPostsScreenState();
}

class _AdminPostsScreenState extends State<AdminPostsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.managePosts),
        ]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tin đăng...',
                prefixIcon: const Icon(Icons.search),
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
            child: StreamBuilder<List<Post>>(
              stream: FirebaseService.getAllPostsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data!;
                
                final filteredPosts = posts.where((p) {
                  final title = p.title.toLowerCase();
                  final desc = p.description.toLowerCase();
                  final address = p.address.toLowerCase();
                  return title.contains(_searchQuery) || 
                         desc.contains(_searchQuery) || 
                         address.contains(_searchQuery);
                }).toList();

                if (filteredPosts.isEmpty) {
                  return const Center(child: Text('Không tìm thấy tin đăng nào'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, i) {
                    final p = filteredPosts[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          PostCard(
                            post: p,
                            showActions: false,
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.postDetail, arguments: p.id);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: p.isApproved ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: p.isApproved ? Colors.green : Colors.orange),
                                ),
                                child: Row(
                                  children: [
                                    Icon(p.isApproved ? Icons.verified : Icons.hourglass_empty, size: 18, color: p.isApproved ? Colors.green : Colors.orange),
                                    const SizedBox(width: 6),
                                    Text(p.isApproved ? AppLocalizations.of(context)!.approved : AppLocalizations.of(context)!.pending, style: TextStyle(color: p.isApproved ? Colors.green : Colors.orange)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () async {
                                  try {
                                    await FirebaseService.setPostApproved(postId: p.id, approved: !p.isApproved);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(!p.isApproved ? AppLocalizations.of(context)!.postApproved : AppLocalizations.of(context)!.postUnapproved),
                                        backgroundColor: !p.isApproved ? Colors.green : Colors.orange,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppLocalizations.of(context)!.updateApprovalError(e)), backgroundColor: Colors.red),
                                    );
                                  }
                                },
                                icon: Icon(p.isApproved ? Icons.remove_circle_outline : Icons.check_circle, color: p.isApproved ? Colors.orange : Colors.green),
                                label: Text(p.isApproved ? AppLocalizations.of(context)!.unapprove : AppLocalizations.of(context)!.approve),
                                style: TextButton.styleFrom(
                                  foregroundColor: p.isApproved ? Colors.orange : Colors.green,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  try {
                                    await FirebaseService.deletePost(p.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(AppLocalizations.of(context)!.postDeleted), backgroundColor: Colors.orange),
                                    );
                                  } catch (e) {
                                    try {
                                      await FirebaseService.setPostAvailability(postId: p.id, available: false);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocalizations.of(context)!.cannotDeletePostHidden), backgroundColor: Colors.orange),
                                      );
                                    } catch (_) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(AppLocalizations.of(context)!.deleteError(e)), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: AppLocalizations.of(context)!.delete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
