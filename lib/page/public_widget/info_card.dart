// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class InfoCard extends StatelessWidget {
  final IconData? iconData;
  final String title;
  final List<Widget> children;

  const InfoCard({
    super.key,
    this.iconData,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return [
          [
            if (iconData != null)
              Icon(
                iconData,
                color: Theme.of(context).primaryColor,
              ).padding(right: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                textBaseline: TextBaseline.ideographic,
              ),
            ),
          ].toRow(crossAxisAlignment: CrossAxisAlignment.center),

          const SizedBox(height: 8),
          ...children,
        ]
        .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
        .padding(all: 16)
        .card(elevation: 0);
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const InfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            "$label：",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
