import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AccountActionsWidget extends StatelessWidget {
  final VoidCallback onLogout;

  const AccountActionsWidget({
    super.key,
    required this.onLogout,
  });

  void _navigateToRoute(BuildContext context, String route) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, route);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chiqish'),
        content: Text('Hisobingizdan chiqishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Chiqish'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required String title,
    required String iconName,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: isDestructive
                  ? Theme.of(context).colorScheme.error.withOpacity(0.1)
                  : Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          trailing: CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            size: 16,
          ),
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0.5.h),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'account_circle',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Hisob amaliyotlari',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildActionItem(
              context: context,
              title: 'Buyurtmalar tarixi',
              iconName: 'history',
              onTap: () => _navigateToRoute(context, '/order-tracking'),
            ),
            _buildActionItem(
              context: context,
              title: 'To\'lov usullari',
              iconName: 'payment',
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('To\'lov usullari bo\'limi tez orada'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildActionItem(
              context: context,
              title: 'Yordam va qo\'llab-quvvatlash',
              iconName: 'help_outline',
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Yordam bo\'limi tez orada'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildActionItem(
              context: context,
              title: 'Foydalanish shartlari',
              iconName: 'description',
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Foydalanish shartlari tez orada'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildActionItem(
              context: context,
              title: 'Maxfiylik siyosati',
              iconName: 'privacy_tip',
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Maxfiylik siyosati tez orada'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
            _buildActionItem(
              context: context,
              title: 'Hisobdan chiqish',
              iconName: 'logout',
              onTap: () => _showLogoutDialog(context),
              isDestructive: true,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}
