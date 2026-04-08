import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/post.dart';
import '../../providers/post_provider.dart';
import '../../services/firebase_service.dart';
import '../../models/review.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';
import '../../config/app_theme.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async { // Thêm async
  final postProvider = Provider.of<PostProvider>(context, listen: false);
  _post = await postProvider.getPostById(widget.postId); // Thêm await
  setState(() {}); // Trigger rebuild
}

  void _contactOwner() {
    if (_post?.contactPhone == null) return;

    // TODO: Implement contact functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.contactOwner),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.phoneNumber),
            const SizedBox(height: 8),
            Text(
              _post!.contactPhone!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.email),
            const SizedBox(height: 8),
            if (_post!.contactEmail != null)
              Text(
                _post!.contactEmail!,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement call functionality
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.callNow),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePost),
        content: Text(AppLocalizations.of(context)!.confirmDeletePost),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      try {
        await postProvider.deletePost(_post!.id);
        if (!mounted) return;
        Navigator.pop(context); // Close detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deleteSuccess)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _editPost() async {
    await Navigator.pushNamed(
      context,
      AppRouter.createPost,
      arguments: _post,
    );
    _loadPost(); // Reload data after returning from edit
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = _post != null && authProvider.user?.id == _post!.owner.id;
    final isAdmin = authProvider.user?.role == 'admin';

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(title: Row(children: [WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.apartmentDetails)])),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.apartmentDetails)]),
        actions: [
          IconButton(
            onPressed: () {
              final link = 'https://wrstudios.app/post/${_post!.id}';
              Share.share('Xem căn hộ: ${_post!.title}\n$link');
            },
            icon: const Icon(Icons.share_outlined),
          ),
          if (isOwner || isAdmin)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editPost();
                } else if (value == 'delete') {
                  _deletePost();
                }
              },
              itemBuilder: (context) => [
                if (isOwner)
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.editPost),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.delete),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Images Slider
            SizedBox(
              height: 300,
              child: _post!.images.isNotEmpty
                  ? PageView.builder(
                      itemCount: _post!.images.length,
                      itemBuilder: (context, index) {
                        final url = _post!.images[index];
                        final isHttp = url.startsWith('http://') || url.startsWith('https://');
                        if (url.trim().isEmpty || !isHttp) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.home_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.home_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.home_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),
            // Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Type Badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.category_outlined, size: 16, color: Colors.purple),
                        const SizedBox(width: 6),
                        Text(
                          _post!.type,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.purple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _post!.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _post!.formattedPrice,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  StreamBuilder<List<Review>>(
                    stream: FirebaseService.getReviewsStreamLite(_post!.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 8),
                            Text('— (0)')
                          ],
                        );
                      }
                      final reviews = snapshot.data ?? [];
                      double avg = 0;
                      if (reviews.isNotEmpty) {
                        avg = reviews.map((e) => e.rating).reduce((a, b) => a + b) / reviews.length;
                      }
                      return Row(
                        children: [
                          ...List.generate(5, (i) => Icon(
                                i < avg.round() ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 18,
                              )),
                          const SizedBox(width: 8),
                          Text(reviews.isEmpty ? AppLocalizations.of(context)!.noReviews : '${avg.toStringAsFixed(1)} (${reviews.length})',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]))
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _post!.address,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (_post!.lat != null && _post!.lng != null)
                        IconButton(
                          icon: const Icon(Icons.directions, color: Colors.blue),
                          onPressed: () async {
                            final url = Uri.parse('comgooglemaps://?saddr=&daddr=${_post!.lat},${_post!.lng}&directionsmode=driving');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              final webUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${_post!.lat},${_post!.lng}');
                              if (await canLaunchUrl(webUrl)) {
                                await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                              } else if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Không thể mở Google Maps')),
                                );
                              }
                            }
                          },
                          tooltip: 'Chỉ đường',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Basic Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                          icon: Icons.bed_outlined,
                          label: '${_post!.bedrooms} PN',
                        ),
                        _buildInfoItem(
                          icon: Icons.bathtub_outlined,
                          label: '${_post!.bathrooms} WC',
                        ),
                        _buildInfoItem(
                          icon: Icons.square_foot_outlined,
                          label: '${_post!.area} m²',
                        ),
                        _buildInfoItem(
                          icon: Icons.location_city_outlined,
                          label: _post!.city,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    AppLocalizations.of(context)!.description,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _post!.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  // Amenities
                  if (_post!.amenities.isNotEmpty) ...[
                    Text(
                      AppLocalizations.of(context)!.amenities,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _post!.amenities
                          .map((amenity) => Chip(
                                label: Text(amenity),
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Owner Info
                  Text(
                    AppLocalizations.of(context)!.ownerInfo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        _post!.owner.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      _post!.owner.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(_post!.owner.phone ?? AppLocalizations.of(context)!.notUpdated),
                    trailing: const Icon(Icons.verified_outlined, color: Colors.green),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.reviews,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<Review>>(
                    stream: FirebaseService.getReviewsStream(_post!.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return StreamBuilder<List<Review>>(
                          stream: FirebaseService.getReviewsStreamLite(_post!.id),
                          builder: (context, ss) {
                            final reviews = ss.data ?? [];
                            if (reviews.isEmpty) {
                              return Text(
                                AppLocalizations.of(context)!.noReviews,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                              );
                            }
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            return Column(
                              children: reviews.map((r) {
                                final isOwn = auth.user?.id == r.userId;
                                final ago = DateTime.now().difference(r.createdAt);
                                final agoText = ago.inMinutes < 60
                                    ? AppLocalizations.of(context)!.minutesAgo(ago.inMinutes)
                                    : ago.inHours < 24
                                        ? AppLocalizations.of(context)!.hoursAgo(ago.inHours)
                                        : AppLocalizations.of(context)!.daysAgo(ago.inDays);
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(child: Text(r.userName.isNotEmpty ? r.userName[0] : '?')),
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(r.userName)),
                                      if (isOwn)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(AppLocalizations.of(context)!.youRated, style: const TextStyle(fontSize: 11)),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(5, (i) => Icon(
                                              i < r.rating ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 18,
                                            )),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(r.comment),
                                      const SizedBox(height: 4),
                                      Text(agoText, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      }
                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return Text(
                          AppLocalizations.of(context)!.noReviews,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        );
                      }
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      return Column(
                        children: reviews.map((r) {
                          final isOwn = auth.user?.id == r.userId;
                          final ago = DateTime.now().difference(r.createdAt);
                          final agoText = ago.inMinutes < 60
                              ? AppLocalizations.of(context)!.minutesAgo(ago.inMinutes)
                              : ago.inHours < 24
                                  ? AppLocalizations.of(context)!.hoursAgo(ago.inHours)
                                  : AppLocalizations.of(context)!.daysAgo(ago.inDays);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(child: Text(r.userName.isNotEmpty ? r.userName[0] : '?')),
                            title: Row(
                              children: [
                                Expanded(child: Text(r.userName)),
                                if (isOwn)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(AppLocalizations.of(context)!.youRated, style: const TextStyle(fontSize: 11)),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(5, (i) => Icon(
                                        i < r.rating ? Icons.star : Icons.star_border,
                                        color: Colors.amber,
                                        size: 18,
                                      )),
                                ),
                                const SizedBox(height: 4),
                                Text(r.comment),
                                const SizedBox(height: 4),
                                Text(agoText, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Builder(builder: (context) {
                    final auth = Provider.of<AuthProvider>(context);
                    if (!auth.isLoggedIn) {
                      return Container();
                    }
                    return _ReviewForm(postId: _post!.id);
                  }),
                ],
              ),
            ),
        ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _contactOwner,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.phone_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Liên hệ ngay'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.publicProfile, arguments: _post!.owner.id);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.profile),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final String postId;
  const _ReviewForm({required this.postId});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  int _rating = 5;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) => IconButton(
                onPressed: () {
                  setState(() {
                    _rating = i + 1;
                  });
                },
                icon: Icon(
                  i < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              )),
        ),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Viết đánh giá của bạn',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              try {
                final text = _controller.text.trim();
                if (text.isEmpty) return;
                await FirebaseService.createReview(postId: widget.postId, rating: _rating, comment: text);
                _controller.clear();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi đánh giá')));
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi gửi đánh giá: $e'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Gửi đánh giá'),
          ),
        ),
      ],
    );
  }
}
