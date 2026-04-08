import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firebase_service.dart';
import '../../models/review.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
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
          Text(AppLocalizations.of(context)!.manageReviews),
        ]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm đánh giá...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
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
            child: StreamBuilder<List<Review>>(
              stream: FirebaseService.getAllReviewsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final reviews = snapshot.data!;
                
                final filteredReviews = reviews.where((r) {
                  final name = r.userName.toLowerCase();
                  final comment = r.comment.toLowerCase();
                  return name.contains(_searchQuery) || comment.contains(_searchQuery);
                }).toList();

                if (filteredReviews.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.noReviews));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemBuilder: (context, i) {
                    final r = filteredReviews[i];
                    return Container(
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [
                        BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                      ]),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(r.userName.isNotEmpty ? r.userName[0].toUpperCase() : 'U')),
                        title: Row(children: [
                          Expanded(child: Text(r.userName)),
                          Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(r.rating.toString())]),
                        ]),
                        subtitle: Text(r.comment),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            try {
                              await FirebaseService.deleteReview(r.id);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.reviewDeleted), backgroundColor: Colors.orange),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(AppLocalizations.of(context)!.deleteReviewError(e)), backgroundColor: Colors.red),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: filteredReviews.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
