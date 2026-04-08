import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'WRStudios'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @profile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get login;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Anh'**
  String get english;

  /// No description provided for @postDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết bài đăng'**
  String get postDetail;

  /// No description provided for @contactOwner.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ chủ nhà'**
  String get contactOwner;

  /// No description provided for @callNow.
  ///
  /// In vi, this message translates to:
  /// **'Gọi ngay'**
  String get callNow;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @payment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get payment;

  /// No description provided for @paymentMethod.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức thanh toán'**
  String get paymentMethod;

  /// No description provided for @payNow.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán ngay'**
  String get payNow;

  /// No description provided for @paymentSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thành công'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thất bại'**
  String get paymentFailed;

  /// No description provided for @requiredLogin.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để tiếp tục'**
  String get requiredLogin;

  /// No description provided for @myPosts.
  ///
  /// In vi, this message translates to:
  /// **'Tin đăng của tôi'**
  String get myPosts;

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get editProfile;

  /// No description provided for @role.
  ///
  /// In vi, this message translates to:
  /// **'Vai trò'**
  String get role;

  /// No description provided for @admin.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị viên'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In vi, this message translates to:
  /// **'Người dùng'**
  String get user;

  /// No description provided for @verified.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác minh'**
  String get verified;

  /// No description provided for @notVerified.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác minh'**
  String get notVerified;

  /// No description provided for @phone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phone;

  /// No description provided for @joinedDate.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia từ'**
  String get joinedDate;

  /// No description provided for @noData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu'**
  String get noData;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa không?'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In vi, this message translates to:
  /// **'Có'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get no;

  /// No description provided for @filterSearch.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc tìm kiếm'**
  String get filterSearch;

  /// No description provided for @amenities.
  ///
  /// In vi, this message translates to:
  /// **'Tiện ích'**
  String get amenities;

  /// No description provided for @selectAmenities.
  ///
  /// In vi, this message translates to:
  /// **'Chọn các tiện ích có sẵn'**
  String get selectAmenities;

  /// No description provided for @apply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get apply;

  /// No description provided for @searchPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm căn hộ...'**
  String get searchPlaceholder;

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @apartment.
  ///
  /// In vi, this message translates to:
  /// **'Căn hộ'**
  String get apartment;

  /// No description provided for @house.
  ///
  /// In vi, this message translates to:
  /// **'Nhà riêng'**
  String get house;

  /// No description provided for @room.
  ///
  /// In vi, this message translates to:
  /// **'Phòng trọ'**
  String get room;

  /// No description provided for @office.
  ///
  /// In vi, this message translates to:
  /// **'Văn phòng'**
  String get office;

  /// No description provided for @penthouse.
  ///
  /// In vi, this message translates to:
  /// **'Penthouse'**
  String get penthouse;

  /// No description provided for @welcome.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng!'**
  String get welcome;

  /// No description provided for @loginPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để đăng tin và lưu yêu thích.'**
  String get loginPrompt;

  /// No description provided for @registration.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get registration;

  /// No description provided for @pleaseLoginToManage.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để quản lý tin đăng'**
  String get pleaseLoginToManage;

  /// No description provided for @pleaseLoginToPost.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để đăng tin'**
  String get pleaseLoginToPost;

  /// No description provided for @membersOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ thành viên mới có thể truy cập Membership'**
  String get membersOnly;

  /// No description provided for @adminOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ admin mới truy cập Dashboard'**
  String get adminOnly;

  /// No description provided for @mapApartment.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ căn hộ'**
  String get mapApartment;

  /// No description provided for @chatbotAI.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý AI'**
  String get chatbotAI;

  /// No description provided for @adminDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Bảng điều khiển Admin'**
  String get adminDashboard;

  /// No description provided for @createPost.
  ///
  /// In vi, this message translates to:
  /// **'Đăng tin mới'**
  String get createPost;

  /// No description provided for @managePremium.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý gói Premium'**
  String get managePremium;

  /// No description provided for @cloudinaryTest.
  ///
  /// In vi, this message translates to:
  /// **'Cloudinary Test'**
  String get cloudinaryTest;

  /// No description provided for @pleaseLoginProfile.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để xem hồ sơ'**
  String get pleaseLoginProfile;

  /// No description provided for @notUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật'**
  String get notUpdated;

  /// No description provided for @changeAvatar.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh đại diện'**
  String get changeAvatar;

  /// No description provided for @deletePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ảnh'**
  String get deletePhoto;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên'**
  String get fullName;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật hồ sơ thành công'**
  String get updateProfileSuccess;

  /// No description provided for @updateProfileError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi cập nhật hồ sơ: '**
  String get updateProfileError;

  /// No description provided for @confirmLogout.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất?'**
  String get confirmLogout;

  /// No description provided for @phoneNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @description.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get description;

  /// No description provided for @ownerInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin chủ nhà'**
  String get ownerInfo;

  /// No description provided for @reviews.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá'**
  String get reviews;

  /// No description provided for @noReviews.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá'**
  String get noReviews;

  /// No description provided for @youRated.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đánh giá'**
  String get youRated;

  /// No description provided for @minutesAgo.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút trước'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ trước'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In vi, this message translates to:
  /// **'{days} ngày trước'**
  String daysAgo(int days);

  /// No description provided for @orderInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin đơn hàng'**
  String get orderInfo;

  /// No description provided for @bankTransferContent.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung chuyển khoản'**
  String get bankTransferContent;

  /// No description provided for @bankTransferNote.
  ///
  /// In vi, this message translates to:
  /// **'Sau khi chuyển khoản xong, bấm nút Thanh toán để xác nhận.'**
  String get bankTransferNote;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý...'**
  String get processing;

  /// No description provided for @pay.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get pay;

  /// No description provided for @loginToPay.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để thanh toán'**
  String get loginToPay;

  /// No description provided for @paymentCreated.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo đơn thanh toán. Vui lòng chuyển khoản theo hướng dẫn'**
  String get paymentCreated;

  /// No description provided for @paymentError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi thanh toán: '**
  String get paymentError;

  /// No description provided for @qrNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tìm thấy ảnh QR. Thêm file vào assets/payments hoặc cấu hình URL.'**
  String get qrNotFound;

  /// No description provided for @accountName.
  ///
  /// In vi, this message translates to:
  /// **'Tên TK'**
  String get accountName;

  /// No description provided for @accountNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số TK'**
  String get accountNumber;

  /// No description provided for @posts.
  ///
  /// In vi, this message translates to:
  /// **'bài'**
  String get posts;

  /// No description provided for @enterValidEmailBeforeRecovery.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email hợp lệ trước khi khôi phục mật khẩu'**
  String get enterValidEmailBeforeRecovery;

  /// No description provided for @recoveryEmailSent.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi email khôi phục tới {email}'**
  String recoveryEmailSent(String email);

  /// No description provided for @recoveryError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khôi phục: {error}'**
  String recoveryError(Object error);

  /// No description provided for @helloWelcome.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào, Chào mừng!'**
  String get helloWelcome;

  /// No description provided for @dontHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản?'**
  String get dontHaveAccount;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPassword;

  /// No description provided for @adminFilled.
  ///
  /// In vi, this message translates to:
  /// **'Đã điền sẵn admin qua dart-define'**
  String get adminFilled;

  /// No description provided for @loginWithSocial.
  ///
  /// In vi, this message translates to:
  /// **'Hoặc đăng nhập với mạng xã hội'**
  String get loginWithSocial;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get passwordsDoNotMatch;

  /// No description provided for @registerSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công. Vui lòng đăng nhập để tiếp tục.'**
  String get registerSuccess;

  /// No description provided for @username.
  ///
  /// In vi, this message translates to:
  /// **'Tên người dùng'**
  String get username;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPassword;

  /// No description provided for @welcomeBack.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng trở lại!'**
  String get welcomeBack;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản?'**
  String get alreadyHaveAccount;

  /// No description provided for @manageMembers.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý thành viên'**
  String get manageMembers;

  /// No description provided for @manageMembersDesc.
  ///
  /// In vi, this message translates to:
  /// **'Xem danh sách, khoá/mở'**
  String get manageMembersDesc;

  /// No description provided for @managePosts.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý bài viết'**
  String get managePosts;

  /// No description provided for @managePostsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt, ẩn/hiện, xoá'**
  String get managePostsDesc;

  /// No description provided for @manageReviews.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý đánh giá'**
  String get manageReviews;

  /// No description provided for @manageReviewsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Xem/xoá bình luận'**
  String get manageReviewsDesc;

  /// No description provided for @reportsAndStats.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo & Thống kê'**
  String get reportsAndStats;

  /// No description provided for @systemOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan hệ thống'**
  String get systemOverview;

  /// No description provided for @users.
  ///
  /// In vi, this message translates to:
  /// **'Người dùng'**
  String get users;

  /// No description provided for @aiStats30Days.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê AI đề xuất (30 ngày)'**
  String get aiStats30Days;

  /// No description provided for @totalEvents.
  ///
  /// In vi, this message translates to:
  /// **'Tổng sự kiện'**
  String get totalEvents;

  /// No description provided for @postViews.
  ///
  /// In vi, this message translates to:
  /// **'Lượt xem bài'**
  String get postViews;

  /// No description provided for @addToFavorites.
  ///
  /// In vi, this message translates to:
  /// **'Thêm yêu thích'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ yêu thích'**
  String get removeFromFavorites;

  /// No description provided for @topCities.
  ///
  /// In vi, this message translates to:
  /// **'Thành phố xem nhiều'**
  String get topCities;

  /// No description provided for @other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get other;

  /// No description provided for @topPosts.
  ///
  /// In vi, this message translates to:
  /// **'Bài viết xem nhiều'**
  String get topPosts;

  /// No description provided for @postLabel.
  ///
  /// In vi, this message translates to:
  /// **'Post: '**
  String get postLabel;

  /// No description provided for @approved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt'**
  String get approved;

  /// No description provided for @pending.
  ///
  /// In vi, this message translates to:
  /// **'Chưa duyệt'**
  String get pending;

  /// No description provided for @postApproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã duyệt bài'**
  String get postApproved;

  /// No description provided for @postUnapproved.
  ///
  /// In vi, this message translates to:
  /// **'Đã bỏ duyệt bài'**
  String get postUnapproved;

  /// No description provided for @updateApprovalError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi cập nhật duyệt: {error}'**
  String updateApprovalError(Object error);

  /// No description provided for @unapprove.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ duyệt'**
  String get unapprove;

  /// No description provided for @approve.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt'**
  String get approve;

  /// No description provided for @postDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa bài'**
  String get postDeleted;

  /// No description provided for @cannotDeletePostHidden.
  ///
  /// In vi, this message translates to:
  /// **'Không thể xóa, đã ẩn bài'**
  String get cannotDeletePostHidden;

  /// No description provided for @deleteError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi xóa: {error}'**
  String deleteError(Object error);

  /// No description provided for @reviewDeleted.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa đánh giá'**
  String get reviewDeleted;

  /// No description provided for @deleteReviewError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi xóa đánh giá: {error}'**
  String deleteReviewError(Object error);

  /// No description provided for @adminRole.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị viên'**
  String get adminRole;

  /// No description provided for @apartmentDetails.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết căn hộ'**
  String get apartmentDetails;

  /// No description provided for @beTheFirstToPost.
  ///
  /// In vi, this message translates to:
  /// **'Hãy đăng tin đầu tiên!'**
  String get beTheFirstToPost;

  /// No description provided for @membership.
  ///
  /// In vi, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @paypalNote.
  ///
  /// In vi, this message translates to:
  /// **'PayPal sẽ cần server tạo đơn hàng. Hiện đang chạy chế độ demo.'**
  String get paypalNote;

  /// No description provided for @deletePost.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tin đăng'**
  String get deletePost;

  /// No description provided for @confirmDeletePost.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa tin đăng này?'**
  String get confirmDeletePost;

  /// No description provided for @deleteSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa tin đăng thành công'**
  String get deleteSuccess;

  /// No description provided for @noPostsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin đăng nào'**
  String get noPostsYet;

  /// No description provided for @createNewPost.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tin đăng mới'**
  String get createNewPost;

  /// No description provided for @editPost.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa tin đăng'**
  String get editPost;

  /// No description provided for @basicInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cơ bản'**
  String get basicInfo;

  /// No description provided for @propertySpecs.
  ///
  /// In vi, this message translates to:
  /// **'Thông số căn hộ'**
  String get propertySpecs;

  /// No description provided for @propertyImages.
  ///
  /// In vi, this message translates to:
  /// **'Hình ảnh căn hộ'**
  String get propertyImages;

  /// No description provided for @imageUploadHint.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ít nhất 1 ảnh (Tối đa 10 ảnh)'**
  String get imageUploadHint;

  /// No description provided for @addPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh'**
  String get addPhoto;

  /// No description provided for @add.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get add;

  /// No description provided for @uploadingImages.
  ///
  /// In vi, this message translates to:
  /// **'Đang upload ảnh...'**
  String get uploadingImages;

  /// No description provided for @pleaseSelectImage.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn ít nhất 1 ảnh'**
  String get pleaseSelectImage;

  /// No description provided for @bedrooms.
  ///
  /// In vi, this message translates to:
  /// **'Số phòng ngủ'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In vi, this message translates to:
  /// **'Số phòng tắm'**
  String get bathrooms;

  /// No description provided for @library.
  ///
  /// In vi, this message translates to:
  /// **'Thư viện'**
  String get library;

  /// No description provided for @camera.
  ///
  /// In vi, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @photoAdded.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm ảnh chụp mới'**
  String get photoAdded;

  /// No description provided for @photoCaptureError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi chụp ảnh: {error}'**
  String photoCaptureError(Object error);

  /// No description provided for @locationError.
  ///
  /// In vi, this message translates to:
  /// **'Không lấy được vị trí'**
  String get locationError;

  /// No description provided for @locationSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã lấy vị trí hiện tại'**
  String get locationSuccess;

  /// No description provided for @selectLocation.
  ///
  /// In vi, this message translates to:
  /// **'Chọn vị trí'**
  String get selectLocation;

  /// No description provided for @addedNImages.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm {count} ảnh'**
  String addedNImages(int count);

  /// No description provided for @photoPickError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi chọn ảnh: {error}'**
  String photoPickError(Object error);

  /// No description provided for @getCurrentLocation.
  ///
  /// In vi, this message translates to:
  /// **'Lấy vị trí hiện tại'**
  String get getCurrentLocation;

  /// No description provided for @noLocation.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có vị trí'**
  String get noLocation;

  /// No description provided for @addressLabel.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ *'**
  String get addressLabel;

  /// No description provided for @addressHint.
  ///
  /// In vi, this message translates to:
  /// **'Số nhà, đường, phường...'**
  String get addressHint;

  /// No description provided for @cityLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thành phố *'**
  String get cityLabel;

  /// No description provided for @cityHint.
  ///
  /// In vi, this message translates to:
  /// **'TP.HCM'**
  String get cityHint;

  /// No description provided for @cityRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập thành phố'**
  String get cityRequired;

  /// No description provided for @propertyType.
  ///
  /// In vi, this message translates to:
  /// **'Loại bất động sản'**
  String get propertyType;

  /// No description provided for @updatePostSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật tin đăng thành công'**
  String get updatePostSuccess;

  /// No description provided for @createPostSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng tin thành công'**
  String get createPostSuccess;

  /// No description provided for @postLimitReached.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đạt giới hạn {limit} bài đăng. Vui lòng nâng cấp gói thành viên.'**
  String postLimitReached(int limit);

  /// No description provided for @upgradeNow.
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp ngay'**
  String get upgradeNow;

  /// No description provided for @remainingPosts.
  ///
  /// In vi, this message translates to:
  /// **'Còn lại {count} lượt đăng'**
  String remainingPosts(int count);

  /// No description provided for @priceRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng giá (VNĐ)'**
  String get priceRange;

  /// No description provided for @areaRange.
  ///
  /// In vi, this message translates to:
  /// **'Diện tích (m²)'**
  String get areaRange;

  /// No description provided for @searchHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử tìm kiếm'**
  String get searchHistory;

  /// No description provided for @clearHistory.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch sử'**
  String get clearHistory;

  /// No description provided for @maxImagesLimit.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chỉ được tải lên tối đa {limit} ảnh.'**
  String maxImagesLimit(int limit);

  /// No description provided for @newest.
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get newest;

  /// No description provided for @priceAsc.
  ///
  /// In vi, this message translates to:
  /// **'Giá tăng'**
  String get priceAsc;

  /// No description provided for @priceDesc.
  ///
  /// In vi, this message translates to:
  /// **'Giá giảm'**
  String get priceDesc;

  /// No description provided for @clearFilter.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lọc'**
  String get clearFilter;

  /// No description provided for @filterLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get filterLabel;

  /// No description provided for @saved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu'**
  String get saved;

  /// No description provided for @saveSearch.
  ///
  /// In vi, this message translates to:
  /// **'Lưu tìm kiếm'**
  String get saveSearch;

  /// No description provided for @searchName.
  ///
  /// In vi, this message translates to:
  /// **'Tên bộ tìm kiếm'**
  String get searchName;

  /// No description provided for @mySearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm của tôi'**
  String get mySearch;

  /// No description provided for @outOfQuotaTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hết lượt đăng tin'**
  String get outOfQuotaTitle;

  /// No description provided for @outOfQuotaMsg.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nâng cấp gói để tăng hạn mức đăng tin.'**
  String get outOfQuotaMsg;

  /// No description provided for @forYou.
  ///
  /// In vi, this message translates to:
  /// **'Dành cho bạn'**
  String get forYou;

  /// No description provided for @amenityAC.
  ///
  /// In vi, this message translates to:
  /// **'Máy lạnh'**
  String get amenityAC;

  /// No description provided for @amenityWashingMachine.
  ///
  /// In vi, this message translates to:
  /// **'Máy giặt'**
  String get amenityWashingMachine;

  /// No description provided for @amenityKitchen.
  ///
  /// In vi, this message translates to:
  /// **'Tủ bếp'**
  String get amenityKitchen;

  /// No description provided for @amenityInternet.
  ///
  /// In vi, this message translates to:
  /// **'Internet'**
  String get amenityInternet;

  /// No description provided for @amenityCableTV.
  ///
  /// In vi, this message translates to:
  /// **'Truyền hình cáp'**
  String get amenityCableTV;

  /// No description provided for @amenityParking.
  ///
  /// In vi, this message translates to:
  /// **'Chỗ đậu xe'**
  String get amenityParking;

  /// No description provided for @amenitySecurity.
  ///
  /// In vi, this message translates to:
  /// **'Bảo vệ 24/7'**
  String get amenitySecurity;

  /// No description provided for @amenityPool.
  ///
  /// In vi, this message translates to:
  /// **'Hồ bơi'**
  String get amenityPool;

  /// No description provided for @amenityGym.
  ///
  /// In vi, this message translates to:
  /// **'Phòng gym'**
  String get amenityGym;

  /// No description provided for @amenityPlayground.
  ///
  /// In vi, this message translates to:
  /// **'Khu vui chơi trẻ em'**
  String get amenityPlayground;

  /// No description provided for @amenityBalcony.
  ///
  /// In vi, this message translates to:
  /// **'Ban công/sân thượng'**
  String get amenityBalcony;

  /// No description provided for @amenitySecuritySystem.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống an ninh'**
  String get amenitySecuritySystem;

  /// No description provided for @amenityElevator.
  ///
  /// In vi, this message translates to:
  /// **'Thang máy'**
  String get amenityElevator;

  /// No description provided for @amenityGarage.
  ///
  /// In vi, this message translates to:
  /// **'Nhà để xe'**
  String get amenityGarage;

  /// No description provided for @amenityLargeWindows.
  ///
  /// In vi, this message translates to:
  /// **'Cửa sổ lớn'**
  String get amenityLargeWindows;

  /// No description provided for @amenityFurnished.
  ///
  /// In vi, this message translates to:
  /// **'Nội thất đầy đủ'**
  String get amenityFurnished;

  /// No description provided for @enterAreaForPrice.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập diện tích để gợi ý giá'**
  String get enterAreaForPrice;

  /// No description provided for @analyzingMarket.
  ///
  /// In vi, this message translates to:
  /// **'Đang phân tích dữ liệu thị trường...'**
  String get analyzingMarket;

  /// No description provided for @aiPriceSuggestion.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý giá từ AI'**
  String get aiPriceSuggestion;

  /// No description provided for @basedOn.
  ///
  /// In vi, this message translates to:
  /// **'Dựa trên diện tích {area}m², loại {type} và {count} tiện ích:'**
  String basedOn(String area, String type, int count);

  /// No description provided for @aiAnalyzingImages.
  ///
  /// In vi, this message translates to:
  /// **'AI đang phân tích ảnh để tìm tiện ích...'**
  String get aiAnalyzingImages;

  /// No description provided for @autoAdded.
  ///
  /// In vi, this message translates to:
  /// **'Đã tự động thêm: {items}'**
  String autoAdded(String items);

  /// No description provided for @uploadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi upload ảnh: {error}'**
  String uploadError(Object error);

  /// No description provided for @postTemplates.
  ///
  /// In vi, this message translates to:
  /// **'Mẫu bài đăng'**
  String get postTemplates;

  /// No description provided for @applyTemplate.
  ///
  /// In vi, this message translates to:
  /// **'Đã áp dụng mẫu bài đăng'**
  String get applyTemplate;

  /// No description provided for @titleLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu đề *'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In vi, this message translates to:
  /// **'VD: Căn hộ cao cấp Q1 view đẹp'**
  String get titleHint;

  /// No description provided for @descLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả chi tiết *'**
  String get descLabel;

  /// No description provided for @descHint.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả đầy đủ về căn hộ...'**
  String get descHint;

  /// No description provided for @aiDesc.
  ///
  /// In vi, this message translates to:
  /// **'AI gợi ý mô tả'**
  String get aiDesc;

  /// No description provided for @aiDescSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo mô tả tự động'**
  String get aiDescSuccess;

  /// No description provided for @priceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giá thuê (VNĐ) *'**
  String get priceLabel;

  /// No description provided for @enterValidNumber.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập số hợp lệ'**
  String get enterValidNumber;

  /// No description provided for @areaLabel.
  ///
  /// In vi, this message translates to:
  /// **'Diện tích (m²) *'**
  String get areaLabel;

  /// No description provided for @enterArea.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập diện tích'**
  String get enterArea;

  /// No description provided for @aiPrice.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý giá AI'**
  String get aiPrice;

  /// No description provided for @contactInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin liên hệ'**
  String get contactInfo;

  /// No description provided for @contactPhone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại liên hệ'**
  String get contactPhone;

  /// No description provided for @contactEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email liên hệ'**
  String get contactEmail;

  /// No description provided for @updatePost.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật tin đăng'**
  String get updatePost;

  /// No description provided for @postNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng tin'**
  String get postNow;

  /// No description provided for @adminPortal.
  ///
  /// In vi, this message translates to:
  /// **'Cổng quản trị'**
  String get adminPortal;

  /// No description provided for @viewHome.
  ///
  /// In vi, this message translates to:
  /// **'Xem trang chủ'**
  String get viewHome;

  /// No description provided for @managePayments.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý thanh toán'**
  String get managePayments;

  /// No description provided for @managePaymentsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt và theo dõi thanh toán'**
  String get managePaymentsDesc;

  /// No description provided for @managePlansDesc.
  ///
  /// In vi, this message translates to:
  /// **'Thêm/Sửa/Xóa gói thành viên'**
  String get managePlansDesc;

  /// No description provided for @theme.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get themeSystem;

  /// No description provided for @revenueStats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê doanh thu'**
  String get revenueStats;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @last7Days.
  ///
  /// In vi, this message translates to:
  /// **'7 ngày qua'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In vi, this message translates to:
  /// **'30 ngày qua'**
  String get last30Days;

  /// No description provided for @transactionsSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch thành công'**
  String get transactionsSuccess;

  /// No description provided for @transactionsFailed.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch thất bại'**
  String get transactionsFailed;

  /// No description provided for @transactionsSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch chờ duyệt'**
  String get transactionsSubmitted;

  /// No description provided for @reportPost.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo bài viết'**
  String get reportPost;

  /// No description provided for @pleaseLoginToReport.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để báo cáo'**
  String get pleaseLoginToReport;

  /// No description provided for @reportReasonsSpam.
  ///
  /// In vi, this message translates to:
  /// **'Spam'**
  String get reportReasonsSpam;

  /// No description provided for @reportReasonsInappropriate.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung không phù hợp'**
  String get reportReasonsInappropriate;

  /// No description provided for @reportReasonsFalseInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin sai lệch'**
  String get reportReasonsFalseInfo;

  /// No description provided for @reportReasonsScam.
  ///
  /// In vi, this message translates to:
  /// **'Lừa đảo'**
  String get reportReasonsScam;

  /// No description provided for @reportReasonsOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get reportReasonsOther;

  /// No description provided for @reportSubmitted.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi báo cáo'**
  String get reportSubmitted;

  /// No description provided for @reportError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi gửi báo cáo:'**
  String get reportError;

  /// No description provided for @manageContentReports.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý báo cáo'**
  String get manageContentReports;

  /// No description provided for @manageContentReportsDesc.
  ///
  /// In vi, this message translates to:
  /// **'Xem/Xử lý báo cáo vi phạm'**
  String get manageContentReportsDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
