import 'package:flutter_test/flutter_test.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/repository/translation_key.dart';

void main() {
  for (final locale in AppLocale.values) {
    final tr = locale.buildSync();
    test('${locale.name}: runtime paths use the selected locale', () {
      expect(tr.resolveKey('setting.change_color_dialog.default'),
          tr.setting.changeColorDialog.kDefault);
      expect(tr.resolveKey('setting.change_color_dialog.deepPurple'),
          tr.setting.changeColorDialog.deepPurple);
      expect(tr.resolveKey('setting.navigation.account_description'),
          tr.setting.navigation.accountDescription);
      expect(tr.resolveKey('electricity.aircon_remote'),
          tr.electricity.airconRemote);
      expect(tr.resolveKey('login.second_factor.enterprise_wechat'),
          tr.login.secondFactor.enterpriseWechat);
      expect(tr.resolveKey('confirm'), tr.common.confirm);
      expect(tr.resolveKey('unknown service error'), 'unknown service error');
    });

    test('${locale.name}: dynamic cache and semester messages interpolate', () {
      expect(
        tr.resolveKey('classtable.empty_state.no_course',
            params: {'semester_code': '2026-2027'}),
        tr.classtable.emptyState.noCourse(semester_code: '2026-2027'),
      );
      expect(
        tr.resolveKey('library.borrow_list_info',
            params: {'borrow': '5', 'dued': '2'}),
        tr.library.borrowListInfo(borrow: '5', dued: '2'),
      );
    });
  }
}
