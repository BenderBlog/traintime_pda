// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:watermeter/model/pda_service/club_info.dart';
import 'package:watermeter/page/club_suggestion/club_card.dart';
import 'package:watermeter/page/club_suggestion/club_detail.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/public_widget.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/pda_service_session.dart';

class ClubSuggestion extends StatefulWidget {
  const ClubSuggestion({super.key});

  @override
  State<ClubSuggestion> createState() => _ClubSuggestionState();
}

class _ClubSuggestionState extends State<ClubSuggestion> {
  ClubType shownType = ClubType.all;

  Widget chooseChip(ClubType e) => Padding(
    padding: EdgeInsetsGeometry.symmetric(horizontal: 4),
    child: TextButton(
      style: TextButton.styleFrom(
        backgroundColor: shownType == e
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      ),
      onPressed: () => setState(() {
        shownType = e;
      }),
      child: Text(
        FlutterI18n.translate(context, e.getTypeName()),
        style: TextStyle(
          color: shownType == e
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    if (clubState.value == SessionState.none) {
      getClubList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (clubState.value) {
        case SessionState.fetched:
          {
            var clubTypeList = List.from(ClubType.values);
            clubTypeList.removeWhere(
              (e) => e == ClubType.unknown || e == ClubType.all,
            );

            var filteredClubList = clubList.where((value) {
              if (shownType == ClubType.all) return true;
              return value.type.contains(shownType);
            }).toList();

            return Scaffold(
              appBar: AppBar(
                title: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Row(
                    children: [
                      chooseChip(ClubType.all),
                      const VerticalDivider(),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: kToolbarHeight,
                          ),
                          child: ListView(
                            padding: EdgeInsetsDirectional.symmetric(
                              vertical: 12,
                            ),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: clubTypeList
                                .map((e) => chooseChip(e))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: LayoutBuilder(
                builder: (context, constraints) => MasonryGridView.count(
                  shrinkWrap: true,
                  itemCount: filteredClubList.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  crossAxisCount: constraints.maxWidth ~/ 280,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => context.pushReplacement(
                        ClubDetail(code: filteredClubList[index].code),
                      ),
                      child: ClubCard(data: filteredClubList[index]),
                    );
                  },
                ),
              ),
            );
          }
        case SessionState.error:
          return ReloadWidget(
            errorStatus: clubError,
            function: () => getClubList(),
          );
        default:
          return Center(child: CircularProgressIndicator());
      }
    });
  }
}
