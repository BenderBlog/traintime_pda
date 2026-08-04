import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/repository/xidian_ids/ids_session.dart';

void main() {
  test('password encryption matches the Go ids login payload', () {
    expect(
      IDSSession.aesEncrypt('secret', '1234567890abcdef'),
      'Y2fkMlmY/KyUHnWiA9lVrnC8HHWUFePOo/JLpbpV/XfZ/zE6Tk2WrZMyCYY1f9ael+nb8OZB4B2EmFM6G18SWNpKTmuSEP0PjuxgVXBdI90=',
    );
  });

  test('username login payload matches Go ids fields', () {
    final payload = IDSSession.buildUsernameLoginPayloadForTesting(
      username: '2200000000',
      password: 'secret',
      salt: '1234567890abcdef',
      execution: 'exec-token',
    );

    expect(payload, {
      'username': '2200000000',
      'password':
          'Y2fkMlmY/KyUHnWiA9lVrnC8HHWUFePOo/JLpbpV/XfZ/zE6Tk2WrZMyCYY1f9ael+nb8OZB4B2EmFM6G18SWNpKTmuSEP0PjuxgVXBdI90=',
      'rememberMe': 'true',
      'cllt': 'userNameLogin',
      'dllt': 'generalLogin',
      '_eventId': 'submit',
      'captcha': '',
      'lt': '',
      'execution': 'exec-token',
    });
  });
}
