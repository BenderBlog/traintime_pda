import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:watermeter/core/languages/language_store_interface.dart';
import 'package:watermeter/core/shared/widgets/settings/choice_control.dart';
import 'package:watermeter/core/shared/widgets/settings/control_tile.dart';
import 'package:watermeter/core/shared/widgets/settings/section_scaffold.dart';
import 'package:watermeter/core/shared/widgets/settings/segmented_list.dart';
import 'package:watermeter/generated/translations.g.dart';

class LanguageSettingsCard extends StatelessWidget {
  const LanguageSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<LanguageStoreInterface>();
    return SignalBuilder(
      builder: (context) {
        final strings = context.t.core.language;
        return SectionSettingScaffold(
          icon: Icons.translate,
          title: strings.title,
          items: SettingSegmentedList(
            items: [
              SettingControlTile(
                leading: Icons.language,
                title: strings.selection,
                child: SettingChoiceControl<AppLanguage>(
                  value: store.language.value,
                  options: [
                    SettingChoiceOption(
                      value: AppLanguage.system,
                      label: strings.system,
                    ),
                    SettingChoiceOption(
                      value: AppLanguage.simplifiedChinese,
                      label: strings.simplifiedChinese,
                    ),
                    SettingChoiceOption(
                      value: AppLanguage.traditionalChinese,
                      label: strings.traditionalChinese,
                    ),
                    SettingChoiceOption(
                      value: AppLanguage.english,
                      label: strings.english,
                    ),
                  ],
                  onChanged: (value) async {
                    try {
                      await store.setLanguage(value);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(strings.saveFailed),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
