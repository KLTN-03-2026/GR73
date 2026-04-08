# Product Backlog (User Stories)

US-01 Tìm kiếm & lọc
- As a visitor, I want to search posts by keyword, city, price, area, amenities so I can quickly find suitable apartments.
- Acceptance: thanh tìm kiếm debounce; filters giá/diện tích/tiện ích; sort newest/priceAsc/priceDesc; lưu tìm kiếm; lịch sử.

US-02 Bản đồ
- As a user, I want to view posts on a map (OSM/Mapbox) so I can assess location.
- Acceptance: mở trang bản đồ, marker theo vị trí, chọn provider mặc định.

US-03 Đăng bài
- As an authenticated user, I want to create/edit/delete posts with photos.
- Acceptance: form hợp lệ; upload ảnh; cập nhật Firestore; quota kiểm soát.

US-04 Yêu thích
- As a user, I want to favorite/unfavorite posts.
- Acceptance: toggle, lưu favorites, gợi ý dựa trên favorites.

US-05 Membership & Thanh toán
- As a user, I want to upgrade membership with a payment flow.
- Acceptance: tạo payment, trạng thái submitted/success/failed; quota+benefits cập nhật; cảnh báo hết quota.

US-06 Admin quản trị
- As an admin, I want to manage users/posts/reviews.
- Acceptance: danh sách, lọc, khoá/duyệt; hiển thị rõ trạng thái.

US-07 Báo cáo vi phạm
- As a user, I want to report a post; As an admin, I want to resolve reports.
- Acceptance: nút báo cáo trên thẻ; form lý do; collection `reports`; admin đổi trạng thái open/resolved/rejected.

US-08 Thống kê doanh thu
- As an admin, I want to view revenue stats (today/7d/30d; counts).
- Acceptance: tổng hợp từ `payments`, hiển thị thẻ thống kê.

US-09 i18n & Theme
- As a user, I want vi/en and light/dark/system themes.
- Acceptance: đổi ngôn ngữ/ giao diện tại Settings và Profile; lưu SharedPreferences.

US-10 Chatbox
- As a user, I want a help chatbot.
- Acceptance: trả lời nội bộ (FAQ), optional AI khi có key.
