import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NewsSection extends StatelessWidget {
  final List<Map<String, dynamic>> newsItems;
  final Function(Map<String, dynamic>)? onNewsItemTap;

  const NewsSection({super.key, required this.newsItems, this.onNewsItemTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Talab bo'yicha: test kontent qo'ymaymiz, bo'sh bo'lsa yo'riqnoma ko'rsatamiz
    if (newsItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(4.w),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Text(
            "Yangiliklar va aksiyalar bo'limi hozircha bo'sh. assets/content/ ichida news.json va promotions.json fayllarini to'ldirib, shu yerga bog'lash mumkin.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yangiliklar va aksiyalar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/news-list');
                },
                child: Text(
                  'Barchasini ko\'rish',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 22.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              final newsItem = newsItems[index];
              return _buildNewsCard(context, newsItem, index == 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(
    BuildContext context,
    Map<String, dynamic> newsItem,
    bool isFirst,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 70.w,
      margin: EdgeInsets.only(right: isFirst ? 2.w : 3.w),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        shadowColor: colorScheme.shadow.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onNewsItemTap?.call(newsItem);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: newsItem["imageUrl"] != null
                          ? CustomImageWidget(
                              imageUrl: newsItem["imageUrl"] as String,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: CustomIconWidget(
                                iconName: 'article',
                                color: colorScheme.primary,
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (newsItem["category"] != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              newsItem["category"] as String,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 1.h),
                        ],
                        Expanded(
                          child: Text(
                            newsItem["title"] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'schedule',
                              color: colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              size: 12,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                newsItem["date"] as String,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(
                                    0.6,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
