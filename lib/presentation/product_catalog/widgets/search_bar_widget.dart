import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool showFilter;

  const SearchBarWidget({
    super.key,
    this.initialValue,
    this.onChanged,
    this.onFilterTap,
    this.showFilter = true,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 12.w,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _isSearching = value.isNotEmpty;
                  });
                  widget.onChanged?.call(value);
                },
                decoration: InputDecoration(
                  hintText: 'Mahsulotlarni qidiring...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
              color: colorScheme.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _controller.clear();
                      setState(() {
                        _isSearching = false;
                      });
                      widget.onChanged?.call('');
                    },
                    icon: CustomIconWidget(
                      iconName: 'clear',
                      color: colorScheme.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 3.w,
                  ),
                ),
                style: theme.textTheme.bodyMedium,
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          if (widget.showFilter) ...[
            SizedBox(width: 3.w),
            Container(
              height: 12.w,
              width: 12.w,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onFilterTap?.call();
                },
                icon: CustomIconWidget(
                  iconName: 'tune',
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
