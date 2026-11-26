// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pda_repository/pda_repository.dart';
import 'package:flutter/material.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
import 'package:watermeter/core/secure_storage/secure_store_interface.dart';
import 'package:watermeter/features/ids/ids.case.dart';
import 'package:watermeter/features/ids/ids_credentials.model.dart';
import 'package:watermeter/features/ids/ids_credentials.store.dart';
import 'package:watermeter/features/ids/widgets/ids_gate.widget.dart';
import 'package:watermeter/features/ids/widgets/ids_interaction.widget.dart';
import 'package:watermeter/features/ids/widgets/ids_logout_tile.widget.dart';
import 'package:watermeter/features/ids/widgets/ids_reauth.widget.dart';
import 'package:watermeter/features/ids/ids_snapshot.model.dart';
import 'package:watermeter/generated/translations.g.dart';

Widget _withMaterialUiLocalizations(BuildContext context, Widget? child) =>
    Localizations.override(
      context: context,
      delegates: [material_ui.DefaultMaterialLocalizations.delegate],
      child: child!,
    );

void main() {
  testWidgets('verification dialog scrolls above the keyboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(viewInsets: const EdgeInsets.only(bottom: 300)),
            child: _withMaterialUiLocalizations(context, child),
          ),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => showIdsReauthDialog(
                context,
                const IdsCodeDelivery(null, null, Duration.zero),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byType(material_ui.CheckboxListTile));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(material_ui.CheckboxListTile)).bottom,
      lessThanOrEqualTo(400),
    );
  });

  testWidgets('shows progress while saved credentials are loading', (
    tester,
  ) async {
    final secure = _MemorySecureStore()..readWait = Completer<void>();
    final feature = IdsUseCase(SecureIdsCredentialsStore(secure), _Network());
    final restore = feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: _loginPage(feature, 'home')),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    secure.readWait!.complete();
    await restore;
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    feature.dispose();
  });

  testWidgets('narrow login scroll area fills space and avoids the keyboard', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final feature = IdsUseCase(_credentialsStore(), _Network());
    await feature.restore();

    Widget page(double keyboardHeight) => TranslationProvider(
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(viewInsets: EdgeInsets.only(bottom: keyboardHeight)),
          child: child!,
        ),
        home: _loginPage(feature, 'home'),
      ),
    );

    await tester.pumpWidget(page(0));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.getSize(find.byType(SingleChildScrollView)).height, 644);

    await tester.pumpWidget(page(300));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(SingleChildScrollView)).bottom,
      lessThanOrEqualTo(400),
    );
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(FilledButton)).bottom,
      lessThanOrEqualTo(400),
    );
    feature.dispose();
  });

  testWidgets('IDS login labels follow the selected Slang locale', (
    tester,
  ) async {
    final original = LocaleSettings.currentLocale;
    addTearDown(() => LocaleSettings.setLocaleSync(original));
    LocaleSettings.setLocaleSync(AppLocale.en);
    final feature = IdsUseCase(_credentialsStore(), _Network());
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: _loginPage(feature, 'home')),
      ),
    );

    expect(find.text('Student or staff ID'), findsOneWidget);
    await LocaleSettings.setLocale(AppLocale.zhTw);
    await tester.pumpAndSettle();
    expect(find.text('學號或工號'), findsOneWidget);
    feature.dispose();
  });

  testWidgets('local second-factor prompt uses the selected language', (
    tester,
  ) async {
    final original = LocaleSettings.currentLocale;
    addTearDown(() => LocaleSettings.setLocaleSync(original));
    LocaleSettings.setLocaleSync(AppLocale.en);
    final network = _Network()
      ..onLogin = (interaction) async {
        await interaction.enterCode!(
          const IdsCodeDelivery(null, null, Duration.zero, codeRejected: true),
        );
      };
    final feature = IdsUseCase(_credentialsStore(), network);
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          builder: _withMaterialUiLocalizations,
          home: _loginPage(feature, 'home'),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'alice');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Incorrect code. Try again.'), findsOneWidget);
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Enter the verification code'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    feature.dispose();
  });

  testWidgets('concurrent verification prompts appear one at a time', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final network = _Network()
      ..onAuthorize = (interaction) async {
        await interaction.enterCode!(
          const IdsCodeDelivery(null, null, Duration.zero),
        );
      };
    final feature = IdsUseCase(_credentialsStore(), network);
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          builder: _withMaterialUiLocalizations,
          home: IdsInteractionHost(feature: feature, child: const Text('home')),
        ),
      ),
    );
    final first = feature.authorizeService(
      Uri.parse('https://ehall.xidian.edu.cn/a'),
    );
    final second = feature.authorizeService(
      Uri.parse('https://ehall.xidian.edu.cn/b'),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Two-step verification', skipOffstage: false),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(
      find.text('Two-step verification', skipOffstage: false),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await Future.wait([first, second]);
    feature.dispose();
  });

  testWidgets('verification sends a code only after the user requests it', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    var sends = 0;
    final network = _Network()
      ..onAuthorize = (interaction) async {
        await interaction.enterCode!(
          IdsCodeDelivery(
            null,
            null,
            Duration.zero,
            sent: false,
            sendCode: (type) async {
              sends++;
              return IdsCodeDelivery(null, null, Duration.zero, codeType: type);
            },
          ),
        );
      };
    final feature = IdsUseCase(_credentialsStore(), network);
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          builder: _withMaterialUiLocalizations,
          home: _authenticatedPage(feature, 'home'),
        ),
      ),
    );
    final pending = feature.authorizeService(
      Uri.parse('https://ehall.xidian.edu.cn/'),
    );
    await tester.pumpAndSettle();
    expect(sends, 0);
    expect(find.text('Verification code sent'), findsNothing);
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(sends, 1);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await pending;
    feature.dispose();
  });

  testWidgets('service recovery opens second-factor UI and resumes', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    IdsCodeType? resentType;
    IdsCodeSubmission? submittedCode;
    final network = _Network()
      ..onAuthorize = (interaction) async {
        submittedCode = await interaction.enterCode!(
          IdsCodeDelivery(
            null,
            null,
            Duration.zero,
            sendCode: (type) async {
              resentType = type;
              return IdsCodeDelivery(null, null, Duration.zero, codeType: type);
            },
          ),
        );
      };
    final feature = IdsUseCase(store, network);
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          builder: _withMaterialUiLocalizations,
          home: _authenticatedPage(feature, 'home'),
        ),
      ),
    );

    final pending = feature.authorizeService(
      Uri.parse('https://ehall.xidian.edu.cn/'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(IdsGate), findsNothing);
    expect(find.text('Two-step verification'), findsOneWidget);
    expect(find.text('Verification code sent'), findsOneWidget);
    await tester.tap(
      find.byType(material_ui.DropdownButtonFormField<IdsCodeType>),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('WeCom code').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(material_ui.TextField).last, '123456');
    await tester.tap(find.text('Trust this device'));
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    await pending;
    expect(resentType, IdsCodeType.enterpriseWechat);
    expect(submittedCode, (code: '123456', trustDevice: true));
    expect(find.text('home'), findsOneWidget);
    expect(feature.snapshot.status, IdsStatus.ready);
    feature.dispose();
  });

  testWidgets('service failure keeps the authenticated page visible', (
    tester,
  ) async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    final network = _Network()
      ..authorizationError = const IdsServiceUnavailable('offline');
    final feature = IdsUseCase(store, network);
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          builder: _withMaterialUiLocalizations,
          home: _loginPage(feature, 'home'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    await expectLater(
      feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/')),
      throwsA(isA<IdsServiceUnavailable>()),
    );
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    feature.dispose();
  });

  testWidgets('logout failure is shown and can be retried', (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final network = _Network()..clearError = StateError('delete failed');
    final feature = IdsUseCase(_credentialsStore(), network);
    await tester.pumpWidget(
      TranslationProvider(
        child: material_ui.MaterialApp(
          home: material_ui.Scaffold(
            body: Builder(
              builder: (context) => idsLogoutTile(context, feature),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Could not sign out. Please try again.'), findsOneWidget);
    expect(find.text('Logout confirmation'), findsOneWidget);
    network.clearError = null;
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('Logout confirmation'), findsNothing);
    feature.dispose();
  });

  testWidgets('logout failure keeps the authenticated page visible', (
    tester,
  ) async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    final network = _Network()..clearError = StateError('clear failed');
    final feature = IdsUseCase(store, network);
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: _loginPage(feature, 'home')),
      ),
    );
    expect(find.text('home'), findsOneWidget);
    await expectLater(feature.signOut(), throwsStateError);
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    feature.dispose();
  });

  testWidgets('saved account starts on the authenticated route', (
    tester,
  ) async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    final feature = IdsUseCase(store, _Network());
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: _authenticatedPage(feature, 'home')),
      ),
    );

    expect(find.text('home'), findsOneWidget);
    expect(find.byType(IdsGate), findsNothing);
    feature.dispose();
  });

  testWidgets('late sign-in cannot reopen the authenticated route', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final pendingLogin = Completer<void>();
    final network = _Network()..onLogin = (_) => pendingLogin.future;
    final feature = IdsUseCase(_credentialsStore(), network);
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: _loginPage(feature, 'home')),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'alice');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    await feature.signOut();
    pendingLogin.complete();
    await tester.pumpAndSettle();

    expect(find.byType(IdsGate), findsOneWidget);
    expect(find.text('home'), findsNothing);
    feature.dispose();
  });

  testWidgets('login distinguishes rejected credentials from network failure', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final network = _Network()
      ..error = const IdsCredentialsRejected('secret server details');
    final feature = IdsUseCase(_credentialsStore(), network);
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: _loginPage(feature, 'home')),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'alice');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrect account or password.'), findsOneWidget);
    expect(find.textContaining('secret server details'), findsNothing);
    network.error = const IdsServiceUnavailable('offline');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Network unavailable. Try again.'), findsOneWidget);
    feature.dispose();
  });

  testWidgets('login screen hides low-level errors and opens on success', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.zh);
    final network = _Network()..error = StateError('secret-token-123');
    final feature = IdsUseCase(_credentialsStore(), network);
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: _loginPage(feature, 'account home')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('学号或工号'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'alice');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();
    expect(find.textContaining('secret-token-123'), findsNothing);
    expect(find.textContaining('登录失败'), findsOneWidget);

    network.error = null;
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();
    expect(find.text('account home'), findsOneWidget);
    expect(find.byType(IdsGate), findsOneWidget);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator).first).canPop(),
      isFalse,
    );
    await feature.signOut();
    await tester.pumpAndSettle();
    expect(find.byType(IdsGate), findsOneWidget);
    expect(find.text('学号或工号'), findsOneWidget);
    expect(find.text('account home'), findsNothing);
    feature.dispose();
  });

  test(
    'restore exposes saved account without claiming a live session',
    () async {
      final store = _credentialsStore();
      await store.write(IdsCredentials('alice', 'secret'));
      final feature = IdsUseCase(store, _Network());

      await feature.restore();

      expect(feature.snapshot.status, IdsStatus.credentialsAvailable);
      expect(feature.snapshot.username, 'alice');
      feature.dispose();
    },
  );

  test('login saves credentials only after the server accepts them', () async {
    final store = _credentialsStore();
    final network = _Network()..error = StateError('password rejected');
    final feature = IdsUseCase(store, network);

    await expectLater(
      feature.signIn(IdsCredentials('alice', 'secret')),
      throwsStateError,
    );
    expect(await store.read(), isNull);
    expect(feature.snapshot.status, IdsStatus.error);

    network.error = null;
    await feature.signIn(IdsCredentials('alice', 'secret'));
    expect((await store.read())?.username, 'alice');
    expect(feature.snapshot.status, IdsStatus.ready);
    feature.dispose();
  });

  test(
    'logout prevents late service authorization from restoring the account',
    () async {
      final store = _credentialsStore();
      await store.write(IdsCredentials('alice', 'secret'));
      final network = _Network();
      final feature = IdsUseCase(store, network);
      await feature.restore();
      network.authorization = Completer<void>();

      final pending = feature.authorizeService(
        Uri.parse('https://ehall.xidian.edu.cn/'),
      );
      await Future<void>.delayed(Duration.zero);
      await feature.signOut();
      network.authorization!.complete();
      await pending;

      expect(feature.snapshot.status, IdsStatus.signedOut);
      expect(feature.snapshot.username, isNull);
      expect(await store.read(), isNull);
      expect(network.resets, 1);
      feature.dispose();
    },
  );

  test('service recovery stays quiet until automatic login fails', () async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    final network = _Network()
      ..authorization = Completer<void>()
      ..authorizationError = const IdsServiceUnavailable('login failed');
    final feature = IdsUseCase(store, network);
    await feature.restore();
    final statuses = <IdsStatus>[];
    final unsubscribe = feature.state.subscribe(
      (snapshot) => statuses.add(snapshot.status),
    );

    final pending = feature.authorizeService(
      Uri.parse('https://ehall.xidian.edu.cn/home'),
    );
    final failed = expectLater(pending, throwsA(isA<IdsServiceUnavailable>()));
    await Future<void>.delayed(Duration.zero);
    final beforeFailure = List<IdsStatus>.of(statuses);
    network.authorization!.complete();
    await failed;

    expect(beforeFailure, [IdsStatus.credentialsAvailable]);
    expect(statuses, [IdsStatus.credentialsAvailable]);
    expect((await store.read())?.username, 'alice');
    unsubscribe();
    feature.dispose();
  });

  test(
    'successful service authorization does not notify unchanged session',
    () async {
      final feature = IdsUseCase(_credentialsStore(), _Network());
      await feature.signIn(IdsCredentials('alice', 'secret'));
      final statuses = <IdsStatus>[];
      final unsubscribe = feature.state.subscribe(
        (value) => statuses.add(value.status),
      );
      await feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/'));
      expect(statuses, [IdsStatus.ready]);
      unsubscribe();
      feature.dispose();
    },
  );

  test('service uses saved session before reading the password', () async {
    final secure = _MemorySecureStore();
    final store = SecureIdsCredentialsStore(secure);
    await store.write(IdsCredentials('alice', 'secret'));
    final network = _Network();
    final feature = IdsUseCase(store, network);
    await feature.restore();
    final readsAfterRestore = secure.reads;

    await feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/'));

    expect(secure.reads, readsAfterRestore);
    expect(network.logins, isEmpty);
    expect(network.authorizeCalls, 1);
    feature.dispose();
  });

  test('expired session triggers one password login and one retry', () async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    final network = _Network()..expiredAuthorizations = 1;
    final feature = IdsUseCase(store, network);
    await feature.restore();

    await feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/'));

    expect(network.authorizeCalls, 2);
    expect(network.logins, [('alice', 'secret')]);
    expect(feature.snapshot.status, IdsStatus.ready);
    feature.dispose();
  });

  test('sign in waits for an in-flight service authorization', () async {
    final authorization = Completer<void>();
    final network = _Network()..authorization = authorization;
    final feature = IdsUseCase(_credentialsStore(), network);
    final pending = feature.authorizeService(
      Uri.parse('https://ehall.xidian.edu.cn/'),
    );
    await Future<void>.delayed(Duration.zero);
    final login = feature.signIn(IdsCredentials('alice', 'secret'));
    await Future<void>.delayed(Duration.zero);
    expect(network.logins, isEmpty);
    authorization.complete();
    await Future.wait([pending, login]);
    expect(network.logins, [('alice', 'secret')]);
    feature.dispose();
  });

  test('a later sign in waits for the previous login to finish', () async {
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    final network = _Network()
      ..onLogin = (_) async {
        if (!firstStarted.isCompleted) {
          firstStarted.complete();
          await releaseFirst.future;
        }
      };
    final store = _credentialsStore();
    final feature = IdsUseCase(store, network);
    final first = feature.signIn(IdsCredentials('alice', 'secret'));
    await firstStarted.future;
    final second = feature.signIn(IdsCredentials('bob', 'other'));
    await Future<void>.delayed(Duration.zero);
    expect(network.logins, [('alice', 'secret')]);
    releaseFirst.complete();
    await Future.wait([first, second]);
    expect((await store.read())?.username, 'bob');
    expect(feature.snapshot.username, 'bob');
    feature.dispose();
  });

  test('service authorization waits for an active sign in', () async {
    final loginStarted = Completer<void>();
    final finishLogin = Completer<void>();
    final network = _Network()
      ..onLogin = (_) async {
        loginStarted.complete();
        await finishLogin.future;
      };
    final feature = IdsUseCase(_credentialsStore(), network);
    final login = feature.signIn(IdsCredentials('alice', 'secret'));
    await loginStarted.future;
    final authorization = feature.authorizeService(
      Uri.parse('https://ehall.xidian.edu.cn/'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(network.authorizeCalls, 0);
    finishLogin.complete();
    await Future.wait([login, authorization]);
    expect(network.authorizeCalls, 1);
    feature.dispose();
  });

  test('service authorization waits for logout cleanup', () async {
    final network = _Network()..clearWait = Completer<void>();
    final feature = IdsUseCase(_credentialsStore(), network);
    final logout = feature.signOut();
    final authorization = feature.authorizeService(
      Uri.parse('https://ehall.xidian.edu.cn/'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(network.authorizeCalls, 0);
    network.clearWait!.complete();
    await Future.wait([logout, authorization]);
    expect(network.authorizeCalls, 1);
    feature.dispose();
  });

  test('failed logout blocks login until cleanup is retried', () async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    final network = _Network()..clearError = StateError('clear failed');
    final feature = IdsUseCase(store, network);
    await feature.restore();
    await expectLater(feature.signOut(), throwsStateError);
    await expectLater(
      feature.signIn(IdsCredentials('bob', 'other')),
      throwsStateError,
    );
    expect(network.logins, isEmpty);
    network.clearError = null;
    await feature.signOut();
    await feature.signIn(IdsCredentials('bob', 'other'));
    expect((await store.read())?.username, 'bob');
    feature.dispose();
  });

  test('sign in waits for logout to finish deleting credentials', () async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    final network = _Network()..clearWait = Completer<void>();
    final feature = IdsUseCase(store, network);
    await feature.restore();

    final logout = feature.signOut();
    final login = feature.signIn(IdsCredentials('bob', 'other'));
    await Future<void>.delayed(Duration.zero);
    expect(network.logins, isEmpty);
    network.clearWait!.complete();
    await Future.wait([logout, login]);
    expect((await store.read())?.username, 'bob');
    expect(feature.snapshot.status, IdsStatus.ready);
    feature.dispose();
  });

  test('concurrent expired requests share one password login', () async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'secret'));
    final network = _Network()..expiredAuthorizations = 2;
    final feature = IdsUseCase(store, network);
    await feature.restore();

    await Future.wait([
      feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/a')),
      feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/b')),
    ]);

    expect(network.logins, [('alice', 'secret')]);
    expect(network.authorizeCalls, 4);
    feature.dispose();
  });

  testWidgets(
    'rejected saved password prompts for a new password without leaving the page',
    (tester) async {
      LocaleSettings.setLocaleSync(AppLocale.en);
      final store = _credentialsStore();
      await store.write(IdsCredentials('alice', 'old'));
      final network = _Network()
        ..expiredAuthorizations = 1
        ..error = const IdsCredentialsRejected('rejected');
      final feature = IdsUseCase(store, network);
      await feature.restore();
      await tester.pumpWidget(
        TranslationProvider(
          child: MaterialApp(home: _loginPage(feature, 'home')),
        ),
      );
      final failed = expectLater(
        feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/')),
        throwsA(isA<IdsCredentialsRejected>()),
      );
      await tester.pumpAndSettle();
      await failed;
      expect(find.text('home'), findsOneWidget);
      expect(find.text('Please sign in again'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).last).autofocus,
        isTrue,
      );
      await tester.enterText(find.byType(TextField).last, 'wrong');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Incorrect account or password.'), findsOneWidget);
      expect(find.text('home'), findsOneWidget);
      network.error = const IdsServiceUnavailable('private details');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Network unavailable. Try again.'), findsOneWidget);
      expect(find.textContaining('private details'), findsNothing);
      network.error = const IdsInteractionCancelled('cancelled');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Sign-in cancelled.'), findsOneWidget);
      network.error = null;
      await tester.enterText(find.byType(TextField).last, 'new');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('home'), findsOneWidget);
      expect(find.text('Please sign in again'), findsNothing);
      expect((await store.read())?.password, 'new');
      expect(network.authorizeCalls, 1);
      await feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/'));
      expect(network.authorizeCalls, 2);
      feature.dispose();
    },
  );

  testWidgets('signing out dismisses the saved-password prompt', (
    tester,
  ) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'old'));
    final network = _Network()
      ..expiredAuthorizations = 1
      ..error = const IdsCredentialsRejected('rejected');
    final feature = IdsUseCase(store, network);
    await feature.restore();
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(home: _loginPage(feature, 'home')),
      ),
    );
    final failed = expectLater(
      feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/')),
      throwsA(isA<IdsCredentialsRejected>()),
    );
    await tester.pumpAndSettle();
    await failed;
    expect(find.text('Please sign in again'), findsOneWidget);
    await feature.signOut();
    await tester.pumpAndSettle();
    expect(find.text('Please sign in again'), findsNothing);
    expect(find.text('Student or staff ID'), findsOneWidget);
    feature.dispose();
  });

  test(
    'reauthentication cannot start without a matching saved account',
    () async {
      final network = _Network();
      final feature = IdsUseCase(_credentialsStore(), network);
      await expectLater(
        feature.reauthenticate(IdsCredentials('alice', 'secret')),
        throwsStateError,
      );
      expect(network.logins, isEmpty);
      expect(feature.snapshot.status, IdsStatus.signedOut);
      feature.dispose();
    },
  );

  test('rejected saved password is not retried', () async {
    final store = _credentialsStore();
    await store.write(IdsCredentials('alice', 'wrong'));
    final network = _Network()
      ..expiredAuthorizations = 1
      ..error = const IdsCredentialsRejected('password rejected');
    final feature = IdsUseCase(store, network);
    await feature.restore();

    await expectLater(
      feature.authorizeService(Uri.parse('https://ehall.xidian.edu.cn/')),
      throwsA(isA<IdsCredentialsRejected>()),
    );

    expect(network.logins, [('alice', 'wrong')]);
    expect(network.authorizeCalls, 1);
    expect(feature.snapshot.status, IdsStatus.credentialsAvailable);
    expect(feature.snapshot.error, isA<IdsCredentialsRejected>());
    feature.dispose();
  });

  test(
    'credential write failure clears the accepted network session',
    () async {
      final secure = _MemorySecureStore()
        ..writeError = StateError('disk failure');
      final store = SecureIdsCredentialsStore(secure);
      final network = _Network();
      final feature = IdsUseCase(store, network);

      await expectLater(
        feature.signIn(IdsCredentials('alice', 'secret')),
        throwsStateError,
      );

      expect(network.resets, 1);
      expect(feature.snapshot.status, IdsStatus.error);
      feature.dispose();
    },
  );
}

