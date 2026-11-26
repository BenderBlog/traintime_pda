// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypter_plus/encrypter_plus.dart' as crypto;
import 'package:pda_network/pda_network.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:test/test.dart';

void main() {
  test(
    'reuses saved cookies but reports expiration without a password fallback',
    () async {
      final saved = <String, String>{};
      final IdsSessionStore sessionStore = (
        read: (key) async => saved[key],
        write: (key, value) async => saved[key] = value,
        delete: (key) async => saved.remove(key),
      );
      final service = Uri.parse('https://ehall.xidian.edu.cn/home');
      var passwordPosts = 0;
      var sessionValid = false;
      var passwordLoginSawCookie = false;
      final fingerprints = <String>[];
      Dio server() => _dio((options) {
        final uri = options.uri;
        if (uri.path == '/authserver/login' && options.method == 'GET') {
          final cookie =
              options.headers[HttpHeaders.cookieHeader]?.toString() ?? '';
          if (!uri.queryParameters.containsKey('service') &&
              passwordPosts > 0) {
            passwordLoginSawCookie = cookie.contains('TGC=session');
          }
          if (sessionValid && cookie.contains('TGC=session')) {
            return _redirect(options, '${service.toString()}?ticket=ST-1');
          }
          return _ok(options, _passwordForm);
        }
        if (uri.path == '/authserver/bfp/info') {
          fingerprints.add(uri.queryParameters['bfp']!);
          return _ok(options, 'ok');
        }
        if (uri.path == '/authserver/common/openSliderCaptcha.htl') {
          return _ok(options, {
            'bigImage': base64Encode([1]),
            'smallImage': base64Encode(Uint8List(16)),
          });
        }
        if (uri.path == '/authserver/common/verifySliderCaptcha.htl') {
          return _ok(options, {'errorCode': 1});
        }
        if (uri.path == '/authserver/login' && options.method == 'POST') {
          final password =
              (options.data as Map<String, dynamic>)['password'] as String;
          final aes = crypto.AES(
            crypto.Key.fromUtf8('1234567890123456'),
            mode: crypto.AESMode.cbc,
            padding: null,
          );
          final decrypted = crypto.Encrypter(aes).decryptBytes(
            crypto.Encrypted.fromBase64(password),
            iv: crypto.IV.fromUtf8('xidianscriptsxdu'),
          );
          expect(
            utf8.decode(
              decrypted.sublist(0, decrypted.length - decrypted.last),
            ),
            'xidianscriptsxduxidianscriptsxduxidianscriptsxduxidianscriptsxdusecret',
          );
          passwordPosts++;
          sessionValid = true;
          return Response(
            requestOptions: options,
            statusCode: 302,
            headers: Headers.fromMap({
              HttpHeaders.locationHeader: [
                uri.queryParameters.containsKey('service')
                    ? '${service.toString()}?ticket=ST-1'
                    : 'https://ids.xidian.edu.cn/done',
              ],
              HttpHeaders.setCookieHeader: ['TGC=session; Path=/; Secure'],
            }),
          );
        }
        if (uri.host == service.host || uri.path == '/done') {
          return _ok(options, 'ready');
        }
        throw StateError('unexpected request: $uri');
      });
      final interaction = IdsInteraction(
        solveSlider: (_, _, _) async => [(x: 100, y: 0, milliseconds: 10)],
      );

      final events = <String>[];
      final first = IdsRepository(
        sessionStore,
        dioFactory: server,
        onLog: events.add,
      );
      await first.login('alice', 'secret', interaction: interaction);
      expect(events.join('\n'), contains('slider'));
      expect(events.join('\n'), contains('login'));
      expect(events.join('\n'), isNot(contains('secret')));
      first.close();
      expect(passwordPosts, 1);
      expect(saved.keys, contains('ids.session.ids.xidian.edu.cn'));

      final second = IdsRepository(sessionStore, dioFactory: server);
      await second.authorize(service);
      second.close();
      expect(passwordPosts, 1);

      sessionValid = false;
      final third = IdsRepository(sessionStore, dioFactory: server);
      await expectLater(
        third.authorize(service),
        throwsA(isA<IdsSessionExpired>()),
      );
      expect(passwordPosts, 1);
      await third.login('alice', 'secret', interaction: interaction);
      expect(passwordPosts, 2);
      expect(passwordLoginSawCookie, isFalse);
      expect(fingerprints, hasLength(2));
      expect(fingerprints[1], fingerprints[0]);
      await third.clear();
      expect(saved.keys, ['ids.fingerprint']);
      third.close();
    },
  );

  test('manual slider reloads and retries after a rejected attempt', () async {
    var images = 0;
    var checks = 0;
    var prompts = 0;
    final retryFlags = <bool>[];
    final client = IdsRepository(
      _memorySessionStore(),
      dioFactory: () => _dio((options) {
        final path = options.uri.path;
        if (path == '/authserver/login' && options.method == 'GET') {
          return _ok(options, _passwordForm);
        }
        if (path == '/authserver/bfp/info') return _ok(options, 'ok');
        if (path == '/authserver/common/openSliderCaptcha.htl') {
          images++;
          return _ok(options, {
            'bigImage': base64Encode([1]),
            'smallImage': base64Encode(Uint8List(16)),
          });
        }
        if (path == '/authserver/common/verifySliderCaptcha.htl') {
          expect(options.headers['X-Requested-With'], 'XMLHttpRequest');
          expect(options.headers['Origin'], 'https://ids.xidian.edu.cn');
          return _ok(options, {'errorCode': ++checks == 1 ? 0 : 1});
        }
        if (path == '/authserver/login' && options.method == 'POST') {
          return _redirect(options, 'https://ids.xidian.edu.cn/done');
        }
        if (path == '/done') return _ok(options, 'done');
        throw StateError('unexpected: $path');
      }),
    );
    await client.login(
      'alice',
      'secret',
      interaction: IdsInteraction(
        solveSlider: (_, _, retry) async {
          prompts++;
          retryFlags.add(retry);
          return [(x: retry ? -10 : 400, y: 3, milliseconds: 200)];
        },
      ),
    );
    expect(prompts, 2);
    expect(retryFlags, [false, true]);
    expect(images, 7);
    expect(checks, 2);
    client.close();
  });

  test(
    'service authorization rejects invalid service URLs before requesting',
    () async {
      var requests = 0;
      final repository = IdsRepository(
        _memorySessionStore(),
        dioFactory: () => _dio((options) {
          requests++;
          return _ok(options, 'unexpected');
        }),
      );
      for (final service in [
        'https://xidian.edu.cn.evil.test/',
        'http://xidian.edu.cn/',
        'https://user@xidian.edu.cn/',
        'https://xidian.edu.cn:444/',
      ]) {
        await expectLater(
          repository.authorize(Uri.parse(service)),
          throwsFormatException,
        );
      }
      expect(requests, 0);
      repository.close();
    },
  );

  test('IDS client implements the shared network interface', () {
    final IdsNetworkRepository repository = IdsRepository(
      _memorySessionStore(),
    );
    expect(repository, isA<IdsRepository>());
    (repository as IdsRepository).close();
  });
  test(
    'asks for a manual slider only after six automatic challenges',
    () async {
      var challenges = 0;
      var prompts = 0;
      final client = IdsRepository(
        _memorySessionStore(),
        dioFactory: () => _dio((options) {
          if (options.uri.path == '/authserver/login' &&
              options.method == 'GET') {
            return _ok(options, _passwordForm);
          }
          if (options.uri.path == '/authserver/bfp/info') {
            return _ok(options, 'ok');
          }
          if (options.uri.path == '/authserver/common/openSliderCaptcha.htl') {
            challenges++;
            return _ok(options, {
              'bigImage': base64Encode([1]),
              'smallImage': base64Encode(Uint8List(16)),
            });
          }
          if (options.uri.path ==
              '/authserver/common/verifySliderCaptcha.htl') {
            return _ok(options, {'errorCode': 1});
          }
          if (options.uri.path == '/authserver/login' &&
              options.method == 'POST') {
            return _redirect(options, 'https://ids.xidian.edu.cn/done');
          }
          if (options.uri.path == '/done') return _ok(options, 'ready');
          throw StateError('unexpected request: ${options.uri}');
        }),
      );

      await client.login(
        'alice',
        'secret',
        interaction: IdsInteraction(
          solveSlider: (_, _, _) async {
            prompts++;
            expect(challenges, 6);
            return [(x: 100, y: 0, milliseconds: 10)];
          },
        ),
      );

      expect(challenges, 6);
      expect(prompts, 1);
      client.close();
    },
  );
  test('clear removes a saved session before the first request', () async {
    const prefix = 'ids.session';
    final saved = <String, String>{
      '$prefix..index': '["ids.xidian.edu.cn"]',
      '$prefix.ids.xidian.edu.cn': 'saved cookie',
    };
    final IdsSessionStore sessionStore = (
      read: (key) async => saved[key],
      write: (key, value) async => saved[key] = value,
      delete: (key) async => saved.remove(key),
    );
    final client = IdsRepository(sessionStore);

    await client.clear();

    expect(saved, isEmpty);
    client.close();
  });
  test(
    'continues an existing session without submitting the password',
    () async {
      final service = Uri.parse('https://ehall.xidian.edu.cn/home');
      var posts = 0;
      final client = IdsRepository(
        _memorySessionStore(),
        dioFactory: () => _dio((options) {
          if (options.uri.host == service.host) return _ok(options, 'ready');
          if (options.method == 'GET') {
            return _ok(
              options,
              '<form id="continue"><input name="execution" value="e1"></form>',
            );
          }
          posts++;
          expect(options.data, {'execution': 'e1'});
          return _redirect(options, '${service.toString()}?ticket=ST-1');
        }),
      );

      await client.authorize(service);

      expect(posts, 1);
      client.close();
    },
  );
  test('login form after a redirect is not an authenticated session', () async {
    final client = IdsRepository(
      _memorySessionStore(),
      dioFactory: () => _dio((options) {
        if (options.uri.path == '/authserver/login' &&
            !options.uri.queryParameters.containsKey('retry')) {
          return _redirect(
            options,
            'https://ids.xidian.edu.cn/authserver/login?retry=1',
          );
        }
        return _ok(options, _passwordForm);
      }),
    );

    await expectLater(
      client.login('alice', 'wrong'),
      throwsA(isA<IdsLoginException>()),
    );
    client.close();
  });

  test(
    'service tickets preserve a requested path, query and fragment',
    () async {
      final service = Uri.parse(
        'https://yjspt.xidian.edu.cn/index.do?term=1#/xskcb',
      );
      final destination = service.replace(
        queryParameters: {'term': '1', 'ticket': 'ST-1'},
      );
      final requested = <Uri>[];
      final repository = IdsRepository(
        _memorySessionStore(),
        dioFactory: () => _dio((options) {
          requested.add(options.uri);
          if (options.uri.host == 'ids.xidian.edu.cn') {
            expect(options.uri.queryParameters['service'], service.toString());
            return _redirect(options, destination.toString());
          }
          return _ok(options, 'ready');
        }),
      );
      await repository.authorize(service);
      expect(requested.last, destination);
      repository.close();
    },
  );

  test('service redirects remain valid after its ticket is consumed', () async {
    final service = Uri.parse('https://ehall.xidian.edu.cn/home');
    final client = IdsRepository(
      _memorySessionStore(),
      dioFactory: () => _dio((options) {
        if (options.uri.host == 'ids.xidian.edu.cn') {
          return _redirect(options, '${service.toString()}?ticket=ST-1');
        }
        if (options.uri.path == '/home') {
          return _redirect(options, 'https://ehall.xidian.edu.cn/dashboard');
        }
        return _ok(options, 'ready');
      }),
    );

    await client.authorize(service);
    client.close();
  });

  test(
    'network outage is reported separately from session expiration',
    () async {
      final client = IdsRepository(
        _memorySessionStore(),
        dioFactory: () => _dio(
          (options) => Response(requestOptions: options, statusCode: 503),
        ),
      );

      await expectLater(
        client.authorize(Uri.parse('https://ehall.xidian.edu.cn/')),
        throwsA(isA<IdsServiceUnavailable>()),
      );
      client.close();
    },
  );

  test(
    'rejects redirect to a lookalike host before sending a request',
    () async {
      final requested = <Uri>[];
      final client = IdsRepository(
        _memorySessionStore(),
        dioFactory: () => _dio((options) {
          requested.add(options.uri);
          return _redirect(options, 'https://xidian.edu.cn.evil.test/ticket');
        }),
      );

      await expectLater(client.login('alice', 'secret'), throwsFormatException);
      expect(requested, hasLength(1));
      client.close();
    },
  );

  test(
    'independent service authorizations can make requests concurrently',
    () async {
      final firstStarted = Completer<void>();
      final secondStarted = Completer<void>();
      final release = Completer<void>();
      final client = IdsRepository(
        _memorySessionStore(),
        dioFactory: () => _dio((options) async {
          if (options.uri.host == 'ehall.xidian.edu.cn') {
            return _ok(options, 'ready');
          }
          final target = Uri.parse(options.uri.queryParameters['service']!);
          if (target.path == '/a') {
            firstStarted.complete();
            await release.future;
          } else {
            secondStarted.complete();
          }
          return _redirect(options, '$target?ticket=ST-1');
        }),
      );
      final first = client.authorize(
        Uri.parse('https://ehall.xidian.edu.cn/a'),
      );
      await firstStarted.future;
      final second = client.authorize(
        Uri.parse('https://ehall.xidian.edu.cn/b'),
      );
      try {
        await secondStarted.future.timeout(const Duration(milliseconds: 300));
      } finally {
        release.complete();
        await Future.wait([first, second]);
        client.close();
      }
    },
  );

  test('concurrent first requests share a client', () async {
    var clients = 0;
    final repository = IdsRepository(
      _memorySessionStore(),
      dioFactory: () {
        clients++;
        return _dio((options) => _ok(options, _passwordForm));
      },
    );
    final first = repository.authorize(
      Uri.parse('https://ehall.xidian.edu.cn/a'),
    );
    final second = repository.authorize(
      Uri.parse('https://ehall.xidian.edu.cn/b'),
    );
    await Future.wait([
      expectLater(first, throwsA(isA<IdsSessionExpired>())),
      expectLater(second, throwsA(isA<IdsSessionExpired>())),
    ]);
    expect(clients, 1);
    repository.close();
  });

  test('clear cancels a login before its queued work starts', () async {
    var requests = 0;
    final client = IdsRepository(
      _memorySessionStore(),
      dioFactory: () => _dio((options) {
        requests++;
        return _ok(options, _passwordForm);
      }),
    );

    final login = client.login('alice', 'secret');
    final failure = expectLater(login, throwsA(isA<Object>()));
    await client.clear();
    await failure;
    expect(requests, 0);
    client.close();
  });

  test('clear waits for an ongoing cookie write and removes it', () async {
    final saved = <String, String>{};
    final writeStarted = Completer<void>();
    final releaseWrite = Completer<void>();
    var blocked = false;
    final IdsSessionStore store = (
      read: (key) async => saved[key],
      write: (key, value) async {
        if (!blocked && key.startsWith('ids.session.')) {
          blocked = true;
          writeStarted.complete();
          await releaseWrite.future;
        }
        saved[key] = value;
      },
      delete: (key) async => saved.remove(key),
    );
    final client = IdsRepository(
      store,
      dioFactory: () => _dio(
        (options) => Response(
          requestOptions: options,
          statusCode: 200,
          data: 'ok',
          headers: Headers.fromMap({
            HttpHeaders.setCookieHeader: ['TGC=old; Path=/; Secure'],
          }),
        ),
      ),
    );
    final dio = await client.session.createClient();
    final request = dio.getUri<void>(Uri.parse('https://ids.xidian.edu.cn/'));
    final finishedRequest = request.then<void>((_) {}, onError: (Object _) {});
    await writeStarted.future;
    var cleared = false;
    final clear = client.clear().then((_) => cleared = true);
    var created = false;
    final newClient = Future.sync(client.session.createClient).then((value) {
      created = true;
      return value;
    });
    await Future<void>.delayed(Duration.zero);
    expect(cleared, isFalse);
    expect(created, isFalse);
    releaseWrite.complete();
    await clear;
    await newClient;
    await finishedRequest;
    expect(saved.keys.where((key) => key.startsWith('ids.session.')), isEmpty);
    client.close();
  });

  test('failed cookie cleanup blocks clients until cleanup succeeds', () async {
    final saved = <String, String>{};
    var failDelete = false;
    final IdsSessionStore store = (
      read: (key) async => saved[key],
      write: (key, value) async => saved[key] = value,
      delete: (key) async {
        if (failDelete) throw StateError('delete failed');
        saved.remove(key);
      },
    );
    final client = IdsRepository(
      store,
      dioFactory: () => _dio(
        (options) => Response(
          requestOptions: options,
          statusCode: 200,
          data: 'ok',
          headers: Headers.fromMap({
            HttpHeaders.setCookieHeader: ['TGC=old; Path=/; Secure'],
          }),
        ),
      ),
    );
    final dio = await client.session.createClient();
    await dio.getUri<void>(Uri.parse('https://ids.xidian.edu.cn/'));
    failDelete = true;
    await expectLater(client.clear(), throwsStateError);
    await expectLater(client.session.createClient(), throwsStateError);
    failDelete = false;
    await client.clear();
    expect(saved.keys.where((key) => key.startsWith('ids.session.')), isEmpty);
    await client.session.createClient();
    client.close();
  });

  test('clear isolates a late response from the next login', () async {
    final oldResponse = Completer<Response<dynamic>>();
    final requestStarted = Completer<void>();
    final saved = <String, String>{};
    final IdsSessionStore sessionStore = (
      read: (key) async => saved[key],
      write: (key, value) async => saved[key] = value,
      delete: (key) async => saved.remove(key),
    );
    var requests = 0;
    final client = IdsRepository(
      sessionStore,
      dioFactory: () => _dio((options) async {
        if (requests++ == 0) {
          requestStarted.complete();
          return oldResponse.future;
        }
        return _redirect(options, 'https://ids.xidian.edu.cn/success');
      }),
    );

    final first = client.login('alice', 'secret');
    await requestStarted.future;
    await client.clear();
    final second = client.login('bob', 'other');
    await expectLater(second, throwsFormatException);
    oldResponse.complete(
      Response(
        requestOptions: RequestOptions(
          path: 'https://ids.xidian.edu.cn/authserver/login',
        ),
        statusCode: 302,
        headers: Headers.fromMap({
          'location': ['https://ids.xidian.edu.cn/old'],
          HttpHeaders.setCookieHeader: ['TGC=old; Path=/; Secure'],
        }),
      ),
    );
    await expectLater(first, throwsA(isA<Object>()));
    expect(saved.keys.where((key) => !key.endsWith('.fingerprint')), isEmpty);
    client.close();
  });

  test('asks the user before sending a second-factor code', () async {
    final events = <String>[];
    var loginPageRequests = 0;
    var submitAttempts = 0;
    final client = IdsRepository(
      _memorySessionStore(),
      dioFactory: () => _dio((options) {
        final uri = options.uri;
        if (uri.path == '/authserver/login' && options.method == 'GET') {
          loginPageRequests++;
          if (loginPageRequests == 1) {
            return _ok(
              options,
              '<form id="pwdFromId">'
              '<input type="hidden" name="pwdEncryptSalt" value="1234567890123456">'
              '<input type="hidden" name="lt" value="">'
              '<input type="hidden" name="execution" value="e1"></form>',
            );
          }
          return _redirect(options, 'https://ids.xidian.edu.cn/done');
        }
        if (uri.path == '/authserver/bfp/info') return _ok(options, 'ok');
        if (uri.path == '/authserver/common/openSliderCaptcha.htl') {
          return _ok(options, {
            'bigImage': base64Encode([1, 2]),
            'smallImage': base64Encode(Uint8List(16)),
          });
        }
        if (uri.path == '/authserver/common/verifySliderCaptcha.htl') {
          return _ok(options, {'errorCode': 1});
        }
        if (uri.path == '/authserver/login' && options.method == 'POST') {
          return _redirect(
            options,
            'https://ids.xidian.edu.cn/authserver/reAuthCheck/reAuthLoginView.do',
          );
        }
        if (uri.path == '/authserver/reAuthCheck/reAuthLoginView.do') {
          return _ok(options, '"reAuthUserId":"alice"');
        }
        if (uri.path.endsWith('changeReAuthType.do')) {
          return _ok(options, {'code': 1});
        }
        if (uri.path.endsWith('getDynamicCodeByReauth.do')) {
          events.add('sent');
          return _ok(options, {'res': 'success', 'mobile': '12345678901'});
        }
        if (uri.path.endsWith('reAuthSubmit.do')) {
          expect((options.data as Map<String, dynamic>)['reAuthType'], '4');
          events.add('submitted');
          submitAttempts++;
          return _ok(options, {
            'code': submitAttempts == 1 ? 'reAuth_failed' : 'reAuth_success',
          });
        }
        if (uri.path == '/done') return _ok(options, 'done');
        throw StateError('unexpected request path: ${uri.path}');
      }),
    );

    await client.login(
      'alice',
      'secret',
      interaction: IdsInteraction(
        solveSlider: (_, _, _) async => [(x: 100, y: 0, milliseconds: 10)],
        enterCode: (delivery) async {
          events.add('prompted');
          expect(delivery.codeRejected, submitAttempts == 1);
          if (submitAttempts == 0) {
            final changed = await delivery.sendCode!(
              IdsCodeType.enterpriseWechat,
            );
            expect(changed.codeType, IdsCodeType.enterpriseWechat);
            expect(changed.maskedRecipient, '123****8901');
          }
          return (code: '123456', trustDevice: false);
        },
      ),
    );

    expect(events, ['prompted', 'sent', 'submitted', 'prompted', 'submitted']);
    client.close();
  });

  test('service ticket stores cookies in the package shared session', () async {
    final service = Uri.parse('https://ehall.xidian.edu.cn/home');
    final requested = <Uri>[];
    final client = IdsRepository(
      _memorySessionStore(),
      dioFactory: () => _dio((options) {
        requested.add(options.uri);
        if (options.uri.path == '/authserver/login' &&
            options.method == 'GET') {
          return options.uri.queryParameters['service'] == service.toString()
              ? _redirect(options, '${service.toString()}?ticket=ST-1')
              : _ok(options, _passwordForm);
        }
        if (options.uri.path == '/authserver/bfp/info') {
          return _ok(options, 'ok');
        }
        if (options.uri.path == '/authserver/common/openSliderCaptcha.htl') {
          return _ok(options, {
            'bigImage': base64Encode([1]),
            'smallImage': base64Encode(Uint8List(16)),
          });
        }
        if (options.uri.path == '/authserver/common/verifySliderCaptcha.htl') {
          return _ok(options, {'errorCode': 1});
        }
        if (options.uri.path == '/authserver/login' &&
            options.method == 'POST') {
          expect(options.contentType, Headers.formUrlEncodedContentType);
          expect((options.data as Map)['username'], 'alice');
          expect((options.data as Map)['password'], isNot('secret'));
          return _redirect(options, 'https://ids.xidian.edu.cn/done');
        }
        if (options.uri.path == '/done') return _ok(options, 'logged in');
        if (options.uri.host == service.host && options.uri.path == '/home') {
          return Response(
            requestOptions: options,
            statusCode: 200,
            data: 'service ready',
            headers: Headers.fromMap({
              HttpHeaders.setCookieHeader: ['SERVICE=ready; Path=/; Secure'],
            }),
          );
        }
        if (options.uri.host == service.host &&
            options.uri.path == '/resource') {
          expect(
            options.headers[HttpHeaders.cookieHeader]?.toString(),
            contains('SERVICE=ready'),
          );
          return _ok(options, 'resource');
        }
        throw StateError('unexpected path: ${options.uri.path}');
      }),
    );

    await client.login(
      'alice',
      'secret',
      interaction: IdsInteraction(
        solveSlider: (_, _, _) async => [(x: 100, y: 0, milliseconds: 10)],
      ),
    );
    await client.authorize(service);
    final sharedClient = await client.session.createClient();
    await sharedClient.getUri<void>(
      Uri.parse('https://ehall.xidian.edu.cn/resource'),
    );

    expect(requested.where((uri) => uri.host == service.host), hasLength(2));
    client.close();
  });

  test('password rejection does not report an authenticated session', () async {
    final client = IdsRepository(
      _memorySessionStore(),
      dioFactory: () => _dio((options) {
        if (options.uri.path == '/authserver/login' &&
            options.method == 'GET') {
          return _ok(options, _passwordForm);
        }
        if (options.uri.path == '/authserver/bfp/info') {
          return _ok(options, 'ok');
        }
        if (options.uri.path == '/authserver/common/openSliderCaptcha.htl') {
          return _ok(options, {
            'bigImage': base64Encode([1]),
            'smallImage': base64Encode(Uint8List(16)),
          });
        }
        if (options.uri.path == '/authserver/common/verifySliderCaptcha.htl') {
          return _ok(options, {'errorCode': 1});
        }
        return Response(
          requestOptions: options,
          statusCode: 401,
          data: '<div id="showErrorTip">用户名或密码有误</div>',
        );
      }),
    );

    await expectLater(
      client.login(
        'alice',
        'wrong',
        interaction: IdsInteraction(
          solveSlider: (_, _, _) async => [(x: 100, y: 0, milliseconds: 10)],
        ),
      ),
      throwsA(isA<IdsCredentialsRejected>()),
    );
    client.close();
  });
}

IdsSessionStore _memorySessionStore() {
  final saved = <String, String>{};
  return (
    read: (key) async => saved[key],
    write: (key, value) async => saved[key] = value,
    delete: (key) async => saved.remove(key),
  );
}

const _passwordForm =
    '<form id="pwdFromId">'
    '<input type="hidden" name="pwdEncryptSalt" value="1234567890123456">'
    '<input type="hidden" name="lt" value="">'
    '<input type="hidden" name="execution" value="e1"></form>';

Dio _dio(FutureOr<Response<dynamic>> Function(RequestOptions) respond) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        handler.resolve(await respond(options), true);
      },
    ),
  );
  return dio;
}

Response<dynamic> _redirect(RequestOptions options, String location) =>
    Response(
      requestOptions: options,
      statusCode: 302,
      headers: Headers.fromMap({
        'location': [location],
      }),
    );

Response<dynamic> _ok(RequestOptions options, Object data) =>
    Response(requestOptions: options, statusCode: 200, data: data);
