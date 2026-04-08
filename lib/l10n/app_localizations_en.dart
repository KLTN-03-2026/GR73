// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WRStudios';

  @override
  String get home => 'Home';

  @override
  String get search => 'Search';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get postDetail => 'Post Detail';

  @override
  String get contactOwner => 'Contact Owner';

  @override
  String get callNow => 'Call Now';

  @override
  String get close => 'Close';

  @override
  String get payment => 'Payment';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get payNow => 'Pay Now';

  @override
  String get paymentSuccess => 'Payment Success';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get requiredLogin => 'Please login to continue';

  @override
  String get myPosts => 'My Posts';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get role => 'Role';

  @override
  String get admin => 'Admin';

  @override
  String get user => 'User';

  @override
  String get verified => 'Verified';

  @override
  String get notVerified => 'Not Verified';

  @override
  String get phone => 'Phone Number';

  @override
  String get joinedDate => 'Joined Date';

  @override
  String get noData => 'No Data';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get filterSearch => 'Filter Search';

  @override
  String get amenities => 'Amenities';

  @override
  String get selectAmenities => 'Select available amenities';

  @override
  String get apply => 'Apply';

  @override
  String get searchPlaceholder => 'Search apartments...';

  @override
  String get all => 'All';

  @override
  String get apartment => 'Apartment';

  @override
  String get house => 'House';

  @override
  String get room => 'Room';

  @override
  String get office => 'Office';

  @override
  String get penthouse => 'Penthouse';

  @override
  String get welcome => 'Welcome!';

  @override
  String get loginPrompt => 'Login to post and save favorites.';

  @override
  String get registration => 'Registration';

  @override
  String get pleaseLoginToManage => 'Please login to manage posts';

  @override
  String get pleaseLoginToPost => 'Please login to post';

  @override
  String get membersOnly => 'Only members can access Membership';

  @override
  String get adminOnly => 'Only admin can access Dashboard';

  @override
  String get mapApartment => 'Apartment Map';

  @override
  String get chatbotAI => 'AI Assistant';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get createPost => 'Create New Post';

  @override
  String get managePremium => 'Manage Premium Plans';

  @override
  String get cloudinaryTest => 'Cloudinary Test';

  @override
  String get pleaseLoginProfile => 'Please login to view profile';

  @override
  String get notUpdated => 'Not updated';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get fullName => 'Full Name';

  @override
  String get updateProfileSuccess => 'Profile updated successfully';

  @override
  String get updateProfileError => 'Error updating profile: ';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get email => 'Email';

  @override
  String get description => 'Description';

  @override
  String get ownerInfo => 'Owner Information';

  @override
  String get reviews => 'Reviews';

  @override
  String get noReviews => 'No reviews yet';

  @override
  String get youRated => 'You rated';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get orderInfo => 'Order Information';

  @override
  String get bankTransferContent => 'Transfer Content';

  @override
  String get bankTransferNote =>
      'After transferring, press Payment button to confirm.';

  @override
  String get processing => 'Processing...';

  @override
  String get pay => 'Pay';

  @override
  String get loginToPay => 'Please login to pay';

  @override
  String get paymentCreated =>
      'Payment order created. Please transfer according to instructions';

  @override
  String get paymentError => 'Payment error: ';

  @override
  String get qrNotFound =>
      'QR image not found. Add file to assets/payments or configure URL.';

  @override
  String get accountName => 'Account Name';

  @override
  String get accountNumber => 'Account Number';

  @override
  String get posts => 'posts';

  @override
  String get enterValidEmailBeforeRecovery =>
      'Enter valid email before password recovery';

  @override
  String recoveryEmailSent(String email) {
    return 'Recovery email sent to $email';
  }

  @override
  String recoveryError(Object error) {
    return 'Recovery error: $error';
  }

  @override
  String get helloWelcome => 'Hello, Welcome!';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get adminFilled => 'Admin pre-filled via dart-define';

  @override
  String get loginWithSocial => 'Or login with social platforms';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerSuccess =>
      'Registration successful. Please login to continue.';

  @override
  String get username => 'Username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get manageMembers => 'Manage Members';

  @override
  String get manageMembersDesc => 'View list, lock/unlock';

  @override
  String get managePosts => 'Manage Posts';

  @override
  String get managePostsDesc => 'Approve, hide/show, delete';

  @override
  String get manageReviews => 'Manage Reviews';

  @override
  String get manageReviewsDesc => 'View/delete comments';

  @override
  String get reportsAndStats => 'Reports & Statistics';

  @override
  String get systemOverview => 'System Overview';

  @override
  String get users => 'Users';

  @override
  String get aiStats30Days => 'AI Stats (30 days)';

  @override
  String get totalEvents => 'Total Events';

  @override
  String get postViews => 'Post Views';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get topCities => 'Top Cities';

  @override
  String get other => 'Other';

  @override
  String get topPosts => 'Top Posts';

  @override
  String get postLabel => 'Post: ';

  @override
  String get approved => 'Approved';

  @override
  String get pending => 'Pending';

  @override
  String get postApproved => 'Post approved';

  @override
  String get postUnapproved => 'Post unapproved';

  @override
  String updateApprovalError(Object error) {
    return 'Update approval error: $error';
  }

  @override
  String get unapprove => 'Unapprove';

  @override
  String get approve => 'Approve';

  @override
  String get postDeleted => 'Post deleted';

  @override
  String get cannotDeletePostHidden => 'Cannot delete, post hidden';

  @override
  String deleteError(Object error) {
    return 'Delete error: $error';
  }

  @override
  String get reviewDeleted => 'Review deleted';

  @override
  String deleteReviewError(Object error) {
    return 'Delete review error: $error';
  }

  @override
  String get adminRole => 'Admin';

  @override
  String get apartmentDetails => 'Apartment Details';

  @override
  String get beTheFirstToPost => 'Be the first to post!';

  @override
  String get membership => 'Membership';

  @override
  String get paypalNote =>
      'PayPal requires a server to create orders. Currently running in demo mode.';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get confirmDeletePost => 'Are you sure you want to delete this post?';

  @override
  String get deleteSuccess => 'Post deleted successfully';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get createNewPost => 'Create New Post';

  @override
  String get editPost => 'Edit Post';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get propertySpecs => 'Property Specifications';

  @override
  String get propertyImages => 'Property Images';

  @override
  String get imageUploadHint => 'Add at least 1 image (Max 10 images)';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get add => 'Add';

  @override
  String get uploadingImages => 'Uploading images...';

  @override
  String get pleaseSelectImage => 'Please select at least 1 image';

  @override
  String get bedrooms => 'Bedrooms';

  @override
  String get bathrooms => 'Bathrooms';

  @override
  String get library => 'Library';

  @override
  String get camera => 'Camera';

  @override
  String get photoAdded => 'Photo added';

  @override
  String photoCaptureError(Object error) {
    return 'Photo capture error: $error';
  }

  @override
  String get locationError => 'Could not get location';

  @override
  String get locationSuccess => 'Location acquired';

  @override
  String get selectLocation => 'Select Location';

  @override
  String addedNImages(int count) {
    return 'Added $count images';
  }

  @override
  String photoPickError(Object error) {
    return 'Error picking photos: $error';
  }

  @override
  String get getCurrentLocation => 'Get Current Location';

  @override
  String get noLocation => 'No location';

  @override
  String get addressLabel => 'Address *';

  @override
  String get addressHint => 'House number, street, ward...';

  @override
  String get cityLabel => 'City *';

  @override
  String get cityHint => 'HCMC';

  @override
  String get cityRequired => 'Please enter city';

  @override
  String get propertyType => 'Property Type';

  @override
  String get updatePostSuccess => 'Post updated successfully';

  @override
  String get createPostSuccess => 'Post created successfully';

  @override
  String postLimitReached(int limit) {
    return 'You have reached the limit of $limit posts. Please upgrade your membership.';
  }

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String remainingPosts(int count) {
    return '$count posts remaining';
  }

  @override
  String get priceRange => 'Price Range (VND)';

  @override
  String get areaRange => 'Area (m²)';

  @override
  String get searchHistory => 'Search History';

  @override
  String get clearHistory => 'Clear History';

  @override
  String maxImagesLimit(int limit) {
    return 'You can only upload a maximum of $limit images.';
  }

  @override
  String get newest => 'Newest';

  @override
  String get priceAsc => 'Price Asc';

  @override
  String get priceDesc => 'Price Desc';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get filterLabel => 'Filter';

  @override
  String get saved => 'Saved';

  @override
  String get saveSearch => 'Save Search';

  @override
  String get searchName => 'Search Name';

  @override
  String get mySearch => 'My Search';

  @override
  String get outOfQuotaTitle => 'Out of Quota';

  @override
  String get outOfQuotaMsg =>
      'Please upgrade your plan to increase post quota.';

  @override
  String get forYou => 'For You';

  @override
  String get amenityAC => 'Air Conditioner';

  @override
  String get amenityWashingMachine => 'Washing Machine';

  @override
  String get amenityKitchen => 'Kitchen Cabinet';

  @override
  String get amenityInternet => 'Internet';

  @override
  String get amenityCableTV => 'Cable TV';

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenitySecurity => 'Security 24/7';

  @override
  String get amenityPool => 'Swimming Pool';

  @override
  String get amenityGym => 'Gym';

  @override
  String get amenityPlayground => 'Kids Playground';

  @override
  String get amenityBalcony => 'Balcony/Terrace';

  @override
  String get amenitySecuritySystem => 'Security System';

  @override
  String get amenityElevator => 'Elevator';

  @override
  String get amenityGarage => 'Garage';

  @override
  String get amenityLargeWindows => 'Large Windows';

  @override
  String get amenityFurnished => 'Fully Furnished';

  @override
  String get enterAreaForPrice => 'Please enter area to get price suggestion';

  @override
  String get analyzingMarket => 'Analyzing market data...';

  @override
  String get aiPriceSuggestion => 'AI Price Suggestion';

  @override
  String basedOn(String area, String type, int count) {
    return 'Based on area ${area}m², type $type and $count amenities:';
  }

  @override
  String get aiAnalyzingImages => 'AI is analyzing images to find amenities...';

  @override
  String autoAdded(String items) {
    return 'Automatically added: $items';
  }

  @override
  String uploadError(Object error) {
    return 'Upload error: $error';
  }

  @override
  String get postTemplates => 'Post Templates';

  @override
  String get applyTemplate => 'Template applied';

  @override
  String get titleLabel => 'Title *';

  @override
  String get titleHint => 'Ex: Luxury Apartment in D1';

  @override
  String get descLabel => 'Detailed Description *';

  @override
  String get descHint => 'Full description of the apartment...';

  @override
  String get aiDesc => 'AI Description Suggestion';

  @override
  String get aiDescSuccess => 'Description generated automatically';

  @override
  String get priceLabel => 'Rent Price (VND) *';

  @override
  String get enterValidNumber => 'Please enter a valid number';

  @override
  String get areaLabel => 'Area (m²) *';

  @override
  String get enterArea => 'Please enter area';

  @override
  String get aiPrice => 'AI Price';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get contactEmail => 'Contact Email';

  @override
  String get updatePost => 'Update Post';

  @override
  String get postNow => 'Post Now';

  @override
  String get adminPortal => 'Admin Portal';

  @override
  String get viewHome => 'View Home';

  @override
  String get managePayments => 'Manage Payments';

  @override
  String get managePaymentsDesc => 'Approve and track payments';

  @override
  String get managePlansDesc => 'Add/Edit/Delete membership plans';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System default';

  @override
  String get revenueStats => 'Revenue Statistics';

  @override
  String get today => 'Today';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get transactionsSuccess => 'Successful Transactions';

  @override
  String get transactionsFailed => 'Failed Transactions';

  @override
  String get transactionsSubmitted => 'Submitted Transactions';

  @override
  String get reportPost => 'Report Post';

  @override
  String get pleaseLoginToReport => 'Please login to report';

  @override
  String get reportReasonsSpam => 'Spam';

  @override
  String get reportReasonsInappropriate => 'Inappropriate content';

  @override
  String get reportReasonsFalseInfo => 'False information';

  @override
  String get reportReasonsScam => 'Scam';

  @override
  String get reportReasonsOther => 'Other';

  @override
  String get reportSubmitted => 'Report submitted';

  @override
  String get reportError => 'Report error:';

  @override
  String get manageContentReports => 'Manage Reports';

  @override
  String get manageContentReportsDesc => 'View/handle violation reports';
}
