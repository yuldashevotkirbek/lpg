import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EstimatedArrivalWidget extends StatefulWidget {
  // Talab bo'yicha vaqt emas, faqat sana ko'rsatiladi
  final DateTime estimatedDate;
  final String status;

  const EstimatedArrivalWidget({
    super.key,
    required this.estimatedDate,
    required this.status,
  });

  @override
  State<EstimatedArrivalWidget> createState() => _EstimatedArrivalWidgetState();
}

class _EstimatedArrivalWidgetState extends State<EstimatedArrivalWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _daysRemaining = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateDaysRemaining();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _updateDaysRemaining() {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = DateTime(
      widget.estimatedDate.year,
      widget.estimatedDate.month,
      widget.estimatedDate.day,
    );
    final difference = end.difference(start).inDays;

    setState(() {
      if (difference < 0) {
        _daysRemaining = 'Kechikdi';
      } else if (difference == 0) {
        _daysRemaining = 'Bugun';
      } else if (difference == 1) {
        _daysRemaining = 'Ertaga';
      } else {
        _daysRemaining = '$difference kun';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'access_time',
                        color: colorScheme.onPrimary,
                        size: 6.w,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Taxminiy yetib kelish kuni',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _formatDate(widget.estimatedDate),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeInfo(
                  context,
                  'Qolgan kun',
                  _daysRemaining,
                  CustomIconWidget(
                    iconName: 'timer',
                    color: colorScheme.secondary,
                    size: 5.w,
                  ),
                ),
                Container(
                  width: 1,
                  height: 8.h,
                  color: colorScheme.outline.withOpacity(0.2),
                ),
                _buildTimeInfo(
                  context,
                  'Holat',
                  widget.status,
                  CustomIconWidget(
                    iconName: 'info_outline',
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
      BuildContext context, String label, String value, Widget icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        children: [
          icon,
          SizedBox(height: 1.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
