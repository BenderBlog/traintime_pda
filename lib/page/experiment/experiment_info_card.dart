// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/repository/experiment_score/image_recognition.dart';
import 'package:watermeter/generated/translations.g.dart';

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
              if (data!.score != null)
                ReXCardRemaining(
                  data!.score!.found
                      ? context.t.experiment.scoreInfo(score: data!.score!.label)
                      : context.t.experiment.tapForScore,
                  isBold: true,
                  onTap: () {
                    _showAlertDialog(
                      context,
                      data!.score!.found,
                      data!.name,
                      data!.score,
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
                      flex: data!.reference?.isNotEmpty ?? false ? 1 : 2,
                      child: InformationWithIcon(
                        icon: Icons.room,
                        text: data!.classroom,
                      ),
                    ),
                    if (data!.reference?.isNotEmpty ?? false)
                      Expanded(
                        flex: 1,
                        child: InformationWithIcon(
                          icon: Icons.book,
                          text: data!.reference!,
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: InformationWithIcon(
                        icon: Icons.person,
                        text: data!.teacher,
                      ),
                    ),
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
    bool isFound,
    String title,
    RecognitionResult? recognition,
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
                Text(
                  isFound
                      ? context.t.experiment.scoreHint3
                      : context.t.experiment.scoreHint1,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(context.t.experiment.yourScore),
                    Container(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                        maxWidth: 300,
                      ),
                      decoration: BoxDecoration(color: Colors.white),
                      child: Image.network(
                        recognition?.rawUrl ?? "",
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
                if (recognition?.found ?? false)
                  Text(
                    context.t.experiment.predictScore(score: recognition!.label),
                  ),
                Divider(),
                Text(context.t.experiment.scoreHint2),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(context.t.experiment.sendMail),
              onPressed: () async {
                final subject = Uri.encodeComponent("XDYou 物理实验图片识别追加");
                final body = Uri.encodeComponent(
                  '''图片链接：${recognition?.rawUrl ?? ":P"}
                识别分数：${recognition?.label}''',
                );
                final mailto =
                    'mailto:superbart_chen@qq.com?subject=$subject&body=$body';
                await launchUrlString(
                  mailto,
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            TextButton(
              child: Text(context.t.common.cancel),
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
