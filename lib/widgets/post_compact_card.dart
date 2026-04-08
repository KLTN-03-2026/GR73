import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../models/post.dart';

class PostCompactCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final bool isFavorited;
  final VoidCallback? onToggleFavorite;
  final double height;

  const PostCompactCard({
    super.key,
    required this.post,
    required this.onTap,
    this.isFavorited = false,
    this.onToggleFavorite,
    this.height = 210,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl = post.images.isNotEmpty ? (post.images.first) : '';
    final isHttp = imgUrl.startsWith('http://') || imgUrl.startsWith('https://');
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 6)),
          ],
        ),
        child: SizedBox(
          height: height,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: isHttp
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        highlightColor: Theme.of(context).colorScheme.surface,
                        child: Container(color: Theme.of(context).colorScheme.surface, height: 150),
                      ),
                    )
                  : Container(height: 120, color: Theme.of(context).colorScheme.surfaceContainerHighest),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                        child: Text(post.type, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(isFavorited ? Icons.favorite : Icons.favorite_border, size: 18, color: isFavorited ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant),
                        onPressed: onToggleFavorite,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(Icons.share, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        onPressed: () {
                          final link = 'https://wrstudios.app/post/${post.id}';
                          Share.share('Xem căn hộ: ${post.title}\n$link');
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${post.price.toStringAsFixed(0)} VNĐ/tháng • ${post.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
