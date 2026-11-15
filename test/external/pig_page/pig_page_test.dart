import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:watermeter/external/pig_page/pig_page.dart';
import 'package:watermeter/generated/translations.g.dart';

void main() {
  Widget page(Dio dio) => TranslationProvider(
    child: MaterialApp(home: PigPage(dio: dio)),
  );

  testWidgets('uses the injected Dio, refreshes, and switches clients', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var requests = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            expect(
              options.uri.toString(),
              'https://www.pighub.top/api/images?sort=0',
            );
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': [
                    {
                      'id': 1,
                      'image_url': '/pig.jpg',
                      'title': 'Pig $requests',
                      'view_count': 0,
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
    addTearDown(dio.close);

    await tester.pumpWidget(page(dio));
    await tester.pumpAndSettle();
    expect(find.text('Pig 1'), findsOneWidget);
    expect(requests, 1);

    await tester.tap(find.byIcon(Icons.replay_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Pig 2'), findsOneWidget);
    expect(requests, 2);

    final otherDio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'data': [
                    {
                      'id': 2,
                      'image_url': '/other.jpg',
                      'title': 'Other pig',
                      'view_count': 0,
                    },
                  ],
                },
              ),
            );
          },
        ),
      );
    addTearDown(otherDio.close);
    await tester.pumpWidget(page(otherDio));
    await tester.pumpAndSettle();
    expect(find.text('Other pig'), findsOneWidget);
    expect(requests, 2);
  });

  testWidgets('shows an error for failed and empty responses', (tester) async {
    var requests = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            if (requests == 1) {
              handler.reject(
                DioException(requestOptions: options, error: 'offline'),
              );
            } else {
              handler.resolve(
                Response(requestOptions: options, data: {'data': []}),
              );
            }
          },
        ),
      );
    addTearDown(dio.close);

    await tester.pumpWidget(page(dio));
    await tester.pumpAndSettle();
    expect(find.textContaining('Failed to fetch a pig'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.replay_outlined));
    await tester.pumpAndSettle();
    expect(find.textContaining('No pig images found'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
