import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductCategoriesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(Map<String, dynamic>)? onCategoryTap;

  const ProductCategoriesGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mahsulot turlari',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/product-catalog');
                },
                child: Text(
                  'Barchasini ko\'rish',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length > 4 ? 4 : categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onCategoryTap?.call(category);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorScheme.primary.withOpacity(0.05),
                  ),
                  child: category["imageUrl"] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: category["imageUrl"] as String,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Center(
                    child: CustomIconWidget(
                      iconName: 'local_gas_station',
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  child: Column(
                    children: [
                      Text(
                        category["name"] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Expanded(
                        child: Text(
                          '${category["startingPrice"]} dan boshlab',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
