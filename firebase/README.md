# Firestore Rules

## Triển khai nhanh bằng Firebase CLI

1. Cài Firebase CLI (nếu chưa):
   ```bash
   curl -sL https://firebase.tools | bash
   ```
2. Đăng nhập:
   ```bash
   firebase login
   ```
3. Chọn project (ví dụ `thang-946f5`):
   ```bash
   firebase use thang-946f5
   ```
4. Triển khai rules:
   ```bash
   firebase deploy --only firestore:rules --force --project thang-946f5 --token "<FIREBASE_TOKEN_TÙY_CHỌN>"
   ```

## Nội dung rules

File `firebase/firestore.rules` đã chứa quyền:
- Đọc `users` công khai; người dùng tự tạo/cập nhật hồ sơ của chính mình
- Bài viết công khai khi `isApproved == true`; chủ bài hoặc admin update/delete
- Favorites chỉ chính chủ
- Reviews: ai cũng đọc; tạo khi đăng nhập; xóa/cập nhật bởi admin hoặc chính tác giả

## Lưu ý
- Sau khi deploy, đăng xuất và đăng nhập lại trong app để đồng bộ vai trò admin.
- Nếu Firestore yêu cầu index cho truy vấn `isAvailable + isApproved + createdAt`, tạo composite index theo link gợi ý trong console.

