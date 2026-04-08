import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firebase_service.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.reportsAndStats),
        ]),
      ),
      body: FutureBuilder<Map<String, int>>(
        future: FirebaseService.getCounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          Widget tile(IconData icon, String title, int value) {
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6)),
              ]),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.purple[50], borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                Text(value.toString(), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ]),
            );
          }
          final header = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(AppLocalizations.of(context)!.systemOverview, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          );
          final list = <Widget>[
            header,
            const SizedBox(height: 12),
            tile(Icons.people_outline, AppLocalizations.of(context)!.users, data['users'] ?? 0),
            tile(Icons.post_add_outlined, AppLocalizations.of(context)!.posts, data['posts'] ?? 0),
            tile(Icons.reviews_outlined, AppLocalizations.of(context)!.reviews, data['reviews'] ?? 0),
          ];
          return ListView(
            children: [
              ...list,
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(AppLocalizations.of(context)!.revenueStats, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              FutureBuilder<Map<String, dynamic>>(
                future: FirebaseService.getRevenueStats(days: 30),
                builder: (context, sRev) {
                  if (!sRev.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final rev = sRev.data!;
                  Widget revTile(String title, String value) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6)),
                      ]),
                      child: Row(children: [
                        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ]),
                    );
                  }
                  String vnd(num v) {
                    final s = v.toStringAsFixed(0);
                    final b = StringBuffer();
                    for (int i = 0; i < s.length; i++) {
                      final idx = s.length - i - 1;
                      b.write(s[idx]);
                      if (i % 3 == 2 && idx != 0) b.write('.');
                    }
                    return b.toString().split('').reversed.join();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      revTile(AppLocalizations.of(context)!.today, '${vnd(rev['today'] ?? 0)} ₫'),
                      revTile(AppLocalizations.of(context)!.last7Days, '${vnd(rev['last7Days'] ?? 0)} ₫'),
                      revTile(AppLocalizations.of(context)!.last30Days, '${vnd(rev['last30Days'] ?? 0)} ₫'),
                      revTile(AppLocalizations.of(context)!.transactionsSuccess, '${rev['successCount'] ?? 0}'),
                      revTile(AppLocalizations.of(context)!.transactionsFailed, '${rev['failedCount'] ?? 0}'),
                      revTile(AppLocalizations.of(context)!.transactionsSubmitted, '${rev['submittedCount'] ?? 0}'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(AppLocalizations.of(context)!.aiStats30Days, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              FutureBuilder<Map<String, dynamic>>(
                future: FirebaseService.getRecommendEventStats(days: 30),
                builder: (context, s2) {
                  if (!s2.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final stats = s2.data!;
                  Widget statTile(String title, String value) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6)),
                      ]),
                      child: Row(children: [
                        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ]),
                    );
                  }
                  final topCities = (stats['top_cities'] as List<dynamic>)
                      .cast<Map<String, dynamic>>();
                  final topPosts = (stats['top_posts'] as List<dynamic>)
                      .cast<Map<String, dynamic>>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      statTile(AppLocalizations.of(context)!.totalEvents, '${stats['total_events']}'),
                      statTile(AppLocalizations.of(context)!.postViews, '${stats['views']}'),
                      statTile(AppLocalizations.of(context)!.addToFavorites, '${stats['favorite_add']}'),
                      statTile(AppLocalizations.of(context)!.removeFromFavorites, '${stats['favorite_remove']}'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(AppLocalizations.of(context)!.topCities, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      ...topCities.map((e) => Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                            ]),
                            child: Row(
                              children: [
                                Expanded(child: Text((e['city'] as String?)?.isNotEmpty == true ? e['city'] as String : AppLocalizations.of(context)!.other)),
                                Text('${e['count']}'),
                              ],
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(AppLocalizations.of(context)!.topPosts, style: Theme.of(context).textTheme.titleMedium),
                      ),
                      ...topPosts.map((e) => Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                            ]),
                            child: Row(
                              children: [
                                Expanded(child: Text('${AppLocalizations.of(context)!.postLabel}${e['postId']}')),
                                Text('${e['count']}'),
                              ],
                            ),
                          )),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
