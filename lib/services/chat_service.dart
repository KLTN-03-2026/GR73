import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';

class ChatService {
  static Future<String> ask({required String prompt, List<Map<String, String>> history = const []}) async {
    if (AIConfig.openaiApiKey.isEmpty) {
      return _localReply(prompt);
    }
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final messages = <Map<String, String>>[
      {
        'role': 'system',
        'content': 'Bạn là trợ lý AI hữu ích cho ứng dụng bất động sản. Trả lời bằng tiếng Việt nếu người dùng dùng tiếng Việt, ngược lại dùng tiếng Anh. Có thể trả lời câu hỏi chung.'
      },
      ...history,
      {'role': 'user', 'content': prompt},
    ];
    final body = jsonEncode({
      'model': AIConfig.openaiModel,
      'messages': messages,
      'temperature': 0.7,
    });
    final headers = {
      'Authorization': 'Bearer ${AIConfig.openaiApiKey}',
      'Content-Type': 'application/json',
    };
    final res = await http.post(uri, headers: headers, body: body);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final choices = data['choices'] as List<dynamic>;
      if (choices.isNotEmpty) {
        final msg = choices.first['message'];
        return (msg['content'] as String).trim();
      }
      return _localReply(prompt);
    }
    return _localReply(prompt);
  }

  static String _localReply(String prompt) {
    final lower = prompt.toLowerCase();
    if (lower.contains('help') || lower.contains('hướng dẫn') || lower.contains('có thể làm gì') || lower.contains('help me')) {
      return 'Bạn có thể hỏi: Kiến trúc hệ thống, mô-đun, dữ liệu Firestore, bảo mật/quyền riêng tư, tìm kiếm & lọc, membership/thanh toán, báo cáo vi phạm, doanh thu, bản đồ (OSM/Mapbox), i18n & theme, triển khai/build, kiểm thử/CI, hiệu năng & accessibility.';
    }
    if (lower.contains('giá') || lower.contains('bao nhiêu')) {
      return 'Giá thuê căn hộ thường 3–15 triệu tuỳ khu và diện tích. Bạn muốn khu vực nào?';
    }
    if (lower.contains('hợp đồng') || lower.contains('cọc')) {
      return 'Thường cần đặt cọc 1–2 tháng. Hợp đồng nên có điều khoản rõ ràng và công chứng nếu thuê dài hạn.';
    }
    if (lower.contains('tìm') || lower.contains('thuê') || lower.contains('lọc')) {
      return 'Vào Trang chủ → thanh tìm kiếm và bộ lọc (giá, diện tích, tiện ích). Có thể lưu tìm kiếm và dùng sắp xếp “Mới nhất/giá tăng/giảm”.';
    }
    if (lower.contains('liên hệ') || lower.contains('gọi') || lower.contains('sđt')) {
      return 'Mở chi tiết bài đăng để xem số điện thoại/Email chủ nhà và liên hệ trực tiếp.';
    }
    if (lower.contains('dưới 5') || lower.contains('5 triệu')) {
      return 'Bộ lọc → đặt Giá tối đa = 5,000,000. Bạn có thể kết hợp tiện ích (máy lạnh, hồ bơi) để thu hẹp kết quả.';
    }
    if (lower.contains('hồ bơi')) {
      return 'Trong bộ lọc → bật tiện ích “Hồ bơi”. Khu vực quận 2, 7 thường có nhiều căn có hồ bơi.';
    }
    if (lower.contains('gần trung tâm')) {
      return 'Chọn khu vực Quận 1/3/Bình Thạnh hoặc bán kính mong muốn rồi sắp xếp “Mới nhất”.';
    }
    if (lower.contains('thanh toán') || lower.contains('membership') || lower.contains('nâng cấp')) {
      return 'Vào mục Thành viên để xem gói. Thanh toán có thể được duyệt trong Admin; theo dõi trạng thái ở phần thanh toán.';
    }
    if (lower.contains('báo cáo') || lower.contains('vi phạm')) {
      return 'Trong thẻ bài, dùng nút cờ để báo cáo vi phạm. Admin xem và xử lý tại trang Quản lý báo cáo.';
    }
    if (lower.contains('doanh thu') || lower.contains('revenue')) {
      return 'Trang Báo cáo & Thống kê có mục doanh thu: hôm nay, 7 ngày, 30 ngày; số giao dịch theo trạng thái. Dữ liệu từ payments.';
    }
    if (lower.contains('bản đồ') || lower.contains('map') || lower.contains('google map')) {
      return 'Ứng dụng hỗ trợ bản đồ Google Maps. Mở trang bản đồ từ menu để tìm kiếm quanh đây.';
    }
    if (lower.contains('i18n') || lower.contains('đa ngôn') || lower.contains('language') || lower.contains('việt') || lower.contains('english')) {
      return 'Đa ngôn ngữ vi/en dùng Flutter gen-l10n (app_vi.arb, app_en.arb). Đổi ngôn ngữ ở Cài đặt và trong Hồ sơ.';
    }
    if (lower.contains('theme') || lower.contains('dark') || lower.contains('chế độ tối')) {
      return 'Theme sáng/tối/hệ thống qua ThemeProvider. Chế độ tối đã tăng tương phản cho card/chip/input theo ColorScheme.';
    }
    if (lower.contains('kiến trúc') || lower.contains('architecture') || lower.contains('module')) {
      return 'Kiến trúc: Router; Providers (Auth/Post/Locale/Theme); Services (Firebase/Payment/Chat); Screens user/admin; Widgets; i18n/Theme cấu hình chung.';
    }
    if (lower.contains('cơ sở dữ liệu') || lower.contains('firestore') || lower.contains('collection')) {
      return 'Collection: users, posts, reviews, favorites, payments, recommend_events, reports. Stream + lọc client để tránh index phức hợp.';
    }
    if (lower.contains('bảo mật') || lower.contains('quyền riêng tư') || lower.contains('privacy') || lower.contains('security')) {
      return 'Không lưu khoá vào repo; Firestore Security Rules; hạn chế log PII; phân quyền admin rõ ràng; có báo cáo vi phạm.';
    }
    if (lower.contains('triển khai') || lower.contains('build') || lower.contains('release') || lower.contains('ci')) {
      return 'Build flutter cho android/ios/web. Nếu dùng AI thì truyền OPENAI_API_KEY qua --dart-define hoặc secrets CI. Khuyến nghị thêm workflow CI.';
    }
    if (lower.contains('kiểm thử') || lower.contains('test') || lower.contains('unit')) {
      return 'Nên thêm unit/widget/integration tests cho Providers và các màn chính; dùng flutter_test và mock Firebase.';
    }
    if (lower.contains('hiệu năng') || lower.contains('performance') || lower.contains('tối ưu')) {
      return 'Lazy-load ảnh, hạn chế rebuild với Provider, dùng ColorScheme; cân nhắc phân trang posts và cache.';
    }
    if (lower.contains('accessibility') || lower.contains('khả năng truy cập')) {
      return 'Tương phản tốt, cỡ chữ, hit target lớn, semantic labels cho screen readers.';
    }
    if (lower.contains('chatbot') || lower.contains('ai')) {
      return 'Chatbot có chế độ nội bộ (không cần AI key) và chế độ AI khi truyền OPENAI_API_KEY. Nội bộ trả lời theo FAQ dự án.';
    }
    return 'Mình là trợ lý nội bộ: bạn có thể hỏi về tìm kiếm, lọc, thanh toán, báo cáo, hoặc chức năng app. Cho mình biết cụ thể nhu cầu nhé!';
  }
}
