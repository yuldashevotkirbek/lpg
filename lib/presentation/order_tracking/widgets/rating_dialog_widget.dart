import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RatingDialogWidget extends StatefulWidget {
  final VoidCallback? onSubmitRating;
  final VoidCallback? onSkip;

  const RatingDialogWidget({
    super.key,
    this.onSubmitRating,
    this.onSkip,
  });

  @override
  State<RatingDialogWidget> createState() => _RatingDialogWidgetState();
}

class _RatingDialogWidgetState extends State<RatingDialogWidget> {
  int _selectedRating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        constraints: BoxConstraints(
          maxWidth: 90.w,
          maxHeight: 80.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            SizedBox(height: 4.h),
            _buildRatingStars(context),
            SizedBox(height: 3.h),
            _buildFeedbackSection(context),
            SizedBox(height: 4.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color:
            AppTheme.getSuccessColor(theme.brightness == Brightness.light)
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'check_circle',
            color:
            AppTheme.getSuccessColor(theme.brightness == Brightness.light),
            size: 12.w,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Buyurtma yetkazildi!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Xizmatimizni baholang va fikr-mulohazangizni qoldiring',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRatingStars(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          'Xizmat sifatini baholang',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isSelected = starIndex <= _selectedRating;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedRating = starIndex;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                child: CustomIconWidget(
                  iconName: isSelected ? 'star' : 'star_border',
                  color: isSelected ? Colors.amber : colorScheme.outline,
                  size: 10.w,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 1.h),
        Text(
          _getRatingText(_selectedRating),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fikr-mulohaza (ixtiyoriy)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _feedbackController,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Xizmat haqida fikringizni yozing...',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: EdgeInsets.all(3.w),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting
                ? null
                : () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              if (widget.onSkip != null) {
                widget.onSkip!();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface.withOpacity(0.7),
              side: BorderSide(color: colorScheme.outline),
              padding: EdgeInsets.symmetric(vertical: 3.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Keyinroq',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton(
            onPressed:
            _isSubmitting || _selectedRating == 0 ? null : _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 3.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
              width: 5.w,
              height: 5.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
              ),
            )
                : Text(
              'Yuborish',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Juda yomon';
      case 2:
        return 'Yomon';
      case 3:
        return 'O\'rtacha';
      case 4:
        return 'Yaxshi';
      case 5:
        return 'Ajoyib';
      default:
        return 'Bahoni tanlang';
    }
  }

  void _submitRating() async {
    if (_selectedRating == 0) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bahoyingiz uchun rahmat!'),
          backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light),
          duration: const Duration(seconds: 3),
        ),
      );

      if (widget.onSubmitRating != null) {
        widget.onSubmitRating!();
      }
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
