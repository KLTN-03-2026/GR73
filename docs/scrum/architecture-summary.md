# Architecture Summary (HLD)

- UI: Flutter screens & widgets; dark/light theo `ColorScheme`.
- State: Providers — AuthProvider, PostProvider, LocaleProvider, ThemeProvider.
- Routing: `MaterialApp` + `AppRouter` ([app.dart](file:///Users/mac/Flutter_project/App_WRStudios/lib/app.dart), [config/app_router.dart](file:///Users/mac/Flutter_project/App_WRStudios/lib/config/app_router.dart)).
- Services: Firebase (Auth/Firestore/Storage), PaymentService, CloudinaryService, RecommendationService, ChatService (fallback nội bộ).
- Data: collections `users`, `posts`, `reviews`, `favorites`, `payments`, `recommend_events`, `reports`.
- Admin: screens quản trị ([admin_*](file:///Users/mac/Flutter_project/App_WRStudios/lib/screens/admin)).
- i18n: gen-l10n với `app_vi.arb`, `app_en.arb`.
- Theme: `AppTheme` + `ThemeProvider`, lưu SharedPreferences.
- Bảo mật: secrets qua `--dart-define`; Firestore Rules (cần bổ sung trong môi trường triển khai).
