import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EstimatedArrivalWidget extends StatefulWidget {
  final DateTime estimatedTime;
  final String status;

  const EstimatedArrivalWidget({
    super.key,
    required this.estimatedTime,
    required this.status,
  });

  @override
  State<EstimatedArrivalWidget> createState() => _EstimatedArrivalWidgetState();
}

class _EstimatedArrivalWidgetState extends State<EstimatedArrivalWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateTimeRemaining();
    _startTimer();
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

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateTimeRemaining();
        _startTimer();
      }
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    final difference = widget.estimatedTime.difference(now);

    if (difference.isNegative) {
      setState(() {
        _timeRemaining = 'Kechikmoqda';
      });
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      setState(() {
        if (hours > 0) {
          _timeRemaining = '${hours}s ${minutes}d';
        } else {
          _timeRemaining = '${minutes}d';
        }
      });
    }
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
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
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
                      'Taxminiy yetib kelish vaqti',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _formatTime(widget.estimatedTime),
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
                  color: colorScheme.shadow.withValues(alpha: 0.05),
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
                  'Qolgan vaqt',
                  _timeRemaining,
                  CustomIconWidget(
                    iconName: 'timer',
                    color: colorScheme.secondary,
                    size: 5.w,
                  ),
                ),
                Container(
                  width: 1,
                  height: 8.h,
                  color: colorScheme.outline.withValues(alpha: 0.2),
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
              color: colorScheme.onSurface.withValues(alpha: 0.6),
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

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
