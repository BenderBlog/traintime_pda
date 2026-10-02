// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';

class ElectricityReadyView extends StatelessWidget {
  final List<Widget> electricityCards;
  final List<Widget> waterCards;
  final List<Widget> notices;

  const ElectricityReadyView({
    super.key,
    required this.electricityCards,
    required this.waterCards,
    this.notices = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            if (notices.isNotEmpty)
              PinnedHeaderSliver(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: notices,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child:
                  [
                    Text(
                          FlutterI18n.translate(context, "electricity.info"),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[800],
                            height: 1.4,
                          ),
                        )
                        .padding(all: 16)
                        .decorated(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        )
                        .padding(vertical: 8, horizontal: 20)
                        .width(double.infinity)
                        .constrained(maxWidth: sheetMaxWidth)
                        .center(),

                    for (final widget in [...electricityCards, ...waterCards])
                      widget
                          .padding(vertical: 4, horizontal: 16)
                          .constrained(maxWidth: sheetMaxWidth)
                          .center(),

                    Image.asset(
                      "assets/art/pda_girl_default.webp",
                    ).padding(bottom: 16, horizontal: 16),
                  ].toColumn(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
