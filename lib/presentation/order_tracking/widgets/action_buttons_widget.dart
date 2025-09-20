import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onCallDriver;
  final VoidCallback? onCallSupport;
  final VoidCallback? onCancelOrder;
  final String orderStatus;

  const ActionButtonsWidget({
    super.key,
    this.onCallDriver,
    this.onCallSupport,
    this.onCancelOrder,
    required this.orderStatus,
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
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amallar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Primary action buttons
        Row(
          children: [
            if (_shouldShowCallDriver())
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Haydovchiga qo\'ng\'iroq',
                  icon: 'phone',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (onCallDriver != null) {
                      onCallDriver!();
                    }
                  },
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            if (_shouldShowCallDriver() && _shouldShowCallSupport())
              SizedBox(width: 3.w),
            if (_shouldShowCallSupport())
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Qo\'llab-quvvatlash',
                  icon: 'support_agent',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (onCallSupport != null) {
                      onCallSupport!();
                    }
                  },
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                ),
              ),
          ],
        ),

        // Secondary actions
        if (_shouldShowSecondaryActions()) ...[
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  context,
                  label: 'Buyurtmani ulashish',
                  icon: 'share',
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _shareOrder(context);
                  },
                ),
              ),
              SizedBox(width: 3.w),
              if (_shouldShowCancelButton())
                Expanded(
                  child: _buildSecondaryButton(
                    context,
                    label: 'Bekor qilish',
                    icon: 'cancel',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showCancelDialog(context);
                    },
                    isDestructive: true,
                  ),
                ),
            ],
          ),
        ],

        // Emergency contact
        SizedBox(height: 3.h),
        _buildEmergencyContact(context),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String label,
        required String icon,
        required VoidCallback onPressed,
        required Color backgroundColor,
        required Color foregroundColor,
      }) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: CustomIconWidget(
        iconName: icon,
        color: foregroundColor,
        size: 5.w,
      ),
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildSecondaryButton(
      BuildContext context, {
        required String label,
        required String icon,
        required VoidCallback onPressed,
        bool isDestructive = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.primary;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: CustomIconWidget(
        iconName: icon,
        color: color,
        size: 4.w,
      ),
      label: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: EdgeInsets.symmetric(vertical: 2.5.h, horizontal: 3.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'emergency',
            color: colorScheme.error,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favqulodda holat',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Muammo yuzaga kelsa: +998 71 123 45 67',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // Handle emergency call
            },
            child: Text(
              'Qo\'ng\'iroq',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowCallDriver() {
    return ['out_for_delivery', 'dispatched']
        .contains(orderStatus.toLowerCase());
  }

  bool _shouldShowCallSupport() {
    return !['delivered', 'cancelled'].contains(orderStatus.toLowerCase());
  }

  bool _shouldShowSecondaryActions() {
    return !['cancelled'].contains(orderStatus.toLowerCase());
  }

  bool _shouldShowCancelButton() {
    return ['confirmed', 'prepared'].contains(orderStatus.toLowerCase());
  }

  void _shareOrder(BuildContext context) {
    // Implement order sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buyurtma ma\'lumotlari ulashildi'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Buyurtmani bekor qilish',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Haqiqatan ham bu buyurtmani bekor qilmoqchimisiz? Bu amalni qaytarib bo\'lmaydi.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Yo\'q',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onCancelOrder != null) {
                  onCancelOrder!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: Text(
                'Ha, bekor qilish',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
