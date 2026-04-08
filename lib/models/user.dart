import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final DateTime createdAt;
  final String? role;
  final bool isVerified;
  final bool isDisabled;
  final String? membershipId;
  final DateTime? membershipExpireAt;
  final int postQuota;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.phone,
    DateTime? createdAt,
    this.role,
    this.isVerified = false,
    this.isDisabled = false,
    this.membershipId,
    this.membershipExpireAt,
    this.postQuota = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return User(
      id: (json['id'] ?? json['uid'] ?? json['userId'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      avatarUrl: (json['avatarUrl'] ?? json['avatar_url']) as String?,
      phone: json['phone'] as String?,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      role: json['role'] as String?,
      isVerified: (json['isVerified'] ?? json['is_verified'] ?? false) as bool,
      isDisabled: (json['isDisabled'] ?? json['disabled'] ?? false) as bool,
      membershipId: json['membershipId'] as String?,
      membershipExpireAt: parseDate(json['membershipExpireAt']),
      postQuota: (json['postQuota'] ?? 0) is int ? (json['postQuota'] as int) : int.tryParse((json['postQuota'] ?? '0').toString()) ?? 0,
    );
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final merged = {...data, 'id': doc.id};
    return User.fromJson(merged);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'role': role,
      'isVerified': isVerified,
      'isDisabled': isDisabled,
      'membershipId': membershipId,
      'membershipExpireAt': membershipExpireAt?.toIso8601String(),
      'postQuota': postQuota,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

// Alias to keep compatibility with existing references to AppUser
typedef AppUser = User;
