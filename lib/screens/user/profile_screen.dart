import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:App_WRStudios/config/app_theme.dart';
import 'package:App_WRStudios/l10n/app_localizations.dart';
import '../../models/membership.dart';
import '../../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/image_picker_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/firebase_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../config/app_router.dart';
import '../../config/constants.dart';
import '../../widgets/common/wr_logo.dart';
import '../../widgets/settings/settings_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ap = Provider.of<AuthProvider>(context, listen: false);
      if (ap.user != null) {
        await ap.refreshUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Row(children: [WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.profile)])),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.pleaseLoginProfile),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
                text: AppLocalizations.of(context)!.login,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)), const SizedBox(width: 8), Text(AppLocalizations.of(context)!.profile)]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Builder(builder: (context) {
                    final url = user.avatarUrl ?? '';
                    final isHttp = url.startsWith('http://') || url.startsWith('https://');
                    if (!isHttp) {
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            highlightColor: Theme.of(context).colorScheme.surface,
                            child: Container(width: 100, height: 100, color: Theme.of(context).colorScheme.surface),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user.isVerified)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Colors.green[400],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(AppLocalizations.of(context)!.verified, style: TextStyle(color: Colors.green[400], fontWeight: FontWeight.w500)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Profile Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoItem(
                    context,
                    icon: Icons.phone_outlined,
                    label: AppLocalizations.of(context)!.phone,
                    value: user.phone ?? AppLocalizations.of(context)!.notUpdated,
                  ),
                  const Divider(),
                  _buildInfoItem(
                    context,
                    icon: Icons.date_range_outlined,
                    label: AppLocalizations.of(context)!.joinedDate,
                    value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                  ),
                  const Divider(),
                  _buildInfoItem(
                    context,
                    icon: Icons.person_outline,
                    label: AppLocalizations.of(context)!.role,
                    value: user.role == 'admin' ? AppLocalizations.of(context)!.admin : AppLocalizations.of(context)!.user,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Membership
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Builder(builder: (context) {
                final mId = user.membershipId;
                final hasMembership = (mId != null && mId.isNotEmpty);
                final name = hasMembership ? (Membership.plans().firstWhere((p) => p.id == mId, orElse: () => Membership.plans().first).name) : 'Chưa có gói';
                return Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Gói hiện tại: $name')),
                    if (hasMembership)
                      TextButton(
                        onPressed: () async {
                          await FirebaseService.cancelMembership(user.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy gói'), backgroundColor: Colors.red));
                        },
                        child: const Text('Hủy gói'),
                      ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 24),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.post_add_outlined),
                    title: Text(AppLocalizations.of(context)!.myPosts),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, AppRouter.myPosts);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(AppLocalizations.of(context)!.editProfile),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showEditProfileDialog(context, user);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(AppLocalizations.of(context)!.settings),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  SettingsSection(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              text: AppLocalizations.of(context)!.logout,
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, user) {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone ?? '');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    XFile? selectedAvatar;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.editProfile),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.primaryColor,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: selectedAvatar != null
                            ? Image.file(File(selectedAvatar!.path), width: 80, height: 80, fit: BoxFit.cover)
                            : (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                                ? Image.network(user.avatarUrl!, width: 80, height: 80, fit: BoxFit.cover)
                                : Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: TextStyle(fontSize: 28, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await ImagePickerService.showImageSourceDialog(context);
                            if (picked != null) {
                              setState(() => selectedAvatar = picked);
                            }
                          },
                          icon: const Icon(Icons.photo_camera),
                          label: Text(AppLocalizations.of(context)!.changeAvatar),
                        ),
                        if (selectedAvatar != null || (user.avatarUrl ?? '').isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() => selectedAvatar = null);
                            },
                            child: Text(AppLocalizations.of(context)!.deletePhoto),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.fullName,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.phone,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String? avatarUrl;
                    try {
                      if (selectedAvatar != null) {
                        final urls = await CloudinaryService.uploadPostImages([selectedAvatar!]);
                        if (urls.isNotEmpty) avatarUrl = urls.first;
                      }
                      await FirebaseService.updateUserProfile(
                        userId: user.id,
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        avatarUrl: avatarUrl,
                      );
                      await authProvider.updateProfile(
                        nameController.text.trim(),
                        phoneController.text.trim(),
                        avatarUrl,
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.updateProfileSuccess), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${AppLocalizations.of(context)!.updateProfileError}$e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout),
          content: Text(AppLocalizations.of(context)!.confirmLogout),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (!context.mounted) return;
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRouter.login);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
      },
    );
  }
}
