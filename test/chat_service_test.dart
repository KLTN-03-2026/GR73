import 'package:flutter_test/flutter_test.dart';
import 'package:App_WRStudios/services/chat_service.dart';

void main() {
  group('ChatService local fallback', () {
    test('answers price question without OpenAI', () async {
      final reply = await ChatService.ask(prompt: 'Giá thuê bao nhiêu?');
      expect(reply.toLowerCase(), contains('giá thuê')); 
    });

    test('answers report violation', () async {
      final reply = await ChatService.ask(prompt: 'Báo cáo vi phạm bài viết như thế nào?');
      expect(reply.toLowerCase(), contains('báo cáo')); 
    });
  });
}
