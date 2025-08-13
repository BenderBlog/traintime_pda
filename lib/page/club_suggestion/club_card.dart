// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:watermeter/model/pda_service/club_info.dart';

class ClubCard extends StatelessWidget {
  final ClubInfo data;

  const ClubCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsetsGeometry.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipOval(
              child: Image(
                image: data.icon,
                errorBuilder: (BuildContext context, Object e, StackTrace? s) {
                  return const Icon(Icons.face_2, size: 64);
                },
                width: 64,
                height: 64,
              ),
            ),
            VerticalDivider(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          style: TextStyle(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: data.type
                            .map(
                              (type) => Padding(
                                padding: EdgeInsetsGeometry.only(left: 4),
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.all(
                                    Radius.circular(12),
                                  ),
                                  child: Container(
                                    padding: EdgeInsetsGeometry.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    child: Text(
                                      type.getTypeName(),
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  Text(
                    data.intro,
                    softWrap: true,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
