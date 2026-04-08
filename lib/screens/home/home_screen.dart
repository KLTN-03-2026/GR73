import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:App_WRStudios/config/app_theme.dart';
import 'package:App_WRStudios/l10n/app_localizations.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/post_provider.dart';
import '../../widgets/post_card.dart';
import '../../config/app_router.dart';
import '../../config/constants.dart';
import '../../widgets/common/wr_logo.dart';
import '../../widgets/skeleton_post_card.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/post_compact_card.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _showHistory = false;
  String _selectedCity = 'Tất cả';
  String _selectedType = 'Tất cả';
  List<String> _selectedAmenities = [];
  Timer? _searchDebounce;
  String _sortMode = 'newest';

  final List<String> _amenities = [
    'Máy lạnh',
    'Máy giặt',
    'Tủ bếp',
    'Internet',
    'Truyền hình cáp',
    'Chỗ đậu xe',
    'Bảo vệ 24/7',
    'Hồ bơi',
    'Phòng gym',
    'Khu vui chơi trẻ em',
    'Ban công/sân thượng',
    'Hệ thống an ninh',
    'Thang máy',
    'Nhà để xe',
    'Cửa sổ lớn',
  ];

  String _getLocalizedAmenity(BuildContext context, String amenity) {
    final loc = AppLocalizations.of(context)!;
    switch (amenity) {
      case 'Máy lạnh': return loc.amenityAC;
      case 'Máy giặt': return loc.amenityWashingMachine;
      case 'Tủ bếp': return loc.amenityKitchen;
      case 'Internet': return loc.amenityInternet;
      case 'Truyền hình cáp': return loc.amenityCableTV;
      case 'Chỗ đậu xe': return loc.amenityParking;
      case 'Bảo vệ 24/7': return loc.amenitySecurity;
      case 'Hồ bơi': return loc.amenityPool;
      case 'Phòng gym': return loc.amenityGym;
      case 'Khu vui chơi trẻ em': return loc.amenityPlayground;
      case 'Ban công/sân thượng': return loc.amenityBalcony;
      case 'Hệ thống an ninh': return loc.amenitySecuritySystem;
      case 'Thang máy': return loc.amenityElevator;
      case 'Nhà để xe': return loc.amenityGarage;
      case 'Cửa sổ lớn': return loc.amenityLargeWindows;
      case 'Nội thất đầy đủ': return loc.amenityFurnished;
      default: return amenity;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _showHistory = _searchFocusNode.hasFocus;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkWebAdminRedirect();
      _loadData();
    });
    RecommendationService.init();
  }
  
  void _checkWebAdminRedirect() {
    // no-op: allow admin to view Home on web
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _showFilterSheet() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final (minPrice, maxPrice) = postProvider.getPriceRange();
    final (minArea, maxArea) = postProvider.getAreaRange();
    
    // Ensure valid ranges
    final safeMinPrice = minPrice;
    final safeMaxPrice = maxPrice > minPrice ? maxPrice : minPrice + 10000000;
    final safeMinArea = minArea;
    final safeMaxArea = maxArea > minArea ? maxArea : minArea + 100;

    RangeValues currentPriceRange = RangeValues(safeMinPrice, safeMaxPrice);
    RangeValues currentAreaRange = RangeValues(safeMinArea, safeMaxArea);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.filterSearch,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          // Price Filter
                          Text(
                            AppLocalizations.of(context)!.priceRange,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          RangeSlider(
                            values: currentPriceRange,
                            min: safeMinPrice,
                            max: safeMaxPrice,
                            divisions: 100,
                            labels: RangeLabels(
                              '${(currentPriceRange.start/1000000).toStringAsFixed(1)}tr',
                              '${(currentPriceRange.end/1000000).toStringAsFixed(1)}tr',
                            ),
                            onChanged: (values) {
                              setStateSheet(() => currentPriceRange = values);
                            },
                          ),
                          Text(
                            '${(currentPriceRange.start/1000000).toStringAsFixed(1)} triệu - ${(currentPriceRange.end/1000000).toStringAsFixed(1)} triệu',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          
                          const SizedBox(height: 24),
                          // Area Filter
                          Text(
                            AppLocalizations.of(context)!.areaRange,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          RangeSlider(
                            values: currentAreaRange,
                            min: safeMinArea,
                            max: safeMaxArea,
                            divisions: 100,
                            labels: RangeLabels(
                              '${currentAreaRange.start.round()}m²',
                              '${currentAreaRange.end.round()}m²',
                            ),
                            onChanged: (values) {
                              setStateSheet(() => currentAreaRange = values);
                            },
                          ),
                          Text(
                            '${currentAreaRange.start.round()}m² - ${currentAreaRange.end.round()}m²',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),

                          const SizedBox(height: 24),
                          Text(
                            AppLocalizations.of(context)!.amenities,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.selectAmenities,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _amenities.map((amenity) {
                              final isSelected = _selectedAmenities.contains(amenity);
                              return FilterChip(
                                label: Text(_getLocalizedAmenity(context, amenity)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setStateSheet(() {
                                    if (selected) {
                                      _selectedAmenities.add(amenity);
                                    } else {
                                      _selectedAmenities.remove(amenity);
                                    }
                                  });
                                },
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                checkmarkColor: AppTheme.primaryColor,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.outlineVariant,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected ? AppTheme.primaryColor : Theme.of(context).colorScheme.onSurface,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply Filters
                        final p = Provider.of<PostProvider>(context, listen: false);
                        p.applyFilters(
                          city: _selectedCity == 'Tất cả' ? null : _selectedCity,
                          type: _selectedType == 'Tất cả' ? null : _selectedType,
                          amenities: _selectedAmenities,
                          minPrice: currentPriceRange.start,
                          maxPrice: currentPriceRange.end,
                          minArea: currentAreaRange.start,
                          maxArea: currentAreaRange.end,
                        );
                        // Trigger main UI update (optional, since provider notifies)
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.apply,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadData() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.fetchPosts();
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _openSaveSearchDialog() async {
    final loc = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: loc.mySearch);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.saveSearch),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: loc.searchName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.save)),
        ],
      ),
    );
    if (result == true) {
      final p = Provider.of<PostProvider>(context, listen: false);
      await p.addSavedSearch(
        name: nameController.text.trim().isEmpty ? loc.mySearch : nameController.text.trim(),
        query: _searchController.text.trim(),
        city: _selectedCity,
        type: _selectedType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    final width = MediaQuery.of(context).size.width;
    final compact = width < 420;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WRLogo(
              size: compact ? 28 : 32,
              onTap: () {
                final postProvider = Provider.of<PostProvider>(context, listen: false);
                postProvider.searchPosts('');
                setState(() {
                  _searchController.clear();
                  _selectedCity = 'Tất cả';
                  _selectedType = 'Tất cả';
                });
              },
            ),
            if (!compact) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'WR Studios',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Upload Icon
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.cloud_upload_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
              tooltip: AppLocalizations.of(context)!.createPost,
              onPressed: () {
                if (authProvider.isLoggedIn) {
                  final role = authProvider.user?.role ?? 'user';
                  final quota = authProvider.user?.postQuota ?? 0;
                  if (role != 'admin' && quota <= 0) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.outOfQuotaTitle),
                        content: Text(AppLocalizations.of(context)!.outOfQuotaMsg),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.close)),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, AppRouter.membership);
                            },
                            child: Text(AppLocalizations.of(context)!.upgradeNow),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, AppRouter.createPost);
                  }
                } else {
                   Navigator.pushNamed(context, AppRouter.login);
                }
              },
            ),
          ),
          
          // Membership Icon (hide for admin)
          if (!authProvider.isLoggedIn || (authProvider.user?.role ?? 'user') != 'admin')
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.credit_card_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
              tooltip: AppLocalizations.of(context)!.membership,
              onPressed: () {
                 if (authProvider.isLoggedIn) {
                   Navigator.pushNamed(context, AppRouter.membership);
                 } else {
                   Navigator.pushNamed(context, AppRouter.login);
                 }
              },
            ),
          ),

          // Menu Popup
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              offset: const Offset(0, 50),
              onSelected: (value) async {
                switch (value) {
                  case 'createPost':
                    if (authProvider.isLoggedIn) {
                      final role = authProvider.user?.role ?? 'user';
                      final quota = authProvider.user?.postQuota ?? 0;
                      if (role != 'admin' && quota <= 0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppLocalizations.of(context)!.outOfQuotaTitle),
                            content: Text(AppLocalizations.of(context)!.outOfQuotaMsg),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.close)),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, AppRouter.membership);
                                },
                                child: Text(AppLocalizations.of(context)!.upgradeNow),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, AppRouter.createPost);
                      }
                    } else {
                      Navigator.pushNamed(context, AppRouter.login);
                    }
                    break;
                  case 'myPosts':
                    Navigator.pushNamed(context, AppRouter.myPosts);
                    break;
                  case 'membership':
                    Navigator.pushNamed(context, AppRouter.membership);
                    break;
                  case 'map':
                    Navigator.pushNamed(context, AppRouter.map);
                    break;
                  case 'profile':
                    Navigator.pushNamed(context, AppRouter.profile);
                    break;
                  case 'settings':
                    Navigator.pushNamed(context, AppRouter.settings);
                    break;
                  case 'admin':
                    Navigator.pushNamed(context, AppRouter.admin);
                    break;
                  case 'cloud':
                    Navigator.pushNamed(context, AppRouter.cloudinaryTest);
                    break;
                }
              },
              itemBuilder: (context) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final items = <PopupMenuEntry<String>>[];

                // User Section Header
                if (authProvider.isLoggedIn) {
                  items.add(PopupMenuItem(
                    enabled: false,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: authProvider.user?.avatarUrl != null 
                              ? NetworkImage(authProvider.user!.avatarUrl!) 
                              : null,
                          child: authProvider.user?.avatarUrl == null 
                              ? Text(authProvider.user?.name[0] ?? 'U', style: const TextStyle(fontWeight: FontWeight.bold)) 
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(authProvider.user?.name ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                              Text(authProvider.user?.email ?? '', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
                  items.add(const PopupMenuDivider());
                }

                // Main Actions with Icons
                if (authProvider.isLoggedIn) {
                   items.add(_buildMenuItem('createPost', Icons.add_circle_outline, AppLocalizations.of(context)!.createPost));
                   items.add(_buildMenuItem('myPosts', Icons.list_alt, AppLocalizations.of(context)!.myPosts));
                   items.add(_buildMenuItem('membership', Icons.diamond_outlined, AppLocalizations.of(context)!.membership));
                   items.add(const PopupMenuDivider());
                }

                // Maps
                items.add(_buildMenuItem('map', Icons.map_outlined, AppLocalizations.of(context)!.mapApartment));
                items.add(const PopupMenuDivider());

                // Admin
                if (authProvider.user?.role == 'admin') {
                   items.add(_buildMenuItem('admin', Icons.dashboard_outlined, AppLocalizations.of(context)!.adminDashboard));
                   items.add(_buildMenuItem('cloud', Icons.cloud_outlined, AppLocalizations.of(context)!.cloudinaryTest));
                   items.add(const PopupMenuDivider());
                }

                // Settings & Profile
                items.add(_buildMenuItem('profile', Icons.person_outline, AppLocalizations.of(context)!.profile));
                items.add(_buildMenuItem('settings', Icons.settings_outlined, AppLocalizations.of(context)!.settings));

                return items;
              },
            ),
          ),
          
          // User Avatar (Direct Link to Profile)
          if (authProvider.isLoggedIn)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRouter.profile),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  backgroundImage: (authProvider.user?.avatarUrl != null &&
                          (authProvider.user!.avatarUrl!.startsWith('http://') || authProvider.user!.avatarUrl!.startsWith('https://')))
                      ? NetworkImage(authProvider.user!.avatarUrl!)
                      : null,
                  child: (authProvider.user?.avatarUrl == null ||
                          !(authProvider.user!.avatarUrl!.startsWith('http://') || authProvider.user!.avatarUrl!.startsWith('https://')))
                      ? Text(authProvider.user?.name[0] ?? 'U', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold))
                      : null,
                ),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(Icons.login, color: Theme.of(context).colorScheme.onSurface),
                onPressed: () => Navigator.pushNamed(context, AppRouter.login),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              final left = Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchPlaceholder,
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _searchController.clear();
                                final postProvider = Provider.of<PostProvider>(context, listen: false);
                                postProvider.searchPosts('');
                              },
                              icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: _showFilterSheet,
                              icon: Icon(Icons.tune, color: Theme.of(context).colorScheme.onPrimaryContainer),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: _openSaveSearchDialog,
                              icon: Icon(Icons.bookmark_add_outlined, color: Theme.of(context).colorScheme.onSecondaryContainer),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                      ),
                      onChanged: (value) {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                          final postProvider = Provider.of<PostProvider>(context, listen: false);
                          postProvider.searchPosts(value);
                        });
                      },
                      onSubmitted: (value) {
                        final postProvider = Provider.of<PostProvider>(context, listen: false);
                        postProvider.searchPosts(value);
                        _searchFocusNode.unfocus();
                      },
                    ),
                    if (_showHistory && postProvider.searchHistory.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                          BoxShadow(
                              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(AppLocalizations.of(context)!.searchHistory, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                                    GestureDetector(
                                      onTap: () => postProvider.clearSearchHistory(),
                                      child: Text(AppLocalizations.of(context)!.clearHistory, style: const TextStyle(color: Colors.red, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              ...postProvider.searchHistory.map((term) => ListTile(
                                leading: Icon(Icons.history, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                title: Text(term),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () => postProvider.removeFromSearchHistory(term),
                                ),
                                onTap: () {
                                  _searchController.text = term;
                                  postProvider.searchPosts(term);
                                  _searchFocusNode.unfocus();
                                },
                                dense: true,
                              )),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _categoryChip('Tất cả', AppLocalizations.of(context)!.all, Icons.category),
                          _categoryChip('Căn hộ', AppLocalizations.of(context)!.apartment, Icons.apartment),
                          _categoryChip('Nhà riêng', AppLocalizations.of(context)!.house, Icons.house),
                          _categoryChip('Phòng trọ', AppLocalizations.of(context)!.room, Icons.bedroom_parent),
                          _categoryChip('Văn phòng', AppLocalizations.of(context)!.office, Icons.business),
                          _categoryChip('Penthouse', AppLocalizations.of(context)!.penthouse, Icons.star),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(
                                Icons.access_time,
                                size: 18,
                                color: _sortMode == 'newest' ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              label: Text(AppLocalizations.of(context)!.newest),
                              selected: _sortMode == 'newest',
                              showCheckmark: false,
                              selectedColor: Theme.of(context).colorScheme.primary,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              side: BorderSide(
                                color: _sortMode == 'newest' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                              ),
                              labelStyle: TextStyle(
                                color: _sortMode == 'newest' ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                fontWeight: _sortMode == 'newest' ? FontWeight.w600 : FontWeight.w400,
                              ),
                              onSelected: (v) => setState(() => _sortMode = 'newest'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(
                                Icons.arrow_upward,
                                size: 18,
                                color: _sortMode == 'priceAsc' ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              label: Text(AppLocalizations.of(context)!.priceAsc),
                              selected: _sortMode == 'priceAsc',
                              showCheckmark: false,
                              selectedColor: Theme.of(context).colorScheme.primary,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              side: BorderSide(
                                color: _sortMode == 'priceAsc' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                              ),
                              labelStyle: TextStyle(
                                color: _sortMode == 'priceAsc' ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                fontWeight: _sortMode == 'priceAsc' ? FontWeight.w600 : FontWeight.w400,
                              ),
                              onSelected: (v) => setState(() => _sortMode = 'priceAsc'),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(
                                Icons.arrow_downward,
                                size: 18,
                                color: _sortMode == 'priceDesc' ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              label: Text(AppLocalizations.of(context)!.priceDesc),
                              selected: _sortMode == 'priceDesc',
                              showCheckmark: false,
                              selectedColor: Theme.of(context).colorScheme.primary,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              side: BorderSide(
                                color: _sortMode == 'priceDesc' ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                              ),
                              labelStyle: TextStyle(
                                color: _sortMode == 'priceDesc' ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                fontWeight: _sortMode == 'priceDesc' ? FontWeight.w600 : FontWeight.w400,
                              ),
                              onSelected: (v) => setState(() => _sortMode = 'priceDesc'),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final p = Provider.of<PostProvider>(context, listen: false);
                              setState(() {
                                _selectedCity = 'Tất cả';
                                _selectedType = 'Tất cả';
                                _selectedAmenities = [];
                                _sortMode = 'newest';
                              });
                              p.applyFilters();
                            },
                            child: Text(AppLocalizations.of(context)!.clearFilter),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: postProvider.getAllCities().length,
                        itemBuilder: (context, index) {
                          final city = postProvider.getAllCities()[index];
                          final isSelected = _selectedCity == city;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: Icon(Icons.location_city, size: 18, color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant),
                              label: Text(city),
                              showCheckmark: false,
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCity = city;
                                });
                                final p = Provider.of<PostProvider>(context, listen: false);
                                p.applyFilters(city: _selectedCity);
                                p.saveRecentFilter(city: _selectedCity, type: _selectedType);
                              },
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              selectedColor: Theme.of(context).colorScheme.primary,
                              checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                              side: BorderSide(
                                color: isSelected ? Colors.transparent : Theme.of(context).colorScheme.outlineVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelStyle: TextStyle(
                                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (authProvider.isLoggedIn && (authProvider.user?.role ?? 'user') != 'admin') ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                          child: Text(AppLocalizations.of(context)!.remainingPosts(authProvider.user?.postQuota ?? 0), style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                    if (postProvider.recentFilters.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: postProvider.recentFilters.length,
                          itemBuilder: (context, index) {
                            final f = postProvider.recentFilters[index];
                            final city = (f['city'] as String?) ?? 'Tất cả';
                            final type = (f['type'] as String?) ?? 'Tất cả';
                            final maxPrice = f['maxPrice'];
                            final parts = <String>[];
                            if (city.isNotEmpty && city != 'Tất cả') parts.add(city);
                            if (type.isNotEmpty && type != 'Tất cả') parts.add(type);
                            String label = parts.isEmpty ? AppLocalizations.of(context)!.filterLabel : parts.join(' · ');
                            if (maxPrice is num) {
                              label += ' · ≤ ${(maxPrice / 1000000).toStringAsFixed(0)}tr';
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InputChip(
                                label: Text(label),
                                onPressed: () {
                                  final p = Provider.of<PostProvider>(context, listen: false);
                                  setState(() {
                                    _selectedCity = city;
                                    _selectedType = type;
                                  });
                                  p.applyFilters(
                                    city: city,
                                    type: type,
                                    maxPrice: maxPrice is num ? maxPrice.toDouble() : null,
                                  );
                                },
                                onDeleted: () {
                                  final p = Provider.of<PostProvider>(context, listen: false);
                                  p.removeRecentFilterAt(index);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (postProvider.savedSearches.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: postProvider.savedSearches.length,
                          itemBuilder: (context, index) {
                            final s = postProvider.savedSearches[index];
                            final label = s['name'] as String? ?? 'Đã lưu';
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InputChip(
                                label: Text(label),
                                onPressed: () {
                                  final p = Provider.of<PostProvider>(context, listen: false);
                                  final q = (s['query'] as String?) ?? '';
                                  final city = (s['city'] as String?) ?? 'Tất cả';
                                  final type = (s['type'] as String?) ?? 'Tất cả';
                                  setState(() {
                                    _selectedCity = city;
                                    _selectedType = type;
                                    _searchController.text = q;
                                  });
                                  p.searchPosts(q);
                                  p.applyFilters(city: city, type: type);
                                },
                                onDeleted: () {
                                  final p = Provider.of<PostProvider>(context, listen: false);
                                  p.removeSavedSearchAt(index);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
              final right = authProvider.isLoggedIn
                  ? const SizedBox.shrink()
                  : Container(
                      width: isWide ? 320 : double.infinity,
                      margin: EdgeInsets.only(
                        right: isWide ? AppConstants.defaultPadding : AppConstants.defaultPadding,
                        left: isWide ? 0 : AppConstants.defaultPadding,
                      ),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.welcome,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.loginPrompt,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRouter.login);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(AppLocalizations.of(context)!.login),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRouter.register);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(AppLocalizations.of(context)!.registration),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    if (!authProvider.isLoggedIn) right,
                  ],
                );
              } else {
                return Column(
                  children: [
                    left,
                    if (!authProvider.isLoggedIn) right,
                  ],
                );
              }
            },
          ),
          // Posts List
          Expanded(
            child: postProvider.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: 6,
                    itemBuilder: (_, __) => const SkeletonPostCard(),
                  )
                : postProvider.posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.house_outlined,
                              size: 80,
                              color: Colors.grey[400],
  ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.noData,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.beTheFirstToPost,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Builder(builder: (context) {
                        final ranked = RecommendationService.rank(List.from(postProvider.posts), city: _selectedCity == 'Tất cả' ? null : _selectedCity);
                        if (_sortMode == 'priceAsc') {
                          ranked.sort((a, b) => a.price.compareTo(b.price));
                        } else if (_sortMode == 'priceDesc') {
                          ranked.sort((a, b) => b.price.compareTo(a.price));
                        } else {
                          ranked.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                        }
                        final forYou = authProvider.isLoggedIn ? postProvider.getPersonalizedPosts(limit: 10) : [];
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          children: [
                            if (forYou.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: const [
                                    Icon(Icons.recommend, color: Colors.purple),
                                    SizedBox(width: 8),
                                    Text('Dành cho bạn', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 235,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: forYou.length,
                                  itemBuilder: (context, i) {
                                    final post = forYou[i];
                                    return SizedBox(
                                      width: 245,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 12),
                                        child: PostCompactCard(
                                          height: 210,
                                          post: post,
                                          onTap: () {
                                            final p = Provider.of<PostProvider>(context, listen: false);
                                            p.incrementPostViews(post.id);
                                            Navigator.pushNamed(context, AppRouter.postDetail, arguments: post.id);
                                          },
                                          isFavorited: authProvider.isLoggedIn ? postProvider.isPostFavorited(post.id) : false,
                                          onToggleFavorite: authProvider.isLoggedIn
                                              ? () {
                                                  final p = Provider.of<PostProvider>(context, listen: false);
                                                  p.toggleFavorite(post.id);
                                                }
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            ...List.generate(ranked.length, (index) {
                              final post = ranked[index];
                              return PostCard(
                                post: post,
                                onTap: () {
                                  final p = Provider.of<PostProvider>(context, listen: false);
                                  p.incrementPostViews(post.id);
                                  Navigator.pushNamed(context, AppRouter.postDetail, arguments: post.id);
                                },
                                isFavorited: authProvider.isLoggedIn ? postProvider.isPostFavorited(post.id) : false,
                                onToggleFavorite: authProvider.isLoggedIn
                                    ? () {
                                        final p = Provider.of<PostProvider>(context, listen: false);
                                        p.toggleFavorite(post.id);
                                      }
                                    : null,
                              );
                            })
                          ],
                        );
                      }),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'chatbot',
            onPressed: () => Navigator.pushNamed(context, AppRouter.chatbot),
            backgroundColor: Colors.white,
            child: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          if (authProvider.isLoggedIn)
            FloatingActionButton(
              heroTag: 'createPost',
              onPressed: () {
                final postProvider = Provider.of<PostProvider>(context, listen: false);
                final userRole = authProvider.user?.role ?? 'user';
                final postCount = postProvider.myPosts.length;
                final quota = authProvider.user?.postQuota ?? 0;

                if (userRole != 'admin' && quota <= 0) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.outOfQuotaTitle),
                      content: Text(AppLocalizations.of(context)!.outOfQuotaMsg),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.close),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRouter.membership);
                          },
                          child: Text(AppLocalizations.of(context)!.upgradeNow),
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.pushNamed(context, AppRouter.createPost);
                }
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          if (!authProvider.isLoggedIn)
            FloatingActionButton(
              heroTag: 'createPostGuest',
              onPressed: () => Navigator.pushNamed(context, AppRouter.login),
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            ),
        ],
      ),
    );
  }

  Widget _categoryChip(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 18, color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant),
        label: Text(label),
        showCheckmark: false,
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedType = value;
            } else {
              _selectedType = 'Tất cả';
            }
          });
          final p = Provider.of<PostProvider>(context, listen: false);
          p.applyFilters(
            city: _selectedCity == 'Tất cả' ? null : _selectedCity,
            type: _selectedType == 'Tất cả' ? null : _selectedType,
          );
          p.saveRecentFilter(
            city: _selectedCity,
            type: _selectedType,
          );
        },
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        checkmarkColor: colorScheme.onPrimary,
        side: BorderSide(
          color: isSelected ? Colors.transparent : colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
