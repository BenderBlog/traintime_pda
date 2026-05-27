// Copyright 2026 BenderBlog Rodriguez and Contributors.
// SPDX-License-Identifier: BSD-3-Clause

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../constants/urls.dart';
import '../models/topic.dart';

/// 帖子列表项
class TopicListItem extends StatelessWidget {
  final Topic topic;
  final VoidCallback? onTap;

  const TopicListItem({super.key, required this.topic, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: Urls.getAvaterUrl(topic.authorId),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: 40,
                  height: 40,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.person, size: 24),
                ),
                errorWidget: (_, _, _) => Container(
                  width: 40,
                  height: 40,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.person, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      if (topic.isStick) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            FlutterI18n.translate(
                              context,
                              'ruisi.topic_list_item.sticky',
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          topic.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (topic.isImage) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.image,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 底部信息
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      Text(
                        topic.author,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      if (topic.categoryName != null &&
                          topic.categoryName!.isNotEmpty) ...[
                        Text(
                          ' • ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            topic.categoryName!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 16),
                      if (topic.lastReplyTime != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          topic.lastReplyTime!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${topic.replies}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.remove_red_eye,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${topic.views}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
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
