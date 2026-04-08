import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firebase_service.dart';
import '../../models/user.dart' as app_user;
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';

class AdminMembersScreen extends StatefulWidget {
  const AdminMembersScreen({super.key});

  @override
  State<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends State<AdminMembersScreen> {
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
          Text(AppLocalizations.of(context)!.manageMembers),
        ]),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm thành viên...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<app_user.User>>(
              stream: FirebaseService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải danh sách: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data ?? [];
                
                final filteredUsers = users.where((u) {
                  final name = u.name.toLowerCase();
                  final email = u.email.toLowerCase();
                  final phone = (u.phone ?? '').toLowerCase();
                  return name.contains(_searchQuery) || 
                         email.contains(_searchQuery) || 
                         phone.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text('Không tìm thấy thành viên nào', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemBuilder: (context, index) {
                    final u = filteredUsers[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U')),
                        title: Row(children: [
                          Expanded(child: Text(u.name)),
                          if ((u.role ?? 'user') == 'admin')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.adminRole,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ]),
                        subtitle: Text('${u.email}${u.phone != null && u.phone!.isNotEmpty ? ' • ${u.phone}' : ''}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (u.isDisabled)
                            const Icon(Icons.lock_outline, color: Colors.red)
                          else
                            const Icon(Icons.lock_open, color: Colors.green),
                          const SizedBox(width: 8),
                          Switch(
                            value: u.isDisabled,
                            onChanged: (v) => FirebaseService.setUserDisabled(userId: u.id, disabled: v),
                          ),
                        ]),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: filteredUsers.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
