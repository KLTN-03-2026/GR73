import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/post.dart';
import '../services/firebase_service.dart';

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];
  List<Post> _myPosts = [];
  List<Post> _favoritePosts = [];
  bool _isLoading = false;
  String? _error;
  final Map<String, bool> _isFavorited = {};
  StreamSubscription<List<Post>>? _postsSub;
  StreamSubscription<List<Post>>? _citiesSub;
  String? _currentCity;
  double? _currentMinPrice;
  double? _currentMaxPrice;
  double? _currentMinArea;
  double? _currentMaxArea;
  int? _currentBedrooms;
  String? _currentType;
  List<String> _currentAmenities = [];
  String _currentQuery = '';
  List<String> _searchHistory = [];
  List<Map<String, dynamic>> _recentFilters = [];
  List<Map<String, dynamic>> _savedSearches = [];
  List<String> _allCities = [];

  List<Post> get posts => _posts;
  List<Post> get myPosts => _myPosts;
  List<Post> get favoritePosts => _favoritePosts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get searchHistory => _searchHistory;
  List<Map<String, dynamic>> get recentFilters => _recentFilters;
  List<Map<String, dynamic>> get savedSearches => _savedSearches;
  List<String> getAllCities() {
    final cities = _allCities.toSet().toList();
    cities.sort();
    if (!cities.contains('Tất cả')) cities.insert(0, 'Tất cả');
    return cities;
  }
  bool isPostFavorited(String postId) => _isFavorited[postId] ?? false;

  PostProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    _loadSearchHistory();
    await _loadRecentFilters();
    _subscribeCities();
    _subscribePosts();
    await _loadSavedSearches();
    if (user != null) {
      await _loadFavorites(user.uid);
      await fetchMyPosts(user.uid);
    }
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory = prefs.getStringList('search_history') ?? [];
    notifyListeners();
  }

  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    if (_searchHistory.contains(query)) {
      _searchHistory.remove(query);
    }
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
    notifyListeners();
  }

  Future<void> removeFromSearchHistory(String query) async {
    _searchHistory.remove(query);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
    notifyListeners();
  }

  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('search_history');
    notifyListeners();
  }

  Future<void> _loadRecentFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('recent_filters') ?? [];
    _recentFilters = raw.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((e) => e.isNotEmpty).toList();
    notifyListeners();
  }

  Future<void> saveRecentFilter({
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? type,
    List<String>? amenities,
  }) async {
    final isDefault = ((city == null || city.isEmpty || city == 'Tất cả') &&
        (type == null || type.isEmpty || type == 'Tất cả') &&
        minPrice == null &&
        maxPrice == null &&
        bedrooms == null &&
        (amenities == null || amenities.isEmpty));
    if (isDefault) {
      return; // Skip saving trivial default filter
    }
    final filter = <String, dynamic>{
      'city': city,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'bedrooms': bedrooms,
      'type': type,
      'amenities': amenities ?? [],
    };
    _recentFilters.removeWhere((f) => _isSameFilter(f, filter));
    _recentFilters.insert(0, filter);
    if (_recentFilters.length > 5) {
      _recentFilters = _recentFilters.sublist(0, 5);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_filters', _recentFilters.map((e) => jsonEncode(e)).toList());
    notifyListeners();
  }

  bool _isSameFilter(Map<String, dynamic> a, Map<String, dynamic> b) {
    return a['city'] == b['city'] &&
        a['minPrice'] == b['minPrice'] &&
        a['maxPrice'] == b['maxPrice'] &&
        a['bedrooms'] == b['bedrooms'] &&
        a['type'] == b['type'] &&
        _listEquals((a['amenities'] as List?)?.cast<String>() ?? const [], (b['amenities'] as List?)?.cast<String>() ?? const []);
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> removeRecentFilterAt(int index) async {
    if (index < 0 || index >= _recentFilters.length) return;
    _recentFilters.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_filters', _recentFilters.map((e) => jsonEncode(e)).toList());
    notifyListeners();
  }

  Future<void> clearRecentFilters() async {
    _recentFilters.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_filters');
    notifyListeners();
  }

  Future<void> _loadSavedSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('saved_searches') ?? [];
    _savedSearches = raw.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((e) => e.isNotEmpty).toList();
    notifyListeners();
  }

  Future<void> addSavedSearch({
    required String name,
    String? query,
    String? city,
    String? type,
    double? maxPrice,
    List<String>? amenities,
  }) async {
    final entry = <String, dynamic>{
      'name': name,
      'query': query ?? '',
      'city': city ?? 'Tất cả',
      'type': type ?? 'Tất cả',
      'maxPrice': maxPrice,
      'amenities': amenities ?? [],
    };
    // Dedup by name + params
    _savedSearches.removeWhere((e) => e['name'] == name);
    _savedSearches.insert(0, entry);
    if (_savedSearches.length > 10) {
      _savedSearches = _savedSearches.sublist(0, 10);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_searches', _savedSearches.map((e) => jsonEncode(e)).toList());
    notifyListeners();
  }

  Future<void> removeSavedSearchAt(int index) async {
    if (index < 0 || index >= _savedSearches.length) return;
    _savedSearches.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_searches', _savedSearches.map((e) => jsonEncode(e)).toList());
    notifyListeners();
  }

  Future<void> clearSavedSearches() async {
    _savedSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_searches');
    notifyListeners();
  }

  // ============ POSTS MANAGEMENT ============

  Future<void> fetchPosts({
    String? city,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    String? type,
    String? searchQuery,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (searchQuery != null && searchQuery.isNotEmpty) {
        await addToSearchHistory(searchQuery);
        _posts = await FirebaseService.searchPosts(searchQuery);
        await _loadFavoriteStatus();
      } else {
        _currentCity = city;
        _currentMinPrice = minPrice;
        _currentMaxPrice = maxPrice;
        _currentMinArea = minArea;
        _currentMaxArea = maxArea;
        _currentBedrooms = bedrooms;
        _currentType = type;
        _currentAmenities = [];
        _subscribePosts();
      }
      
    } catch (e) {
      _error = 'Lỗi tải danh sách tin đăng: ${e.toString()}';
      debugPrint('Fetch posts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribePosts() {
    _postsSub?.cancel();
    final stream = FirebaseService.getPostsStream(
      city: _currentCity,
      minPrice: _currentMinPrice,
      maxPrice: _currentMaxPrice,
      bedrooms: _currentBedrooms,
      type: _currentType,
      amenities: _currentAmenities,
    );
    _postsSub = stream.listen((items) async {
      // Apply area filter locally since it might not be in the stream query
      var filtered = items;
      if (_currentMinArea != null) {
        filtered = filtered.where((p) => p.area >= _currentMinArea!).toList();
      }
      if (_currentMaxArea != null) {
        filtered = filtered.where((p) => p.area <= _currentMaxArea!).toList();
      }
      
      _posts = filtered;
      await _loadFavoriteStatus();
      notifyListeners();
    }, onError: (e) {
      _error = 'Lỗi stream tin đăng: $e';
      notifyListeners();
    });
  }

  void _subscribeCities() {
    _citiesSub?.cancel();
    final stream = FirebaseService.getAllPostsStream();
    _citiesSub = stream.listen((items) async {
      _allCities = items.map((p) => p.city).toSet().toList();
      notifyListeners();
    }, onError: (e) {
      // ignore: avoid_print
      debugPrint('Cities stream error: $e');
    });
  }

  void applyFilters({
    String? city,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    String? type,
    List<String>? amenities,
  }) {
    _currentCity = city;
    _currentMinPrice = minPrice;
    _currentMaxPrice = maxPrice;
    _currentMinArea = minArea;
    _currentMaxArea = maxArea;
    _currentBedrooms = bedrooms;
    _currentType = type;
    if (amenities != null) {
      _currentAmenities = amenities;
    }
    _refreshPosts();
  }

  void _refreshPosts() {
    if (_currentQuery.isNotEmpty) {
      _postsSub?.cancel();
      _performSearch();
    } else {
      _subscribePosts();
    }
  }

  Future<void> _performSearch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var results = await FirebaseService.searchPosts(_currentQuery);
      
      // Apply local filters
      results = results.where((post) {
        if (_currentCity != null && _currentCity!.isNotEmpty && _currentCity != 'Tất cả' && post.city != _currentCity) {
          return false;
        }
        if (_currentType != null && _currentType!.isNotEmpty && _currentType != 'Tất cả' && post.type != _currentType) {
          return false;
        }
        if (_currentMinPrice != null && post.price < _currentMinPrice!) {
          return false;
        }
        if (_currentMaxPrice != null && post.price > _currentMaxPrice!) {
          return false;
        }
        if (_currentBedrooms != null && post.bedrooms != _currentBedrooms) {
          return false;
        }
        if (_currentAmenities.isNotEmpty) {
          for (final amenity in _currentAmenities) {
            if (!post.amenities.contains(amenity)) {
              return false;
            }
          }
        }
        return true;
      }).toList();

      _posts = results;
      await _loadFavoriteStatus();
    } catch (e) {
      _error = 'Lỗi tìm kiếm: ${e.toString()}';
      debugPrint('Search posts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyPosts(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myPosts = await FirebaseService.getUserPosts(userId);
    } catch (e) {
      _error = 'Lỗi tải tin đăng của tôi: ${e.toString()}';
      debugPrint('Fetch my posts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(Post post) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final existingOwner = await FirebaseService.getUser(post.owner.id);
      if (existingOwner == null) {
        await FirebaseService.upsertUser(post.owner);
      }
      final postId = await FirebaseService.createPost(post);
      final created = Post(
        id: postId,
        title: post.title,
        description: post.description,
        price: post.price,
        address: post.address,
        city: post.city,
        type: post.type,
        area: post.area,
        bedrooms: post.bedrooms,
        bathrooms: post.bathrooms,
        images: post.images,
        owner: post.owner,
        isAvailable: post.isAvailable,
        isApproved: post.isApproved,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        amenities: post.amenities,
        contactPhone: post.contactPhone,
        contactEmail: post.contactEmail,
        views: post.views,
        isFeatured: post.isFeatured,
      );
      _myPosts.insert(0, created);
      // Hiển thị ngay trên UI trước khi stream phản hồi
      final existsInList = _posts.any((p) => p.id == created.id);
      if (!existsInList) {
        _posts.insert(0, created);
      }
      notifyListeners();
      try {
        if ((existingOwner?.role ?? 'user') != 'admin') {
          await FirebaseService.decrementPostQuota(userId: post.owner.id, amount: 1);
        }
      } catch (_) {}
    } catch (e) {
      _error = 'Lỗi đăng tin: ${e.toString()}';
      debugPrint('Create post error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePost(String postId, Post updatedPost) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.updatePost(postId, updatedPost.toFirestore());
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex] = updatedPost;
      }

      final myPostIndex = _myPosts.indexWhere((p) => p.id == postId);
      if (myPostIndex != -1) {
        _myPosts[myPostIndex] = updatedPost;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi cập nhật tin: ${e.toString()}';
      debugPrint('Update post error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.deletePost(postId);
      _posts.removeWhere((p) => p.id == postId);
      _myPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi xóa tin: ${e.toString()}';
      debugPrint('Delete post error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> togglePostAvailability(String postId, bool isAvailable) async {
    try {
      await FirebaseService.updatePost(postId, {'isAvailable': isAvailable});
      for (var i = 0; i < _posts.length; i++) {
        if (_posts[i].id == postId) {
          _posts[i] = Post(
            id: _posts[i].id,
            title: _posts[i].title,
            description: _posts[i].description,
            price: _posts[i].price,
            address: _posts[i].address,
            city: _posts[i].city,
            type: _posts[i].type,
            area: _posts[i].area,
            bedrooms: _posts[i].bedrooms,
            bathrooms: _posts[i].bathrooms,
            images: _posts[i].images,
            owner: _posts[i].owner,
            isAvailable: isAvailable,
            createdAt: _posts[i].createdAt,
            updatedAt: DateTime.now(),
            amenities: _posts[i].amenities,
            contactPhone: _posts[i].contactPhone,
            contactEmail: _posts[i].contactEmail,
            views: _posts[i].views,
            isFeatured: _posts[i].isFeatured,
          );
        }
      }

      for (var i = 0; i < _myPosts.length; i++) {
        if (_myPosts[i].id == postId) {
          _myPosts[i] = Post(
            id: _myPosts[i].id,
            title: _myPosts[i].title,
            description: _myPosts[i].description,
            price: _myPosts[i].price,
            address: _myPosts[i].address,
            city: _myPosts[i].city,
            type: _myPosts[i].type,
            area: _myPosts[i].area,
            bedrooms: _myPosts[i].bedrooms,
            bathrooms: _myPosts[i].bathrooms,
            images: _myPosts[i].images,
            owner: _myPosts[i].owner,
            isAvailable: isAvailable,
            createdAt: _myPosts[i].createdAt,
            updatedAt: DateTime.now(),
            amenities: _myPosts[i].amenities,
            contactPhone: _myPosts[i].contactPhone,
            contactEmail: _myPosts[i].contactEmail,
            views: _myPosts[i].views,
            isFeatured: _myPosts[i].isFeatured,
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Toggle availability error: $e');
    }
  }

  Future<Post?> getPostById(String postId) async {
    final idx = _posts.indexWhere((post) => post.id == postId);
    if (idx == -1) {
      debugPrint('Get post by id error: Not found for id $postId');
      return null;
    }
    return _posts[idx];
  }

  void incrementPostViews(String postId) async {
    try {
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx == -1) return;
      final post = _posts[idx];
      await FirebaseService.updatePost(postId, {'views': post.views + 1});
      _posts[idx] = Post(
          id: post.id,
          title: post.title,
          description: post.description,
          price: post.price,
          address: post.address,
          city: post.city,
          type: post.type,
          lat: post.lat,
          lng: post.lng,
          area: post.area,
          bedrooms: post.bedrooms,
          bathrooms: post.bathrooms,
          images: post.images,
          owner: post.owner,
          isAvailable: post.isAvailable,
          createdAt: post.createdAt,
          updatedAt: DateTime.now(),
          amenities: post.amenities,
          contactPhone: post.contactPhone,
          contactEmail: post.contactEmail,
          views: post.views + 1,
          isFeatured: post.isFeatured,
          isApproved: true,
        );
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseService.logRecommendEvent(
          userId: user.uid,
          postId: postId,
          event: 'view',
          context: {'city': post.city, 'price': post.price, 'area': post.area},
        );
      }
    } catch (e) {
      debugPrint('Increment views error: $e');
    }
  }

  // ============ FAVORITES MANAGEMENT ============

  Future<void> _loadFavorites(String userId) async {
    try {
      final favIds = await FirebaseService.getUserFavorites(userId);
      _isFavorited.clear();
      for (final id in favIds) {
        _isFavorited[id] = true;
      }
      _favoritePosts = _posts.where((p) => _isFavorited[p.id] == true).toList();
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final favIds = await FirebaseService.getUserFavorites(user.uid);
        _isFavorited.clear();
        for (final id in favIds) {
          _isFavorited[id] = true;
        }
        _favoritePosts = _posts.where((p) => _isFavorited[p.id] == true).toList();
      }
    } catch (e) {
      debugPrint('Load favorite status error: $e');
    }
  }

  Future<void> toggleFavorite(String postId) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Vui lòng đăng nhập để thêm vào yêu thích');
      }

      final isCurrentlyFavorited = _isFavorited[postId] ?? false;

      if (isCurrentlyFavorited) {
        await FirebaseService.removeFromFavorites(userId: user.uid, postId: postId);
        _isFavorited[postId] = false;
        _favoritePosts.removeWhere((post) => post.id == postId);
        await FirebaseService.logRecommendEvent(userId: user.uid, postId: postId, event: 'favorite_remove');
      } else {
        await FirebaseService.addToFavorites(userId: user.uid, postId: postId);
        _isFavorited[postId] = true;
        final post = _posts.firstWhere((p) => p.id == postId);
        _favoritePosts.add(post);
        await FirebaseService.logRecommendEvent(userId: user.uid, postId: postId, event: 'favorite_add');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      rethrow;
    }
  }

  // ============ SEARCH ============

  Future<void> searchPosts(String query) async {
    _currentQuery = query;
    _refreshPosts();
  }

  // ============ FILTERS ============

  List<Post> filterPosts({
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    List<String>? amenities,
  }) {
    return _posts.where((post) {
      if (city != null && city.isNotEmpty && city != 'Tất cả' && post.city != city) {
        return false;
      }
      
      if (minPrice != null && post.price < minPrice) {
        return false;
      }
      
      if (maxPrice != null && post.price > maxPrice) {
        return false;
      }
      
      if (bedrooms != null && post.bedrooms != bedrooms) {
        return false;
      }
      
      if (amenities != null && amenities.isNotEmpty) {
        for (final amenity in amenities) {
          if (!post.amenities.contains(amenity)) {
            return false;
          }
        }
      }
      
      return true;
    }).toList();
  }

  // ============ UTILITIES ============

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _postsSub?.cancel();
    _citiesSub?.cancel();
    super.dispose();
  }

  void addMockPost(Post post) {
    _posts.insert(0, post);
    _myPosts.insert(0, post);
    notifyListeners();
  }

  void clearAllPosts() {
    _posts.clear();
    _myPosts.clear();
    _favoritePosts.clear();
    _isFavorited.clear();
    notifyListeners();
  }

  List<String> getAvailableCities() {
    final cities = _posts.map((post) => post.city).toSet().toList();
    cities.insert(0, 'Tất cả');
    return cities;
  }

  (double, double) getPriceRange() {
    if (_posts.isEmpty) return (0, 10000000);
    
    final prices = _posts.map((post) => post.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    
    return (minPrice, maxPrice);
  }

  (double, double) getAreaRange() {
    if (_posts.isEmpty) return (0, 500);
    
    final areas = _posts.map((post) => post.area).toList();
    final minArea = areas.reduce((a, b) => a < b ? a : b);
    final maxArea = areas.reduce((a, b) => a > b ? a : b);
    
    return (minArea, maxArea);
  }

  List<String> getAvailableAmenities() {
    final allAmenities = _posts.expand((post) => post.amenities).toSet().toList();
    allAmenities.sort();
    return allAmenities;
  }

  // ============ PERSONALIZATION ============

  (String?, String?) _preferredCityType() {
    final countsCity = <String, int>{};
    final countsType = <String, int>{};
    for (final p in _favoritePosts) {
      countsCity[p.city] = (countsCity[p.city] ?? 0) + 1;
      countsType[p.type] = (countsType[p.type] ?? 0) + 1;
    }
    String? bestCity;
    String? bestType;
    int maxCity = 0;
    int maxType = 0;
    countsCity.forEach((c, n) {
      if (n > maxCity) {
        maxCity = n;
        bestCity = c;
      }
    });
    countsType.forEach((t, n) {
      if (n > maxType) {
        maxType = n;
        bestType = t;
      }
    });
    return (bestCity, bestType);
  }

  List<Post> getPersonalizedPosts({int limit = 10}) {
    var items = List<Post>.from(_posts);
    final prefs = _preferredCityType();
    final city = prefs.$1;
    // Simple prioritization: preferred city first
    if (city != null && city.isNotEmpty) {
      items.sort((a, b) {
        final ac = a.city == city ? 1 : 0;
        final bc = b.city == city ? 1 : 0;
        if (ac != bc) return bc.compareTo(ac);
        return b.createdAt.compareTo(a.createdAt);
      });
    } else {
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    if (items.length > limit) items = items.sublist(0, limit);
    return items;
  }

  void sortPosts(String sortBy) {
    switch (sortBy) {
      case 'price_asc':
        _posts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        _posts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'date_desc':
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'date_asc':
        _posts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'area_desc':
        _posts.sort((a, b) => b.area.compareTo(a.area));
        break;
    }
    notifyListeners();
  }
}
