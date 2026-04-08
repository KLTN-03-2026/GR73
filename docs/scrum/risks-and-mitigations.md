# Risks & Mitigations

- Firebase Security Rules chưa chặt → Viết Rules, kiểm thử truy cập.
- Lộ secrets (AI key) → chỉ dùng `--dart-define`, secrets trong CI; không commit.
- Map provider thay đổi API → bọc qua service, cho phép switch OSM/Mapbox.
- Hiệu năng trên thiết bị thấp → lazy-load ảnh, cache, phân trang.
- Thiếu test → bổ sung test tối thiểu cho providers và screens chính.
- UI dark mode kém tương phản → dùng ColorScheme, kiểm tra thủ công.
