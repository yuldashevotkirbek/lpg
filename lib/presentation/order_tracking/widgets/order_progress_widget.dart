import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class OrderProgressWidget extends StatelessWidget {
  final List<Map<String, dynamic>> orderStages;
  final int currentStageIndex;

  const OrderProgressWidget({
    super.key,
    required this.orderStages,
    required this.currentStageIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buyurtma holati',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          _buildProgressIndicator(context),
          SizedBox(height: 2.h),
          _buildStagesList(context),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (currentStageIndex + 1) / orderStages.length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 6,
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              '${((progress * 100).round())}%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: orderStages.asMap().entries.map((entry) {
            final index = entry.key;
            final isCompleted = index <= currentStageIndex;
            final isActive = index == currentStageIndex;

            return _buildStageIndicator(context, index, isCompleted, isActive);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStageIndicator(
      BuildContext context, int index, bool isCompleted, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.3),
        border:
        isActive ? Border.all(color: colorScheme.primary, width: 3) : null,
      ),
      child: isCompleted
          ? CustomIconWidget(
        iconName: 'check',
        color: colorScheme.onPrimary,
        size: 4.w,
      )
          : null,
    );
  }

  Widget _buildStagesList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: orderStages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        final isCompleted = index <= currentStageIndex;
        final isActive = index == currentStageIndex;

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(color: colorScheme.primary.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
                child: isCompleted
                    ? CustomIconWidget(
                  iconName: 'check',
                  color: colorScheme.onPrimary,
                  size: 5.w,
                )
                    : Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage['title'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (stage['timestamp'] != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        stage['timestamp'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                    if (stage['description'] != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        stage['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Joriy',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
