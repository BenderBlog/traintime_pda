import 'package:flutter/material.dart';

/// A Flutter dropdown styled to match the M3E dropdown field.
class SettingDropdownButton<T> extends StatelessWidget {
  const SettingDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(28);

    return Material(
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          isDense: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colors.onSurface),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconEnabledColor: colors.onSurface,
          iconDisabledColor: colors.onSurfaceVariant,
          dropdownColor: colors.surfaceContainer,
          borderRadius: radius,
          elevation: 3,
          menuMaxHeight: 350,
        ),
      ),
    );
  }
}
