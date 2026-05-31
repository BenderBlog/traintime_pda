// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

part of '../content_classtable_page.dart';

BoxDecoration buildClassTableBackgroundDecoration(
  BuildContext context,
  ClassTableWidgetState classTableState,
) {
  final image = File("${supportPath.path}/${classTableState.decorationName}");
  return BoxDecoration(
    image:
        (preference.getBool(preference.Preference.decorated) &&
            image.existsSync())
        ? DecorationImage(
            image: FileImage(image),
            fit: BoxFit.cover,
            opacity: Theme.of(context).brightness == Brightness.dark
                ? 0.4
                : 1.0,
          )
        : null,
  );
}
