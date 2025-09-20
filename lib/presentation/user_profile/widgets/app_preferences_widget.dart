import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppPreferencesWidget extends StatefulWidget {
  final bool orderNotifications;
  final bool promotionNotifications;
  final bool deliveryReminders;
  final String selectedLanguage;
  final Function(bool) onOrderNotificationsChanged;
  final Function(bool) onPromotionNotificationsChanged;
  final Function(bool) onDeliveryRemindersChanged;
  final Function(String) onLanguageChanged;

  const AppPreferencesWidget({
    super.key,
    required this.orderNotifications,
    required this.promotionNotifications,
    required this.deliveryReminders,
    required this.selectedLanguage,
    required this.onOrderNotificationsChanged,
    required this.onPromotionNotificationsChanged,
    required this.onDeliveryRemindersChanged,
    required this.onLanguageChanged,
  });

  @override
  State<AppPreferencesWidget> createState() => _AppPreferencesWidgetState();
}

class _AppPreferencesWidgetState extends State<AppPreferencesWidget> {
  void _showLanguageSelector() {
    final languages = [
      {'code': 'uz_cyrl', 'name': 'O\'zbekcha (Кирилл)', 'flag': '🇺🇿'},
      {'code': 'uz_latn', 'name': 'O\'zbekcha (Lotin)', 'flag': '🇺🇿'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 0.5.h,
                margin: EdgeInsets.only(top: 1.h),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Text(
                      'Tilni tanlang',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 3.h),
                    ...languages
                        .map((language) => _buildLanguageOption(language)),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(Map<String, String> language) {
    final isSelected = widget.selectedLanguage == language['code'];

    return ListTile(
      leading: Text(
        language['flag']!,
        style: TextStyle(fontSize: 24),
      ),
      title: Text(
        language['name']!,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? CustomIconWidget(
        iconName: 'check_circle',
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      )
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onLanguageChanged(language['code']!);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Til o\'zgartirildi: ${language['name']}'),
            backgroundColor: AppTheme.getSuccessColor(
                Theme.of(context).brightness == Brightness.light),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required String iconName,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withOpacity(0.6),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          HapticFeedback.lightImpact();
          onChanged(newValue);
        },
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 1.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguageName = widget.selectedLanguage == 'uz_cyrl'
        ? 'O\'zbekcha (Кирилл)'
        : 'O\'zbekcha (Lotin)';

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
                  iconName: 'settings',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Ilova sozlamalari',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            // Notification Preferences
            Text(
              'Bildirishnomalar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.h),
            _buildPreferenceSwitch(
              title: 'Buyurtma yangiliklari',
              subtitle: 'Buyurtma holati haqida bildirishnomalar',
              iconName: 'shopping_bag',
              value: widget.orderNotifications,
              onChanged: widget.onOrderNotificationsChanged,
            ),
            _buildPreferenceSwitch(
              title: 'Aksiyalar va chegirmalar',
              subtitle: 'Yangi aksiyalar haqida xabarlar',
              iconName: 'local_offer',
              value: widget.promotionNotifications,
              onChanged: widget.onPromotionNotificationsChanged,
            ),
            _buildPreferenceSwitch(
              title: 'Yetkazib berish eslatmalari',
              subtitle: 'Yetkazib berish vaqti haqida eslatmalar',
              iconName: 'delivery_dining',
              value: widget.deliveryReminders,
              onChanged: widget.onDeliveryRemindersChanged,
            ),
            SizedBox(height: 3.h),
            // Language Preference
            Text(
              'Til sozlamalari',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 1.h),
            ListTile(
              leading: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'language',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(
                'Ilova tili',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                selectedLanguageName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4),
                size: 16,
              ),
              onTap: _showLanguageSelector,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 0, vertical: 1.h),
            ),
          ],
        ),
      ),
    );
  }
}
