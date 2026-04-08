import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_router.dart';
import '../../widgets/common/wr_logo.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Web Layout (Grid)
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            WRLogo(size: 28, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.adminPortal),
          ]),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRouter.home),
              icon: const Icon(Icons.home),
              label: Text(AppLocalizations.of(context)!.viewHome),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.all(32),
              childAspectRatio: 1.5,
              children: [
                _webTile(context, Icons.people_outline, AppLocalizations.of(context)!.manageMembers, AppLocalizations.of(context)!.manageMembersDesc, AppRouter.adminMembers),
                _webTile(context, Icons.post_add_outlined, AppLocalizations.of(context)!.managePosts, AppLocalizations.of(context)!.managePostsDesc, AppRouter.adminPosts),
                _webTile(context, Icons.reviews_outlined, AppLocalizations.of(context)!.manageReviews, AppLocalizations.of(context)!.manageReviewsDesc, AppRouter.adminReviews),
                _webTile(context, Icons.report_gmailerrorred_outlined, AppLocalizations.of(context)!.manageContentReports, AppLocalizations.of(context)!.manageContentReportsDesc, AppRouter.adminContentReports),
                _webTile(context, Icons.receipt_long, AppLocalizations.of(context)!.managePayments, AppLocalizations.of(context)!.managePaymentsDesc, AppRouter.adminPayments),
                _webTile(context, Icons.settings_applications_outlined, AppLocalizations.of(context)!.managePremium, AppLocalizations.of(context)!.managePlansDesc, AppRouter.managePlans),
                _webTile(context, Icons.bar_chart, AppLocalizations.of(context)!.reportsAndStats, AppLocalizations.of(context)!.systemOverview, AppRouter.adminReports),
              ],
            ),
          ),
        ),
      );
    }

    // Mobile Layout (List)
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.adminDashboard),
        ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _tile(context, Icons.people_outline, AppLocalizations.of(context)!.manageMembers, AppLocalizations.of(context)!.manageMembersDesc, AppRouter.adminMembers),
          const SizedBox(height: 12),
          _tile(context, Icons.post_add_outlined, AppLocalizations.of(context)!.managePosts, AppLocalizations.of(context)!.managePostsDesc, AppRouter.adminPosts),
          const SizedBox(height: 12),
          _tile(context, Icons.reviews_outlined, AppLocalizations.of(context)!.manageReviews, AppLocalizations.of(context)!.manageReviewsDesc, AppRouter.adminReviews),
          const SizedBox(height: 12),
          _tile(context, Icons.report_gmailerrorred_outlined, AppLocalizations.of(context)!.manageContentReports, AppLocalizations.of(context)!.manageContentReportsDesc, AppRouter.adminContentReports),
          const SizedBox(height: 12),
          _tile(context, Icons.receipt_long, AppLocalizations.of(context)!.managePayments, AppLocalizations.of(context)!.managePaymentsDesc, AppRouter.adminPayments),
          const SizedBox(height: 12),
          _tile(context, Icons.settings_applications_outlined, AppLocalizations.of(context)!.managePremium, AppLocalizations.of(context)!.managePlansDesc, AppRouter.managePlans),
          const SizedBox(height: 12),
          _tile(context, Icons.bar_chart, AppLocalizations.of(context)!.reportsAndStats, AppLocalizations.of(context)!.systemOverview, AppRouter.adminReports),
        ]),
      ),
    );
  }

  Widget _webTile(BuildContext context, IconData icon, String title, String subtitle, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
