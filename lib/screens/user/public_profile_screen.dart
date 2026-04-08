import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/post_card.dart';
import '../../providers/post_provider.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';
import '../../l10n/app_localizations.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  List<dynamic> _posts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final u = await FirebaseService.getUser(widget.userId);
      final posts = await FirebaseService.getUserPosts(widget.userId);
      setState(() {
        _user = {
          'id': u?.id ?? widget.userId,
          'name': u?.name ?? 'Người dùng',
          'email': u?.email ?? '',
          'avatarUrl': u?.avatarUrl ?? '',
          'isVerified': u?.isVerified ?? false,
        };
        _posts = posts;
        _loading = false;
      });
    } catch (_) {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PostProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.profile),
        ]),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: (_user?['avatarUrl'] as String?)?.isNotEmpty == true
                          ? NetworkImage(_user!['avatarUrl'] as String)
                          : null,
                      child: ((_user?['avatarUrl'] as String?)?.isEmpty ?? true)
                          ? Text((_user?['name'] as String?)?.substring(0,1).toUpperCase() ?? 'U')
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_user?['name'] as String? ?? 'Người dùng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      if ((_user?['email'] as String?)?.isNotEmpty == true)
                        Text(_user!['email'] as String, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ])),
                    if ((_user?['isVerified'] as bool?) == true)
                      const Icon(Icons.verified, color: Colors.blue)
                  ]),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context)!.myPosts, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  if (_posts.isEmpty)
                    Center(child: Text(AppLocalizations.of(context)!.noData))
                  else
                    Column(children: [
                      ..._posts.map((post) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PostCard(
                          post: post,
                          onTap: () {
                            p.incrementPostViews(post.id);
                            Navigator.pushNamed(context, AppRouter.postDetail, arguments: post.id);
                          },
                        ),
                      ))
                    ])
                ],
              ),
            ),
    );
  }
}
