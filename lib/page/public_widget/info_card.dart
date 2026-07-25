// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class InfoCard extends StatelessWidget {
  final IconData? iconData;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onTap;
  final String title;
  final List<Widget> children;

  const InfoCard({
    super.key,
    this.iconData,
    this.icon,
    this.buttonText,
    this.onTap,
    required this.title,
    required this.children,
  }) : assert(
         (icon == null && buttonText == null && onTap == null) ||
             (icon != null && buttonText != null && onTap != null),
         "icon, buttonText, and onTap must be provided together",
       );

  @override
  Widget build(BuildContext context) {
    return [
          [
                if (iconData != null)
                  Icon(
                    iconData,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ).padding(right: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    textBaseline: TextBaseline.ideographic,
                    fontSize: 16,
                  ),
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: onTap,
                    icon: Icon(icon!, size: 20),
                    label: Text(buttonText!),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ]
              .toRow(crossAxisAlignment: CrossAxisAlignment.center)
              .padding(
                vertical: icon == null ? 8 : 2,
                left: 12,
                right: icon == null ? 12 : 0,
              )
              .backgroundColor(Theme.of(context).colorScheme.primary),
          ...children,
        ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(bottom: 12)
        .card(elevation: 0);
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color? valueColor;
  const InfoItem({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            "$label${value == null ? "" : "："}",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          if (value != null) ...[
            const SizedBox(width: 4),
            Text(
              value!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
