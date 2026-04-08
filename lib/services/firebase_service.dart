import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/user.dart' as app_user;
import '../models/post.dart';
import '../models/review.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseService {
  static final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static bool _fbLoginInProgress = false;
  
  // ============ AUTHENTICATION ============
  
  static Future<firebase_auth.User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'userId': firebaseUser.uid,
          'email': email,
          'name': name,
          'phone': phone,
          'avatarUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
          'isVerified': false,
          'postQuota': 0,
        });
      }
      
      return firebaseUser;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }
  
  static Future<firebase_auth.User?> signInWithFacebook() async {
    if (_fbLoginInProgress) return null;
    _fbLoginInProgress = true;
    try {
      if (kIsWeb) {
        final provider = firebase_auth.FacebookAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        return userCredential.user;
      }
      await FacebookAuth.instance.logOut();
      // Use default behavior (nativeWithFallback) to avoid webOnly white screen issues on some simulators
      var result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      if (result.status == LoginStatus.cancelled) return null;
      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw Exception('Facebook login failed: ${result.message ?? 'unknown error'}');
      }
      final credential = firebase_auth.FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('Facebook sign in error: $e');
      rethrow;
    } finally {
      _fbLoginInProgress = false;
    }
  }
  
  static Future<firebase_auth.User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  static Future<firebase_auth.User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(provider);
        return userCredential.user;
      }
      await GoogleSignIn.instance.initialize();
      final googleUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email']);
      final googleAuth = googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      rethrow;
    }
  }
  
  
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  static firebase_auth.User? get currentUser => _auth.currentUser;
  
  static Stream<firebase_auth.User?> authStateChanges() => _auth.authStateChanges();

  static Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  // ============ USER MANAGEMENT ============
  
  static Future<app_user.User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        try {
          return app_user.User.fromFirestore(doc);
        } catch (e) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          int parseInt(dynamic v, [int def = 0]) {
            if (v == null) return def;
            if (v is int) return v;
            if (v is num) return v.toInt();
            return int.tryParse(v.toString()) ?? def;
          }
          return app_user.User(
            id: doc.id,
            name: (data['name'] ?? 'Người dùng').toString(),
            email: (data['email'] ?? '').toString(),
            avatarUrl: (data['avatarUrl'] ?? '') as String?,
            phone: (data['phone'] ?? '') as String?,
            createdAt: DateTime.now(),
            role: (data['role'] ?? 'user').toString(),
            isVerified: (data['isVerified'] ?? false) == true,
            isDisabled: (data['isDisabled'] ?? false) == true,
            membershipId: (data['membershipId'] ?? '') as String?,
            membershipExpireAt: DateTime.now(),
            postQuota: parseInt(data['postQuota']),
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get user error: $e');
      rethrow;
    }
  }
  
  static Future<void> updateUserProfile({
    required String userId,
    required String name,
    required String phone,
    String? avatarUrl,
  }) async {
    try {
      final updateData = {
        'name': name,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }
      
      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      debugPrint('Update user error: $e');
      rethrow;
    }
  }

  static Future<void> setUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Set user role error: $e');
      rethrow;
    }
  }

  static Future<void> setUserDisabled({
    required String userId,
    required bool disabled,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'isDisabled': disabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Set user disabled error: $e');
      rethrow;
    }
  }

  static Future<void> updateMembershipBenefits({
    required String userId,
    required String membershipId,
    required int durationDays,
    required int quotaAdd,
  }) async {
    try {
      final expire = DateTime.now().add(Duration(days: durationDays));
      await _firestore.collection('users').doc(userId).set({
        'membershipId': membershipId,
        'membershipExpireAt': expire.toIso8601String(),
        'postQuota': FieldValue.increment(quotaAdd),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Update membership error: $e');
      rethrow;
    }
  }

  static Future<void> cancelMembership(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'membershipId': null,
        'membershipExpireAt': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Cancel membership error: $e');
      rethrow;
    }
  }

  static Future<void> decrementPostQuota({
    required String userId,
    int amount = 1,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'postQuota': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Decrement post quota error: $e');
      rethrow;
    }
  }

  static Future<void> upsertUser(app_user.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'userId': user.id,
        'email': user.email,
        'name': user.name,
        'phone': user.phone ?? '',
        'avatarUrl': user.avatarUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'role': user.role ?? 'user',
        'isVerified': user.isVerified,
        'isDisabled': user.isDisabled,
        'postQuota': user.postQuota,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Upsert user error: $e');
      rethrow;
    }
  }
  
  // ============ POST MANAGEMENT ============
  
  static Future<String> createPost(Post post) async {
    try {
      final postRef = _firestore.collection('posts').doc();
      final postId = postRef.id;
      
      await postRef.set(post.toFirestore());
      return postId;
    } catch (e) {
      debugPrint('Create post error: $e');
      rethrow;
    }
  }
  
  static Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('posts').doc(postId).update(updates);
    } catch (e) {
      debugPrint('Update post error: $e');
      rethrow;
    }
  }
  
  static Future<void> deletePost(String postId) async {
    try {
      // 1. Delete post
      await _firestore.collection('posts').doc(postId).delete();
      
      // 2. Delete related reviews
      final reviewsSnapshot = await _firestore.collection('reviews').where('postId', isEqualTo: postId).get();
      for (final doc in reviewsSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // 3. Delete related favorites
      final favoritesSnapshot = await _firestore.collection('favorites').where('postId', isEqualTo: postId).get();
      for (final doc in favoritesSnapshot.docs) {
        await doc.reference.delete();
      }

      // 4. Delete related recommend_events (statistics)
      final eventsSnapshot = await _firestore.collection('recommend_events').where('postId', isEqualTo: postId).get();
      for (final doc in eventsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Delete post error: $e');
      rethrow;
    }
  }
  
  static Stream<List<app_user.User>> getUsersStream() {
    try {
      return _firestore.collection('users').snapshots().map((snapshot) {
        final users = <app_user.User>[];
        for (final doc in snapshot.docs) {
          try {
            users.add(app_user.User.fromFirestore(doc));
          } catch (_) {
            final data = doc.data();
            int parseInt(dynamic v, [int def = 0]) {
              if (v == null) return def;
              if (v is int) return v;
              if (v is num) return v.toInt();
              return int.tryParse(v.toString()) ?? def;
            }
            users.add(app_user.User(
              id: doc.id,
              name: (data['name'] ?? 'Người dùng').toString(),
              email: (data['email'] ?? '').toString(),
              avatarUrl: (data['avatarUrl'] ?? '') as String?,
              phone: (data['phone'] ?? '') as String?,
              createdAt: DateTime.now(),
              role: (data['role'] ?? 'user').toString(),
              isVerified: (data['isVerified'] ?? false) == true,
              isDisabled: (data['isDisabled'] ?? false) == true,
              membershipId: (data['membershipId'] ?? '') as String?,
              membershipExpireAt: DateTime.now(),
              postQuota: parseInt(data['postQuota']),
            ));
          }
        }
        return users;
      });
    } catch (e) {
      debugPrint('Get users stream error: $e');
      rethrow;
    }
  }
  
  static Stream<List<Post>> getPostsStream({
    String? city,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? type,
    List<String>? amenities,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('posts')
        .where('isAvailable', isEqualTo: true)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true);
      
      // Client-side filtering to avoid composite index issues
      return query.snapshots().asyncMap((snapshot) async {
        final posts = <Post>[];
        for (final doc in snapshot.docs) {
          final postData = doc.data();
          
          // Filter by City
          if (city != null && city.isNotEmpty && city != 'Tất cả') {
            if (postData['city'] != city) continue;
          }
          
          // Filter by Type
          if (type != null && type.isNotEmpty) {
             final pType = postData['type'] as String? ?? '';
             if (pType != type) continue;
          }
          
          // Filter by Bedrooms
          if (bedrooms != null) {
             int pBed = 0;
             final rawBed = postData['bedrooms'];
             if (rawBed is int) {
               pBed = rawBed;
             } else if (rawBed is num) {
               pBed = rawBed.toInt();
             } else if (rawBed != null) {
               pBed = int.tryParse(rawBed.toString()) ?? 0;
             }
             if (pBed != bedrooms) continue;
          }
          
          // Filter by Price
          final pPrice = (postData['price'] as num?)?.toDouble() ?? 0.0;
          if (minPrice != null && pPrice < minPrice) continue;
          if (maxPrice != null && pPrice > maxPrice) continue;

          // Filter by Amenities
          if (amenities != null && amenities.isNotEmpty) {
            final pAmenities = List<String>.from(postData['amenities'] ?? []);
            // Check if post has ALL selected amenities (AND logic)
            bool hasAll = true;
            for (final amenity in amenities) {
              if (!pAmenities.contains(amenity)) {
                hasAll = false;
                break;
              }
            }
            if (!hasAll) continue;
          }

          final owner = await getUser(postData['ownerId']);
          if (owner != null) {
            posts.add(Post.fromFirestore(doc, owner));
          }
        }
        return posts;
      });
    } catch (e) {
      debugPrint('Get posts stream error: $e');
      rethrow;
    }
  }

  static Stream<List<Post>> getAllPostsStream() {
    try {
      final Query<Map<String, dynamic>> query = _firestore.collection('posts').orderBy('createdAt', descending: true);
      return query.snapshots().asyncMap((snapshot) async {
        final posts = <Post>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final owner = await getUser(data['ownerId']);
          if (owner != null) {
            posts.add(Post.fromFirestore(doc, owner));
          }
        }
        return posts;
      });
    } catch (e) {
      debugPrint('Get all posts stream error: $e');
      rethrow;
    }
  }

  static Future<void> setPostApproved({
    required String postId,
    required bool approved,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).set({
        'isApproved': approved,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Set post approved error: $e');
      rethrow;
    }
  }

  static Future<void> setPostAvailability({
    required String postId,
    required bool available,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).set({
        'isAvailable': available,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Set post availability error: $e');
      rethrow;
    }
  }

  static Future<Map<String, int>> getCounts() async {
    try {
      final users = await _firestore.collection('users').get();
      final posts = await _firestore.collection('posts').get();
      final reviews = await _firestore.collection('reviews').get();
      return {
        'users': users.docs.length,
        'posts': posts.docs.length,
        'reviews': reviews.docs.length,
      };
    } catch (e) {
      debugPrint('Get counts error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getRecommendEventStats({int days = 30}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));
      final query = await _firestore
          .collection('recommend_events')
          .where('createdAt', isGreaterThanOrEqualTo: since)
          .get();
      int views = 0;
      int favAdd = 0;
      int favRemove = 0;
      final cityCounts = <String, int>{};
      final postViewCounts = <String, int>{};
      for (final doc in query.docs) {
        final data = doc.data();
        final event = (data['event'] as String?) ?? '';
        final context = (data['context'] as Map<String, dynamic>?) ?? {};
        final city = (context['city'] as String?) ?? '';
        final postId = (data['postId'] as String?) ?? '';
        if (event == 'view') {
          views++;
          if (postId.isNotEmpty) {
            postViewCounts[postId] = (postViewCounts[postId] ?? 0) + 1;
          }
          if (city.isNotEmpty) {
            cityCounts[city] = (cityCounts[city] ?? 0) + 1;
          }
        } else if (event == 'favorite_add') {
          favAdd++;
        } else if (event == 'favorite_remove') {
          favRemove++;
        }
      }
      List<MapEntry<String, int>> topPosts = postViewCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topPosts = topPosts.take(5).toList();
      List<MapEntry<String, int>> topCities = cityCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCities = topCities.take(5).toList();
      return {
        'views': views,
        'favorite_add': favAdd,
        'favorite_remove': favRemove,
        'top_posts': topPosts.map((e) => {'postId': e.key, 'count': e.value}).toList(),
        'top_cities': topCities.map((e) => {'city': e.key, 'count': e.value}).toList(),
        'days': days,
        'total_events': query.docs.length,
      };
    } catch (e) {
      debugPrint('Get recommend stats error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getRevenueStats({int days = 30}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore.collection('payments').get();
      double total30 = 0;
      double total7 = 0;
      double today = 0;
      int successCount = 0;
      int failedCount = 0;
      int submittedCount = 0;
      final daily = <String, double>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] ?? 'pending').toString();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final createdAtStr = (data['createdAt'] ?? '') as String? ?? '';
        final createdAt = DateTime.tryParse(createdAtStr) ?? DateTime.now();
        if (status == 'success') {
          successCount++;
          if (createdAt.isAfter(since)) {
            total30 += amount;
            final dayKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
            daily[dayKey] = (daily[dayKey] ?? 0) + amount;
          }
          final since7 = DateTime.now().subtract(const Duration(days: 7));
          if (createdAt.isAfter(since7)) total7 += amount;
          final now = DateTime.now();
          if (createdAt.year == now.year && createdAt.month == now.month && createdAt.day == now.day) {
            today += amount;
          }
        } else if (status == 'failed') {
          failedCount++;
        } else if (status == 'submitted') {
          submittedCount++;
        }
      }
      final series = daily.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return {
        'today': today,
        'last7Days': total7,
        'last30Days': total30,
        'successCount': successCount,
        'failedCount': failedCount,
        'submittedCount': submittedCount,
        'series': series.map((e) => {'date': e.key, 'amount': e.value}).toList(),
      };
    } catch (e) {
      debugPrint('Get revenue stats error: $e');
      rethrow;
    }
  }

  // ============ CONTENT REPORTS ============
  static Future<void> createPostReport({
    required String postId,
    required String reporterUserId,
    required String reason,
    String? details,
  }) async {
    try {
      await _firestore.collection('reports').add({
        'postId': postId,
        'reporterUserId': reporterUserId,
        'reason': reason,
        'details': details ?? '',
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Create report error: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllReportsStream() {
    try {
      return _firestore.collection('reports').orderBy('createdAt', descending: true).snapshots();
    } catch (e) {
      debugPrint('Get reports stream error: $e');
      rethrow;
    }
  }

  static Future<void> updateReportStatus({
    required String reportId,
    required String status, // open, resolved, rejected
  }) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Update report status error: $e');
      rethrow;
    }
  }

  static Stream<List<Review>> getReviewsStream(String postId) {
    try {
      final query = _firestore
          .collection('reviews')
          .where('postId', isEqualTo: postId)
          .orderBy('createdAt', descending: true);
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Review.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      debugPrint('Get reviews stream error: $e');
      rethrow;
    }
  }

  static Stream<List<Review>> getAllReviewsStream() {
    try {
      final query = _firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true);
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Review.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      debugPrint('Get all reviews stream error: $e');
      rethrow;
    }
  }

  static Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      debugPrint('Delete review error: $e');
      rethrow;
    }
  }

  static Stream<List<Review>> getReviewsStreamLite(String postId) {
    try {
      final query = _firestore
          .collection('reviews')
          .where('postId', isEqualTo: postId);
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Review.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      debugPrint('Get reviews lite stream error: $e');
      rethrow;
    }
  }

  static Future<void> createReview({
    required String postId,
    required int rating,
    required String comment,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Vui lòng đăng nhập để đánh giá');
      }
      final profile = await getUser(user.uid);
      final review = Review(
        id: '',
        postId: postId,
        userId: user.uid,
        userName: profile?.name ?? (profile?.email ?? user.email ?? 'Người dùng'),
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('reviews').add(review.toFirestore());
    } catch (e) {
      debugPrint('Create review error: $e');
      rethrow;
    }
  }
  
  static Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      if (doc.exists) {
        final postData = doc.data()!;
        final owner = await getUser(postData['ownerId']);
        if (owner != null) {
          return Post.fromFirestore(doc, owner);
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Get post error: $e');
      rethrow;
    }
  }
  
  static Future<List<Post>> getUserPosts(String userId) async {
    try {
      Query base = _firestore.collection('posts').where('ownerId', isEqualTo: userId);
      try {
        final query = await base.orderBy('createdAt', descending: true).get();
        final posts = <Post>[];
        for (final doc in query.docs) {
          final Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
          final String? ownerId = postData['ownerId'] as String?;
          if (ownerId == null || ownerId.isEmpty) continue;
          final owner = await getUser(ownerId);
          if (owner != null) {
            posts.add(Post.fromFirestore(doc, owner));
          }
        }
        return posts;
      } on FirebaseException catch (e) {
        if (e.code == 'failed-precondition') {
          final query = await base.get();
          final posts = <Post>[];
          for (final doc in query.docs) {
            final Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
            final String? ownerId = postData['ownerId'] as String?;
            if (ownerId == null || ownerId.isEmpty) continue;
            final owner = await getUser(ownerId);
            if (owner != null) {
              posts.add(Post.fromFirestore(doc, owner));
            }
          }
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return posts;
        }
        rethrow;
      }
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Get user posts error: $e');
      rethrow;
    }
  }
  
  // ============ FAVORITES ============
  
  static Future<void> addToFavorites({
    required String userId,
    required String postId,
  }) async {
    try {
      final favoriteId = '${userId}_$postId';
      await _firestore.collection('favorites').doc(favoriteId).set({
        'favoriteId': favoriteId,
        'userId': userId,
        'postId': postId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Add to favorites error: $e');
      rethrow;
    }
  }
  
  static Future<void> removeFromFavorites({
    required String userId,
    required String postId,
  }) async {
    try {
      final favoriteId = '${userId}_$postId';
      await _firestore.collection('favorites').doc(favoriteId).delete();
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Remove from favorites error: $e');
      rethrow;
    }
  }
  
  static Future<List<String>> getUserFavorites(String userId) async {
    try {
      final query = await _firestore.collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();
      
      return query.docs
          .map((doc) => (doc.data()['postId'] as String?) ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Get user favorites error: $e');
      rethrow;
    }
  }
  
  static Future<bool> isPostFavorited({
    required String userId,
    required String postId,
  }) async {
    try {
      final favoriteId = '${userId}_$postId';
      final doc = await _firestore.collection('favorites').doc(favoriteId).get();
      return doc.exists;
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Check favorite error: $e');
      return false;
    }
  }

  // ============ RECOMMENDER EVENTS ==========
  static Future<void> logRecommendEvent({
    required String userId,
    required String postId,
    required String event,
    Map<String, dynamic>? context,
  }) async {
    try {
      await _firestore.collection('recommend_events').add({
        'userId': userId,
        'postId': postId,
        'event': event,
        'context': context ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Log recommend event error: $e');
    }
  }
  
  // ============ SEARCH ============
  
  static Future<List<Post>> searchPosts(String query) async {
    try {
      final postsQuery = await _firestore.collection('posts')
        .where('isAvailable', isEqualTo: true)
        .where('isApproved', isEqualTo: true)
        .get();
      
      final filteredPosts = <Post>[];
      for (final doc in postsQuery.docs) {
        final data = doc.data();
        final title = (data['title'] as String).toLowerCase();
        final address = (data['address'] as String).toLowerCase();
        final city = (data['city'] as String).toLowerCase();
        final searchLower = query.toLowerCase();
        
        if (title.contains(searchLower) || 
            address.contains(searchLower) || 
            city.contains(searchLower)) {
          final owner = await getUser(data['ownerId']);
          if (owner != null) {
            filteredPosts.add(Post.fromFirestore(doc, owner));
          }
        }
      }
      
      return filteredPosts;
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Search posts error: $e');
      rethrow;
    }
  }
  
  // ============ STORAGE (for future use) ============
  
  static Future<List<String>> uploadPostImages(
    List<File> imageFiles,
    String postId,
  ) async {
    try {
      final uploadedUrls = <String>[];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final storageRef = _storage.ref().child('posts/$postId/$fileName');
        
        final uploadTask = await storageRef.putFile(imageFile);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        uploadedUrls.add(downloadUrl);
      }
      
      return uploadedUrls;
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Upload images error: $e');
      rethrow;
    }
  }
  
  static Future<String> uploadProfileImage(
    File imageFile,
    String userId,
  ) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('profiles/$userId/$fileName');
      
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      // ignore: avoid_print
      debugPrint('Upload profile image error: $e');
      rethrow;
    }
  }
}
