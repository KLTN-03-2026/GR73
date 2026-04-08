import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io';
import 'firebase_service.dart';

class AIService {
  // Image Labeling
  static Future<List<String>> analyzeImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.6);
      final imageLabeler = ImageLabeler(options: options);
      
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
      
      final List<String> labelTexts = labels.map((l) => l.label).toList();
      debugPrint('AI Labels found: $labelTexts');
      
      imageLabeler.close();
      
      return suggestAmenitiesFromLabels(labelTexts);
    } catch (e) {
      debugPrint('AI Image Analysis Error: $e');
      return [];
    }
  }

  // Price Prediction
  static Future<double?> predictPrice({
    required String city,
    required String type,
    required double area,
    required int bedrooms,
    List<String> amenities = const [],
  }) async {
    try {
      // 1. Fetch similar posts from Firebase
      // Ideally, we should have a more complex query or a dedicated backend function
      // For now, we fetch recent posts in the same city and type
      final posts = await FirebaseService.searchPosts(city); 
      
      // if (posts.isEmpty) return null; // Removed to allow fallback

      // 2. Filter by type and calculate average price per m2
      var similarPosts = posts.where((p) => p.type == type && p.area > 0).toList();
      
      // Fallback: If no posts with same type, use all posts in city
      if (similarPosts.isEmpty) {
        similarPosts = posts.where((p) => p.area > 0).toList();
      }

      // Fallback 2: If still empty (new city), use a default base price per m2
      if (similarPosts.isEmpty) {
        // Default base price: 150,000 VND / m2 (approximate average)
        double basePricePerM2 = 150000;
        double predictedPrice = basePricePerM2 * area;
        
        // Adjust for amenities even with default base price
        if (amenities.isNotEmpty) {
           double amenityBonus = amenities.length * 0.02;
           if (amenityBonus > 0.3) amenityBonus = 0.3;
           predictedPrice += predictedPrice * amenityBonus;
        }
        return (predictedPrice / 100000).round() * 100000;
      }

      double totalPricePerM2 = 0;
      int count = 0;

      for (final post in similarPosts) {
        // Exclude outliers (too cheap or too expensive) if needed
        double pricePerM2 = post.price / post.area;
        totalPricePerM2 += pricePerM2;
        count++;
      }

      if (count == 0) return null;

      double avgPricePerM2 = totalPricePerM2 / count;

      // 3. Adjust based on bedrooms (heuristic)
      // Assume base price is for 1 bedroom. Each extra bedroom adds ~10% value?
      // Or we can just trust area. Usually area covers bedrooms.
      // Let's just use area * avgPricePerM2 for simplicity.
      
      double predictedPrice = avgPricePerM2 * area;
      
      // 4. Adjust based on amenities
      if (amenities.isNotEmpty) {
        // Each amenity adds roughly 2% value
        double amenityBonus = amenities.length * 0.02; 
        // Cap bonus at 30%
        if (amenityBonus > 0.3) amenityBonus = 0.3;
        predictedPrice += predictedPrice * amenityBonus;
      }
      
      // Round to nearest 100,000
      return (predictedPrice / 100000).round() * 100000;
    } catch (e) {
      debugPrint('AI Price Prediction Error: $e');
      return null;
    }
  }

  // Amenities Recommendation from Labels
  static List<String> suggestAmenitiesFromLabels(List<String> labels) {
    final Map<String, List<String>> labelToAmenities = {
      'bed': ['Nội thất đầy đủ'],
      'bedroom': ['Nội thất đầy đủ'],
      'couch': ['Nội thất đầy đủ'],
      'sofa': ['Nội thất đầy đủ'],
      'television': ['Truyền hình cáp', 'Internet'],
      'monitor': ['Internet'],
      'kitchen': ['Tủ bếp'],
      'refrigerator': ['Tủ bếp', 'Nội thất đầy đủ'],
      'washing machine': ['Máy giặt'],
      'pool': ['Hồ bơi'],
      'swimming pool': ['Hồ bơi'],
      'gym': ['Phòng gym'],
      'fitness': ['Phòng gym'],
      'parking': ['Chỗ đậu xe'],
      'car': ['Chỗ đậu xe', 'Nhà để xe'],
      'motorcycle': ['Chỗ đậu xe', 'Nhà để xe'],
      'plant': ['Ban công/sân thượng'],
      'tree': ['Ban công/sân thượng'],
      'balcony': ['Ban công/sân thượng'],
      'window': ['Cửa sổ lớn'],
      'security': ['Bảo vệ 24/7', 'Hệ thống an ninh'],
    };

    final Set<String> suggested = {};
    for (final label in labels) {
      final lowerLabel = label.toLowerCase();
      for (final key in labelToAmenities.keys) {
        if (lowerLabel.contains(key)) {
          suggested.addAll(labelToAmenities[key]!);
        }
      }
    }
    return suggested.toList();
  }

  // Text generation for post description from structured fields
  static Future<String> generateDescription({
    required String type,
    required double area,
    required int bedrooms,
    required int bathrooms,
    required String city,
    required List<String> amenities,
  }) async {
    final amenitiesText = amenities.isEmpty
        ? 'đầy đủ tiện ích cơ bản'
        : amenities.take(6).join(', ');
    final bedText = '$bedrooms phòng ngủ';
    final bathText = '$bathrooms phòng tắm';
    final areaText = '${area.toStringAsFixed(0)}m²';
    final intro = '$type cho thuê tại $city, diện tích $areaText, $bedText, $bathText.';
    final features = 'Căn nhà có ${amenitiesText}. Khu vực an ninh, giao thông thuận tiện, gần tiện ích thiết yếu.';
    final callToAction = 'Liên hệ để xem nhà trực tiếp và thương lượng.';
    return '$intro\n\n$features\n\n$callToAction';
  }
}
