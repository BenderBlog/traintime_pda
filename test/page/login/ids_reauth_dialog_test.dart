// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/login/ids_reauth_dialog.dart';
import 'package:watermeter/repository/ids_session/ids_auth_protocol.dart';
import 'package:watermeter/repository/ids_session/ids_reauth_client.dart';

void main() {
  for (final locale in [AppLocale.zh, AppLocale.zhTw]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      for (final method in IDSReAuthCodeType.values) {
        testWidgets('Verification dialog: $locale, scale $scale, $method', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(360, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          LocaleSettings.setLocaleSync(locale);
          addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.zh));
          final client = _CodeClient();
          await tester.pumpWidget(
            TranslationProvider(
              child: MaterialApp(
                locale: locale.flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates: GlobalMaterialLocalizations.delegates,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  body: Builder(
                    builder: (context) => TextButton(
                      onPressed: () async {
                        try {
                          await showIDSReAuthDialog(context, client);
                        } on IDSReAuthCancelledException {
                          // Cancellation is the expected way to close this test dialog.
                        }
                      },
                      child: const Text('Open'),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          if (method == IDSReAuthCodeType.enterpriseWechat) {
            await tester.tap(
              find.byType(DropdownButtonFormField<IDSReAuthCodeType>),
            );
            await tester.pumpAndSettle();
            await tester.tap(
              find
                  .text(locale.translations.login.secondFactor.enterpriseWechat)
                  .last,
            );
            await tester.pumpAndSettle();
          }
          await tester.ensureVisible(find.byType(OutlinedButton));
          await tester.tap(find.byType(OutlinedButton));
          await tester.pumpAndSettle();
          expect(client.sentMethods, [method]);

          // The keyboard and delivery status must not hide the trust hint or actions.
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byType(CheckboxListTile));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          final cancel = find.widgetWithText(
            TextButton,
            locale.translations.common.cancel,
          );
          expect(cancel.hitTestable(), findsOneWidget);
          expect(find.byType(FilledButton).hitTestable(), findsOneWidget);
          await tester.tap(cancel);
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsNothing);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}

class _CodeClient extends IDSReAuthClient {
  _CodeClient()
    : super(
        dio: Dio(),
        challengeUri: Uri.parse('https://example.test/challenge'),
        username: 'test',
        service: null,
      );

  final sentMethods = <IDSReAuthCodeType>[];

  @override
  Future<IDSCodeDelivery> sendCode({
    IDSReAuthCodeType codeType = IDSReAuthCodeType.sms,
  }) async {
    sentMethods.add(codeType);
    return const IDSCodeDelivery(
      message: '验证码已发送，请在有效期内输入验证码',
      maskedMobile: '130****0000',
      retryAfter: Duration(seconds: 120),
      wasAlreadySent: false,
    );
  }
}
