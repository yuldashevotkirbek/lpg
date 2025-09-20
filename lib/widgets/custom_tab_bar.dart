import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Tab item configuration for custom tab bar
class CustomTabItem {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final String? route;
  final VoidCallback? onTap;

  const CustomTabItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.route,
    this.onTap,
  });
}

/// Custom Tab Bar widget for LPG delivery application
/// Provides flexible tabbed navigation within screens
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CustomTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  final TabAlignment? tabAlignment;
  final EdgeInsets? labelPadding;
  final Color? indicatorColor;
  final double? indicatorWeight;
  final TabBarIndicatorSize? indicatorSize;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.onTap,
    this.isScrollable = false,
    this.tabAlignment,
    this.labelPadding,
    this.indicatorColor,
    this.indicatorWeight,
    this.indicatorSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.tabBarTheme.labelColor != null
            ? colorScheme.surface
            : colorScheme.primary,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        tabs: tabs.map((tab) => _buildTab(context, tab)).toList(),
        onTap: (index) {
          HapticFeedback.lightImpact();
          _handleTabTap(context, index);
        },
        isScrollable: isScrollable,
        tabAlignment: tabAlignment,
        labelPadding:
        labelPadding ?? const EdgeInsets.symmetric(horizontal: 16.0),
        indicatorColor: indicatorColor ??
            theme.tabBarTheme.indicatorColor ??
            colorScheme.primary,
        indicatorWeight: indicatorWeight ?? 3.0,
        indicatorSize: indicatorSize ??
            theme.tabBarTheme.indicatorSize ??
            TabBarIndicatorSize.label,
        labelColor: theme.tabBarTheme.labelColor ?? colorScheme.primary,
        unselectedLabelColor: theme.tabBarTheme.unselectedLabelColor ??
            colorScheme.onSurface.withAlpha(153),
        labelStyle: theme.tabBarTheme.labelStyle ??
            theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        unselectedLabelStyle: theme.tabBarTheme.unselectedLabelStyle ??
            theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w400,
            ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, CustomTabItem tab) {
    if (tab.icon != null || tab.customIcon != null) {
      return Tab(
        icon: tab.customIcon ?? Icon(tab.icon),
        text: tab.label,
      );
    }

    return Tab(text: tab.label);
  }

  void _handleTabTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    final tab = tabs[index];

    // Handle custom onTap callback
    if (tab.onTap != null) {
      tab.onTap!();
      return;
    }

    // Handle route navigation
    if (tab.route != null) {
      Navigator.pushNamed(context, tab.route!);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

/// Segmented Tab Bar for category selection
class CustomSegmentedTabBar extends StatelessWidget {
  final List<CustomTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final EdgeInsets margin;
  final double height;

  const CustomSegmentedTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.onTap,
    this.margin = const EdgeInsets.all(16.0),
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = currentIndex == index;

          return Expanded(
            child: _buildSegmentedTab(context, tab, index, isSelected),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSegmentedTab(
      BuildContext context, CustomTabItem tab, int index, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _handleTabTap(context, index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: colorScheme.primary.withAlpha(51),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.icon != null || tab.customIcon != null) ...[
                tab.customIcon ??
                    Icon(
                      tab.icon,
                      size: 18,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  tab.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTabTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    final tab = tabs[index];

    // Handle custom onTap callback
    if (tab.onTap != null) {
      tab.onTap!();
      return;
    }

    // Handle route navigation
    if (tab.route != null) {
      Navigator.pushNamed(context, tab.route!);
    }
  }
}

/// Chip-style Tab Bar for filters and categories
class CustomChipTabBar extends StatelessWidget {
  final List<CustomTabItem> tabs;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final EdgeInsets padding;
  final double spacing;
  final bool scrollable;

  const CustomChipTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.spacing = 8.0,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Wrap(
      spacing: spacing,
      children: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        final isSelected = currentIndex == index;

        return _buildChipTab(context, tab, index, isSelected);
      }).toList(),
    );

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = currentIndex == index;

            return Padding(
              padding:
              EdgeInsets.only(right: index < tabs.length - 1 ? spacing : 0),
              child: _buildChipTab(context, tab, index, isSelected),
            );
          }).toList(),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: content,
    );
  }

  Widget _buildChipTab(
      BuildContext context, CustomTabItem tab, int index, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tab.icon != null || tab.customIcon != null) ...[
            tab.customIcon ??
                Icon(
                  tab.icon,
                  size: 16,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
            const SizedBox(width: 6),
          ],
          Text(tab.label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.lightImpact();
          _handleTabTap(context, index);
        }
      },
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.outline.withAlpha(77),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  void _handleTabTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    final tab = tabs[index];

    // Handle custom onTap callback
    if (tab.onTap != null) {
      tab.onTap!();
      return;
    }

    // Handle route navigation
    if (tab.route != null) {
      Navigator.pushNamed(context, tab.route!);
    }
  }
}
