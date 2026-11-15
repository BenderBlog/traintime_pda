// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:watermeter/generated/translations.g.dart';

import '../model/pighub_image.dart';

class PigContent extends StatelessWidget {
  const PigContent({
    super.key,
    required this.images,
    required this.index,
    required this.onChangePig,
  });

  final Future<List<PigHubImage>> images;
  final int index;
  final ValueChanged<int> onChangePig;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PigHubImage>>(
      future: images,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          final error = snapshot.hasError
              ? snapshot.error
              : 'No pig images found';
          return [
                Text(
                  context.t.common.newHomepageHint,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Failed to fetch a pig :(\n$error',
                  textAlign: TextAlign.center,
                ),
              ]
              .toColumn(mainAxisAlignment: MainAxisAlignment.center)
              .padding(horizontal: 24)
              .center();
        }

        final data = snapshot.data!;
        final pig = data[index];
        return [
              Text(
                'There are ${data.length} pigs in the Animal Farm. \n'
                "Better stay at home and do as you're told. \n"
                'Get out of the road if you want to grow old!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: Image.network(
                  pig.url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image_outlined, size: 80),
                  ),
                ),
              ).clipRRect(all: 12),
              const SizedBox(height: 8),
              Text(
                pig.title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => onChangePig(data.length),
                icon: const Icon(Icons.shuffle),
                label: const Text('Change A Pig'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => launchUrlString(
                  pig.url,
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.save),
                label: const Text('Save this Pig'),
              ),
              const SizedBox(height: 16),
            ]
            .toColumn(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            )
            .scrollable()
            .center()
            .padding(horizontal: 24);
      },
    );
  }
}
