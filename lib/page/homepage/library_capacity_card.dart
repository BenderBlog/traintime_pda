// Copyright 2025 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:result_dart/result_dart.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/library_capacity.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/repository/library_capacity_session.dart';

class LibraryCapacityCard extends StatelessWidget {
  const LibraryCapacityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var north = northStatus.value;
      var south = southStatus.value;

      return [
        Text(
          FlutterI18n.translate(context, "library_card.title"),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ).padding(vertical: 2),
        [
          Flexible(flex: 1, child: LibraryCapacityInfo(info: south)),
          Flexible(
            flex: 1,
            child: LibraryCapacityInfo(info: north, isNorthCampus: true),
          ),
        ].toRow(),
      ].toColumn().paddingDirectional(all: 8).withHomeCardStyle(context);
    });
  }
}

class LibraryCapacityInfo extends StatelessWidget {
  final bool isNorthCampus;
  final Result<LibraryCapacity> info;

  const LibraryCapacityInfo({
    super.key,
    required this.info,
    this.isNorthCampus = false,
  });

  @override
  Widget build(BuildContext context) {
    return info
        .fold(
          (success) => success.isEmptyData
              ? Text(FlutterI18n.translate(context, "library_card.fetching"))
              : [
                  Text(
                    FlutterI18n.translate(
                      context,
                      isNorthCampus
                          ? "library_card.northern_library"
                          : "library_card.southern_library",
                    ),
                  ),
                  [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      FlutterI18n.translate(
                        context,
                        "library_card.people",
                        translationParams: {
                          "people": success.occupancy.toString(),
                        },
                      ),
                    ),
                  ].toRow(),
                  [
                    Icon(
                      Icons.chair,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      FlutterI18n.translate(
                        context,
                        "library_card.seat",
                        translationParams: {
                          "seat": success.availableSeats.toString(),
                        },
                      ),
                    ),
                  ].toRow(),
                ].toColumn(crossAxisAlignment: CrossAxisAlignment.start),
          (failure) => Text(failure.toString()),
        )
        .padding(all: 12.0)
        .card(color: Theme.of(context).colorScheme.onPrimary, elevation: 0);
  }
}
