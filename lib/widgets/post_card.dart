import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../models/post.dart';
import '../models/review.dart';
import '../services/firebase_service.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../config/app_router.dart';
import '../l10n/app_localizations.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isFavorited;
  final VoidCallback? onToggleFavorite;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.isFavorited = false,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: post.images.isNotEmpty && (post.images.first.startsWith('http://') || post.images.first.startsWith('https://'))
                      ? CachedNetworkImage(
                          imageUrl: post.images.first,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            highlightColor: Theme.of(context).colorScheme.surface,
                            child: Container(color: Theme.of(context).colorScheme.surface, height: 220),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 220,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.image_not_supported, size: 50, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          height: 220,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(Icons.home, size: 50, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                ),
                
                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: post.isAvailable ? Colors.green : Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.2), blurRadius: 4),
                        ],
                      ),
                    child: Text(
                      post.isAvailable ? 'CÒN TRỐNG' : 'ĐÃ THUÊ',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Featured Badge
                if (post.isFeatured)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.2), blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('NỔI BẬT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                // Favorite Button
                if (onToggleFavorite != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                          ],
                        ),
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : Colors.grey,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  right: 56,
                  child: GestureDetector(
                    onTap: () {
                      final link = 'https://wrstudios.app/post/${post.id}';
                      Share.share('Xem căn hộ: ${post.title}\n$link');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.share, color: Colors.grey, size: 20),
                    ),
                  ),
                ),
                // Report Button
                Positioned(
                  bottom: 12,
                  right: 100,
                  child: GestureDetector(
                    onTap: () => _showReportDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
                        ],
                      ),
                      child: const Icon(Icons.flag_outlined, color: Colors.redAccent, size: 18),
                    ),
                  ),
                ),
                  
                // Rating Badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: StreamBuilder<List<Review>>(
                      stream: FirebaseService.getReviewsStreamLite(post.id),
                      builder: (context, snapshot) {
                        final reviews = snapshot.data ?? [];
                        final count = reviews.length;
                        final avg = count > 0 
                            ? reviews.map((e) => e.rating).reduce((a, b) => a + b) / count 
                            : 0.0;
                            
                        return Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              count > 0 ? avg.toStringAsFixed(1) : 'Mới',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            if (count > 0)
                              Text(' ($count)', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                
                // Edit/Delete Actions
                if (showActions)
                  Positioned(
                    top: 12,
                    left: post.isFeatured ? 100 : 12, // Offset if featured badge exists
                    child: Row(
                      children: [
                        if (onEdit != null)
                          _actionButton(Icons.edit, Theme.of(context).colorScheme.primary, onEdit!),
                        const SizedBox(width: 8),
                        if (onDelete != null)
                          _actionButton(Icons.delete, Theme.of(context).colorScheme.error, onDelete!),
                      ],
                    ),
                  ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          post.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        post.formattedPrice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Address
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${post.address}, ${post.city}',
                          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info Row (Area, Beds, Baths)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeatureItem(context, Icons.square_foot, '${post.area.toStringAsFixed(0)}m²'),
                        _buildVerticalDivider(),
                        _buildFeatureItem(context, Icons.bed_outlined, '${post.bedrooms} PN'),
                        _buildVerticalDivider(),
                        _buildFeatureItem(context, Icons.bathtub_outlined, '${post.bathrooms} WC'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Owner & Time (tappable)
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRouter.publicProfile, arguments: post.owner.id),
                    child: Row(
                      children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        backgroundImage: post.owner.avatarUrl != null && post.owner.avatarUrl!.isNotEmpty
                            ? NetworkImage(post.owner.avatarUrl!)
                            : null,
                        child: post.owner.avatarUrl == null || post.owner.avatarUrl!.isEmpty
                            ? Text(post.owner.name[0], style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    post.owner.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (post.owner.isVerified) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.verified, size: 14, color: Theme.of(context).colorScheme.primary),
                                ]
                              ],
                            ),
                            Text(
                              _getTimeAgo(post.createdAt),
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (!ap.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseLoginToReport), backgroundColor: Colors.orange),
      );
      return;
    }
    String reason = 'spam';
    final detailsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.reportPost),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(AppLocalizations.of(context)!.reportReasonsSpam),
                  value: 'spam',
                  groupValue: reason,
                  onChanged: (v) => setState(() => reason = v ?? 'spam'),
                ),
                RadioListTile<String>(
                  title: Text(AppLocalizations.of(context)!.reportReasonsInappropriate),
                  value: 'inappropriate',
                  groupValue: reason,
                  onChanged: (v) => setState(() => reason = v ?? 'inappropriate'),
                ),
                RadioListTile<String>(
                  title: Text(AppLocalizations.of(context)!.reportReasonsFalseInfo),
                  value: 'false_info',
                  groupValue: reason,
                  onChanged: (v) => setState(() => reason = v ?? 'false_info'),
                ),
                RadioListTile<String>(
                  title: Text(AppLocalizations.of(context)!.reportReasonsScam),
                  value: 'scam',
                  groupValue: reason,
                  onChanged: (v) => setState(() => reason = v ?? 'scam'),
                ),
                RadioListTile<String>(
                  title: Text(AppLocalizations.of(context)!.reportReasonsOther),
                  value: 'other',
                  groupValue: reason,
                  onChanged: (v) => setState(() => reason = v ?? 'other'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.description,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel)),
            ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseService.createPostReport(
                    postId: post.id,
                    reporterUserId: ap.user!.id,
                    reason: reason,
                    details: detailsController.text.trim(),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.reportSubmitted), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${AppLocalizations.of(context)!.reportError} $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.12), 
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        );
      }
    );
  }

  Widget _buildVerticalDivider() {
    return Builder(
      builder: (context) {
        return Container(height: 20, width: 1, color: Theme.of(context).colorScheme.outlineVariant);
      }
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ';
    } else {
      return '${difference.inMinutes} phút';
    }
  }
}
