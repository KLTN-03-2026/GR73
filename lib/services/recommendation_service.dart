import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/post.dart';
import 'recommendation_backend.dart';

class RecommendationService {
  static final _backend = createBackend();

  static Future<void> init() async {
    await _backend.init();
  }

  static List<Post> rank(List<Post> posts, {String? city, double? budget}) {
    if (posts.isEmpty) return posts;
    if (kIsWeb) {
      posts.sort((a, b) => _scoreHeuristic(b, city: city, budget: budget).compareTo(_scoreHeuristic(a, city: city, budget: budget)));
      return posts;
    }
    final scored = posts.map((p) => (p, _scoreModel(p, city: city, budget: budget))).toList();
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.map((e) => e.$1).toList();
  }

  static double _scoreHeuristic(Post p, {String? city, double? budget}) {
    double s = 0;
    s += min(1.0, p.area / 100.0) * 0.25;
    s += min(1.0, p.bedrooms / 4.0) * 0.15;
    s += city != null && city.isNotEmpty && p.city == city ? 0.2 : 0;
    if (budget != null && budget > 0) {
      final diff = (budget - p.price).abs();
      s += diff <= budget * 0.2 ? 0.2 : 0.05;
    } else {
      s += p.price < 10_000_000 ? 0.1 : 0.05;
    }
    final days = DateTime.now().difference(p.createdAt).inDays;
    s += days < 7 ? 0.2 : days < 30 ? 0.1 : 0.05;
    if (p.isFeatured) s += 0.1;
    return s;
  }

  static double _scoreModel(Post p, {String? city, double? budget}) {
    try {
      final features = _buildFeatures(p, city: city, budget: budget);
      final s = _backend.score(features);
      if (s != null) return s;
      return _scoreHeuristic(p, city: city, budget: budget);
    } catch (_) {
      return _scoreHeuristic(p, city: city, budget: budget);
    }
  }

  static List<double> _buildFeatures(Post p, {String? city, double? budget}) {
    final priceNorm = (p.price / 20000000.0).clamp(0.0, 1.0);
    final areaNorm = (p.area / 120.0).clamp(0.0, 1.0);
    final bedNorm = (p.bedrooms / 4.0).clamp(0.0, 1.0);
    final bathNorm = (p.bathrooms / 3.0).clamp(0.0, 1.0);
    final featured = p.isFeatured ? 1.0 : 0.0;
    final days = DateTime.now().difference(p.createdAt).inDays.toDouble();
    final recencyNorm = (days / 60.0).clamp(0.0, 1.0);
    final cityMatch = (city != null && city.isNotEmpty && p.city == city) ? 1.0 : 0.0;
    final budgetNorm = budget != null && budget > 0 ? (1.0 - ((p.price - budget).abs() / (budget + 1))).clamp(0.0, 1.0) : 0.0;
    return [priceNorm, areaNorm, bedNorm, bathNorm, featured, recencyNorm, cityMatch, budgetNorm];
  }
}
