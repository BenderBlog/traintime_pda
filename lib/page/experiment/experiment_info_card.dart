// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';

class ExperimentInfoCard extends StatelessWidget {
  final ExperimentData? data;
  final String? title;
  const ExperimentInfoCard({super.key, this.data, this.title})
    : assert(data != null || title != null);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (data != null) {
          return ReXCard(
            title: Text(data!.name),
            remaining: [
              (data!.score != null && data!.score!.found)
                  ? ReXCardRemaining(data!.score!.label)
                  : ReXCardRemaining(
                      FlutterI18n.translate(
                        context,
                        "experiment.tap_for_score",
                      ),
                      isBold: true,
                      onTap: () {
                        _showAlertDialog(
                          context,
                          data!.name,
                          data!.score?.rawUrl ?? '',
                        );
                      },
                    ),
            ],
            bottomRow: Column(
              children: [
                Builder(
                  builder: (context) {
                    final dateFormatter = DateFormat(
                      'y/M/d EEEE',
                      Localizations.localeOf(context).toLanguageTag(),
                    );
                    final timeFormatter = DateFormat("HH:mm:ss");

                    return InformationWithIcon(
                      icon: Icons.access_time_filled_rounded,
                      text: data!.timeRanges
                          .map<String>((timeRange) {
                            final firstDate = timeRange.$1;
                            final secondDate = timeRange.$2;
                            final dateStr = dateFormatter.format(firstDate);
                            final startTimeStr = timeFormatter.format(
                              firstDate,
                            );
                            final endTimeStr = timeFormatter.format(secondDate);
                            return "$dateStr $startTimeStr~$endTimeStr";
                          })
                          .join("\n"),
                    );
                  },
                ),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      flex: 2,
                      child: InformationWithIcon(
                        icon: Icons.room,
                        text: data!.classroom,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: InformationWithIcon(
                        icon: Icons.person,
                        text: data!.teacher,
                      ),
                    ),
                    // if (data!.reference?.isNotEmpty ?? false)
                    //   Expanded(
                    //     flex: 1,
                    //     child: InformationWithIcon(
                    //       icon: Icons.book,
                    //       text: data!.reference!,
                    //     ),
                    //   ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 0,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Text(
                title!,
                textScaler: const TextScaler.linear(1.1),
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _showAlertDialog(
    BuildContext context,
    String title,
    String imageUrl,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(FlutterI18n.translate(context, "experiment.score_hint_1")),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(FlutterI18n.translate(context, "experiment.your_score")),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        maxWidth: 300,
                      ),
                      child: Image.network(
                        imageUrl,
                        scale: 0.75,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 48);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(),
                Text(FlutterI18n.translate(context, "experiment.score_hint_2")),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                FlutterI18n.translate(context, "experiment.send_mail"),
              ),
              onPressed: () async {
                final subject = Uri.encodeComponent("XDYou 图片识别追加");
                final body = Uri.encodeComponent(imageUrl);
                final mailto = 'mailto:?subject=$subject&body=$body';
                await launchUrlString(
                  mailto,
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            TextButton(
              child: Text(FlutterI18n.translate(context, "cancel")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
