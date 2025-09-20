import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SkeletonCardWidget extends StatefulWidget {
  const SkeletonCardWidget({super.key});

  @override
  State<SkeletonCardWidget> createState() => _SkeletonCardWidgetState();
}

class _SkeletonCardWidgetState extends State<SkeletonCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    color: colorScheme.outline
                        .withValues(alpha: _animation.value * 0.3),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton
                      Container(
                        height: 4.w,
                        width: 70.w,
                        decoration: BoxDecoration(
                          color: colorScheme.outline
                              .withValues(alpha: _animation.value * 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 2.w),
                      // Subtitle skeleton
                      Container(
                        height: 3.w,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: colorScheme.outline
                              .withValues(alpha: _animation.value * 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      // Price skeleton
                      Container(
                        height: 4.w,
                        width: 50.w,
                        decoration: BoxDecoration(
                          color: colorScheme.outline
                              .withValues(alpha: _animation.value * 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 2.w),
                      // Button skeleton
                      Container(
                        height: 8.w,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colorScheme.outline
                              .withValues(alpha: _animation.value * 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
