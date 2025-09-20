import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum PasswordStrength { weak, medium, strong }

class PasswordStrengthWidget extends StatelessWidget {
  final String password;

  const PasswordStrengthWidget({
    super.key,
    required this.password,
  });

  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppTheme.lightTheme.colorScheme.error;
      case PasswordStrength.medium:
        return AppTheme.getWarningColor(true);
      case PasswordStrength.strong:
        return AppTheme.getSuccessColor(true);
    }
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Zaif';
      case PasswordStrength.medium:
        return 'O\'rtacha';
      case PasswordStrength.strong:
        return 'Kuchli';
    }
  }

  double _getStrengthProgress(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  List<String> _getRequirements() {
    return [
      'Kamida 8 ta belgi',
      'Katta va kichik harflar',
      'Kamida bitta raqam',
      'Maxsus belgi (!@#\$%^&*)',
    ];
  }

  bool _isRequirementMet(String requirement) {
    switch (requirement) {
      case 'Kamida 8 ta belgi':
        return password.length >= 8;
      case 'Katta va kichik harflar':
        return password.contains(RegExp(r'[a-z]')) &&
            password.contains(RegExp(r'[A-Z]'));
      case 'Kamida bitta raqam':
        return password.contains(RegExp(r'[0-9]'));
      case 'Maxsus belgi (!@#\$%^&*)':
        return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = _calculateStrength(password);
    final strengthColor = _getStrengthColor(strength);
    final strengthText = _getStrengthText(strength);
    final progress = _getStrengthProgress(strength);
    final requirements = _getRequirements();

    return Container(
      margin: EdgeInsets.only(top: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Parol kuchi: ',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              Text(
                strengthText,
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: strengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor:
            AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 4,
          ),
          SizedBox(height: 2.h),
          Text(
            'Talablar:',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          ...requirements.map((requirement) {
            final isMet = _isRequirementMet(requirement);
            return Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: isMet ? 'check_circle' : 'radio_button_unchecked',
                    color: isMet
                        ? AppTheme.getSuccessColor(true)
                        : AppTheme.lightTheme.colorScheme.outline,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      requirement,
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: isMet
                            ? AppTheme.lightTheme.colorScheme.onSurface
                            : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
