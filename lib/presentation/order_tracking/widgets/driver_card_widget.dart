import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DriverCardWidget extends StatelessWidget {
  final Map<String, dynamic> driverInfo;
  final VoidCallback? onCallDriver;

  const DriverCardWidget({
    super.key,
    required this.driverInfo,
    this.onCallDriver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_shipping',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Haydovchi ma\'lumotlari',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              _buildDriverAvatar(context),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildDriverInfo(context),
              ),
              _buildCallButton(context),
            ],
          ),
          SizedBox(height: 3.h),
          _buildVehicleInfo(context),
        ],
      ),
    );
  }

  Widget _buildDriverAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 15.w,
      height: 15.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.w),
        child: driverInfo['avatar'] != null
            ? CustomImageWidget(
          imageUrl: driverInfo['avatar'] as String,
          width: 15.w,
          height: 15.w,
          fit: BoxFit.cover,
        )
            : Container(
          color: colorScheme.primary.withOpacity(0.1),
          child: CustomIconWidget(
            iconName: 'person',
            color: colorScheme.primary,
            size: 8.w,
          ),
        ),
      ),
    );
  }

  Widget _buildDriverInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          driverInfo['name'] as String? ?? 'Noma\'lum haydovchi',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'star',
              color: Colors.amber,
              size: 4.w,
            ),
            SizedBox(width: 1.w),
            Text(
              '${driverInfo['rating'] ?? 4.5}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '(${driverInfo['totalTrips'] ?? 150} safar)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        if (driverInfo['phone'] != null) ...[
          SizedBox(height: 0.5.h),
          Text(
            driverInfo['phone'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCallButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onCallDriver != null) {
            onCallDriver!();
          }
        },
        icon: CustomIconWidget(
          iconName: 'phone',
          color: colorScheme.onPrimary,
          size: 5.w,
        ),
        tooltip: 'Haydovchiga qo\'ng\'iroq qilish',
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'local_shipping',
            color: colorScheme.primary,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transport vositasi',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${driverInfo['vehicleModel'] ?? 'Yuk mashinasi'} • ${driverInfo['plateNumber'] ?? '01A123BC'}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (driverInfo['vehicleColor'] != null)
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: _getVehicleColor(driverInfo['vehicleColor'] as String),
                shape: BoxShape.circle,
                border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3)),
              ),
            ),
        ],
      ),
    );
  }

  Color _getVehicleColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'oq':
      case 'white':
        return Colors.white;
      case 'qora':
      case 'black':
        return Colors.black;
      case 'ko\'k':
      case 'blue':
        return Colors.blue;
      case 'qizil':
      case 'red':
        return Colors.red;
      case 'yashil':
      case 'green':
        return Colors.green;
      case 'kulrang':
      case 'grey':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
