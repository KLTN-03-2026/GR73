import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/post_detail_screen.dart';
import '../models/post.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/public_profile_screen.dart';
import '../screens/user/my_posts_screen.dart';
import '../screens/user/create_post_screen.dart';
import '../screens/payments/payment_screen.dart';
import '../screens/payments/manage_plans_screen.dart';
import '../screens/payments/membership_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_members_screen.dart';
import '../screens/admin/admin_posts_screen.dart';
import '../screens/admin/admin_reviews_screen.dart';
import '../screens/admin/admin_reports_screen.dart';
import '../screens/admin/admin_payments_screen.dart';
import '../screens/admin/admin_content_reports_screen.dart';
import '../screens/dev/cloudinary_test_screen.dart';
import '../screens/home/map_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/ai/chatbot_screen.dart';

class AppRouter {
  static const String initialRoute = '/home';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String publicProfile = '/public-profile';
  static const String settings = '/settings';
  static const String myPosts = '/my-posts';
  static const String createPost = '/create-post';
  static const String postDetail = '/post-detail';
  static const String map = '/map';
  static const String chatbot = '/chatbot';
  static const String cloudinaryTest = '/cloudinary-test';
  static const String payment = '/payment';
  static const String managePlans = '/manage-plans';
  static const String membership = '/membership';
  static const String admin = '/admin';
  static const String adminMembers = '/admin/members';
  static const String adminPosts = '/admin/posts';
  static const String adminReviews = '/admin/reviews';
  static const String adminReports = '/admin/reports';
  static const String adminContentReports = '/admin/content-reports';
  static const String adminPayments = '/admin/payments';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case publicProfile:
        final userId = routeSettings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: userId));
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case myPosts:
        return MaterialPageRoute(builder: (_) => const MyPostsScreen());
      case createPost:
        final postToEdit = routeSettings.arguments as Post?;
        return MaterialPageRoute(builder: (_) => CreatePostScreen(postToEdit: postToEdit));
      case postDetail:
        final postId = routeSettings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => PostDetailScreen(postId: postId ?? ''),
        );
      case cloudinaryTest:
        return MaterialPageRoute(builder: (_) => const CloudinaryTestScreen());
      case map:
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case chatbot:
        return MaterialPageRoute(builder: (_) => const ChatbotScreen());
      case payment:
        return MaterialPageRoute(builder: (_) => const PaymentScreen(), settings: routeSettings);
      case managePlans:
        return MaterialPageRoute(builder: (_) => const ManagePlansScreen());
      case membership:
        return MaterialPageRoute(builder: (_) => const MembershipScreen());
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case adminMembers:
        return MaterialPageRoute(builder: (_) => const AdminMembersScreen());
      case adminPosts:
        return MaterialPageRoute(builder: (_) => const AdminPostsScreen());
      case adminReviews:
        return MaterialPageRoute(builder: (_) => const AdminReviewsScreen());
      case adminReports:
        return MaterialPageRoute(builder: (_) => const AdminReportsScreen());
      case adminContentReports:
        return MaterialPageRoute(builder: (_) => const AdminContentReportsScreen());
      case adminPayments:
        return MaterialPageRoute(builder: (_) => const AdminPaymentsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy route: ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