Widget _loginPage(IdsUseCase feature, String homeLabel) => IdsGate(
  feature: feature,
  targetBuilder: (context) => _authenticatedPage(feature, homeLabel),
);

Widget _authenticatedPage(IdsUseCase feature, String homeLabel) =>
    IdsInteractionHost(feature: feature, child: Text(homeLabel));

SecureIdsCredentialsStore _credentialsStore() =>
    SecureIdsCredentialsStore(_MemorySecureStore());

final class _MemorySecureStore implements SecureStoreInterface {
  final values = <String, String>{};
  Completer<void>? readWait;
  Object? writeError;
  int reads = 0;

  @override
  Future<String?> read(String key) async {
    reads++;
    await readWait?.future;
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (writeError != null) throw writeError!;
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

final class _Network implements IdsNetworkRepository {
  Object? clearError;
  Completer<void>? clearWait;
  Object? error;
  Future<void> Function(IdsInteraction)? onLogin;
  Future<void> Function(IdsInteraction)? onAuthorize;
  Object? authorizationError;
  Completer<void>? authorization;
  int resets = 0;
  int authorizeCalls = 0;
  int expiredAuthorizations = 0;
  final logins = <(String, String)>[];

  @override
  Future<void> login(
    String username,
    String password, {
    IdsInteraction interaction = const IdsInteraction(),
  }) async {
    logins.add((username, password));
    if (error != null) throw error!;
    await onLogin?.call(interaction);
  }

  @override
  Future<void> authorize(
    Uri service, {
    IdsInteraction interaction = const IdsInteraction(),
  }) async {
    authorizeCalls++;
    await authorization?.future;
    if (expiredAuthorizations > 0) {
      expiredAuthorizations--;
      throw const IdsSessionExpired('session expired');
    }
    if (authorizationError != null) throw authorizationError!;
    await onAuthorize?.call(interaction);
  }

  @override
  Future<void> clear() async {
    resets++;
    await clearWait?.future;
    if (clearError != null) throw clearError!;
  }
}
