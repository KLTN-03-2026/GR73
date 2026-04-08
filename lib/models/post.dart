import 'package:cloud_firestore/cloud_firestore.dart';
import 'user.dart'; // Đổi thành import tương đối

class Post {
  final String id;
  final String title;
  final String description;
  final double price;
  final String address;
  final String city;
  final String type;
  final double? lat;
  final double? lng;
  final double area;
  final int bedrooms;
  final int bathrooms;
  final List<String> images;
  final User owner; // Đổi từ AppUser thành User
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> amenities;
  final String? contactPhone;
  final String? contactEmail;
  final int views;
  final bool isFeatured;
  final bool isApproved;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    required this.city,
    required this.type,
    this.lat,
    this.lng,
    required this.area,
    required this.bedrooms,
    required this.bathrooms,
    this.images = const [],
    required this.owner,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.amenities = const [],
    this.contactPhone,
    this.contactEmail,
    this.views = 0,
    this.isFeatured = false,
    this.isApproved = true,
  });

  factory Post.fromFirestore(DocumentSnapshot doc, User owner) { // Đổi AppUser -> User
    final data = doc.data() as Map<String, dynamic>;
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }
    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }
    DateTime toDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }
    return Post(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: toDouble(data['price']),
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      type: data['type'] ?? 'Căn hộ',
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      area: toDouble(data['area']),
      bedrooms: toInt(data['bedrooms']),
      bathrooms: toInt(data['bathrooms']),
      images: List<String>.from(data['images'] ?? []),
      owner: owner,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: toDate(data['createdAt']),
      updatedAt: toDate(data['updatedAt']),
      amenities: List<String>.from(data['amenities'] ?? []),
      contactPhone: data['contactPhone'],
      contactEmail: data['contactEmail'],
      views: toInt(data['views']),
      isFeatured: data['isFeatured'] ?? false,
      isApproved: data['isApproved'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': id,
      'title': title,
      'description': description,
      'price': price,
      'address': address,
      'city': city,
      'type': type,
      'lat': lat,
      'lng': lng,
      'area': area,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'images': images,
      'ownerId': owner.id,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'amenities': amenities,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'views': views,
      'isFeatured': isFeatured,
      'isApproved': isApproved,
    };
  }

  String get formattedPrice {
    final intVal = price.round();
    final s = intVal.toString();
    final b = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      b.write(s[i]);
      c++;
      if (c == 3 && i != 0) {
        b.write('.');
        c = 0;
      }
    }
    final formatted = b.toString().split('').reversed.join();
    return '$formatted VNĐ/tháng';
  }

  String get basicInfo {
    return '$bedrooms PN • $bathrooms WC • ${area.toStringAsFixed(0)} m²';
  }
}
