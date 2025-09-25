import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionButtons extends StatelessWidget {
  final VoidCallback? onReorderLast;
  final VoidCallback? onScheduleDelivery;

  const QuickActionButtons({
    super.key,
    this.onReorderLast,
    this.onScheduleDelivery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context: context,
              title: 'Oxirgi buyurtmani takrorlash',
              icon: 'refresh',
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              onTap: () {
                HapticFeedback.lightImpact();
                onReorderLast?.call();
              },
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: _buildActionButton(
              context: context,
              title: 'Yetkazishni rejalashtirish',
              icon: 'schedule',
              backgroundColor: colorScheme.secondary,
              textColor: colorScheme.onSecondary,
              onTap: () {
                HapticFeedback.lightImpact();
                onScheduleDelivery?.call();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String icon,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      shadowColor: backgroundColor.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 12.h,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: textColor,
                size: 24,
              ),
              SizedBox(height: 1.h),
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
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
    );
  }
}
