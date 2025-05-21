// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData icon;
  final String str;
  final MaterialColor infoColor;

  const CustomListTile({
    super.key,
    required this.icon,
    required this.str,
    required this.infoColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: infoColor.shade900,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              str,
              style: TextStyle(
                color: infoColor.shade900,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
