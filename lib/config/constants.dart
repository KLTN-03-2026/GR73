class AppConstants {
  // API Endpoints
  static const String apiBaseUrl = 'http://your-api-url.com/api';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String postsEndpoint = '/posts';
  static const String userPostsEndpoint = '/posts/my-posts';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Validation Messages
  static const String emailRequired = 'Vui lòng nhập email';
  static const String emailInvalid = 'Email không hợp lệ';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static const String passwordMinLength = 'Mật khẩu phải có ít nhất 6 ký tự';
  static const String nameRequired = 'Vui lòng nhập họ tên';
  static const String phoneRequired = 'Vui lòng nhập số điện thoại';
  static const String titleRequired = 'Vui lòng nhập tiêu đề';
  static const String descriptionRequired = 'Vui lòng nhập mô tả';
  static const String priceRequired = 'Vui lòng nhập giá';
  static const String addressRequired = 'Vui lòng nhập địa chỉ';
  // XÓA CÁC DÒNG TRÙNG LẶP Ở ĐÂY (dòng 34-38)
  
  // App Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const int maxImages = 10;
  static const int maxImageSizeMB = 10;
  
  // Cloudinary config
  static const String cloudinaryCloudName = 'dof4h81ab';
  static const String cloudinaryUploadPreset = 'mobile_unsigned';

  // Admin control
  static const List<String> adminEmails = [
    'ngotiu2004@gmail.com',
  ];
}
