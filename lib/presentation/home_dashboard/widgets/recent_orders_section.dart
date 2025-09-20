import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentOrdersSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentOrders;
  final Function(Map<String, dynamic>)? onOrderTap;
  final Function(Map<String, dynamic>)? onReorderTap;
  final Function(Map<String, dynamic>)? onTrackTap;
  final Function(Map<String, dynamic>)? onRateTap;

  const RecentOrdersSection({
    super.key,
    required this.recentOrders,
    this.onOrderTap,
    this.onReorderTap,
    this.onTrackTap,
    this.onRateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (recentOrders.isEmpty) {
      return _buildEmptyState(context);
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
                'So\'nggi buyurtmalar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/order-tracking');
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          itemCount: recentOrders.length > 3 ? 3 : recentOrders.length,
          itemBuilder: (context, index) {
            final order = recentOrders[index];
            return _buildOrderCard(context, order);
          },
        ),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        shadowColor: colorScheme.shadow.withValues(alpha: 0.05),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onOrderTap?.call(order);
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            _showQuickActions(context, order);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order["status"] as String)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'receipt_long',
                        color: _getStatusColor(order["status"] as String),
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buyurtma #${order["orderNumber"]}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            order["date"] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                              colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order["status"] as String)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(order["status"] as String),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(order["status"] as String),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order["productName"] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Miqdor: ${order["quantity"]}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                              colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      order["totalPrice"] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onTrackTap?.call(order);
                        },
                        icon: CustomIconWidget(
                          iconName: 'track_changes',
                          color: colorScheme.primary,
                          size: 16,
                        ),
                        label: Text(
                          'Kuzatish',
                          style: theme.textTheme.labelMedium,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onReorderTap?.call(order);
                        },
                        icon: CustomIconWidget(
                          iconName: 'refresh',
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                        label: Text(
                          'Qayta buyurtma',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'receipt_long_outlined',
            color: colorScheme.primary.withValues(alpha: 0.6),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Hali buyurtmalar yo\'q',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Birinchi buyurtmangizni bering va bizning xizmatimizdan foydalaning',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/product-catalog');
            },
            child: Text('Buyurtma berish'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context, Map<String, dynamic> order) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Buyurtma #${order["orderNumber"]}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'track_changes',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Kuzatish'),
              onTap: () {
                Navigator.pop(context);
                onTrackTap?.call(order);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Qayta buyurtma berish'),
              onTap: () {
                Navigator.pop(context);
                onReorderTap?.call(order);
              },
            ),
            if (order["status"] == "delivered") ...[
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'star_rate',
                  color: AppTheme.warningLight,
                  size: 24,
                ),
                title: Text('Xizmatni baholash'),
                onTap: () {
                  Navigator.pop(context);
                  onRateTap?.call(order);
                },
              ),
            ],
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppTheme.warningLight;
      case 'confirmed':
        return AppTheme.accentLight;
      case 'preparing':
        return AppTheme.warningLight;
      case 'on_the_way':
        return AppTheme.accentLight;
      case 'delivered':
        return AppTheme.successLight;
      case 'cancelled':
        return AppTheme.errorLight;
      default:
        return AppTheme.neutralDarkColor;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Kutilmoqda';
      case 'confirmed':
        return 'Tasdiqlandi';
      case 'preparing':
        return 'Tayyorlanmoqda';
      case 'on_the_way':
        return 'Yo\'lda';
      case 'delivered':
        return 'Yetkazildi';
      case 'cancelled':
        return 'Bekor qilindi';
      default:
        return 'Noma\'lum';
    }
  }
}
