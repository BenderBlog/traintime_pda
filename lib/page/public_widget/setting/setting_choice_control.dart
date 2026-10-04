// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';

class SettingChoiceOption<T> {
  const SettingChoiceOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// Uses a segmented button only when every translated label fits.
class SettingChoiceControl<T> extends StatelessWidget {
  const SettingChoiceControl({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<SettingChoiceOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final requiredWidth = options.fold<double>(0, (width, option) {
          final painter = TextPainter(
            text: TextSpan(
              text: option.label,
              style: theme.textTheme.labelLarge,
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 1,
          )..layout();
          final result = width > painter.width ? width : painter.width;
          painter.dispose();
          return result;
        });
        if (options.length >= 2 &&
            options.length <= 5 &&
            (requiredWidth + 72) * options.length <= constraints.maxWidth) {
          return SegmentedButton<T>(
            segments: options
                .map(
                  (option) => ButtonSegment<T>(
                    value: option.value,
                    label: Text(option.label),
                    icon: option.icon == null ? null : Icon(option.icon),
                  ),
                )
                .toList(),
            selected: {value},
            onSelectionChanged: (selected) => onChanged(selected.single),
          );
        }
        return SettingRadioChoices<T>(
          value: value,
          options: options,
          onChanged: onChanged,
        );
      },
    );
  }
}

class SettingRadioChoices<T> extends StatelessWidget {
  const SettingRadioChoices({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<SettingChoiceOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: value,
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (option) => RadioListTile<T>(
                value: option.value,
                title: Text(option.label),
                secondary: option.icon == null ? null : Icon(option.icon),
                contentPadding: EdgeInsets.zero,
              ),
            )
            .toList(),
      ),
    );
  }
}
