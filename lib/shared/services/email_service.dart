import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const _email = 'yi880276@gmail.com';
  static const _appPassword = 'dkknqdosrasmqowv';

  /// 문의 이메일 전송
  static Future<bool> sendInquiry({
    required String senderName,
    required String subject,
    required String body,
    String? senderEmail,
  }) async {
    try {
      final smtpServer = gmail(_email, _appPassword);

      final message = Message()
        ..from = Address(_email, 'SynthTune Music')
        ..recipients.add(_email)
        ..subject = '[앱 문의] $subject'
        ..text = '''
SynthTune Music 문의

보낸 사람: $senderName
이메일: ${senderEmail ?? '미제공'}
시간: ${DateTime.now()}

─────────────────────
$body
─────────────────────

이 메일은 SynthTune Music에서 자동 발송되었습니다.
''';

      await send(message, smtpServer);
      return true;
    } catch (_) {
      return false;
    }
  }
}
