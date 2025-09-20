import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom AppBar widget for LPG delivery application
/// Provides consistent navigation and branding across screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;
  final bool showNotificationIcon;
  final int notificationCount;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.onBackPressed,
    this.showNotificationIcon = false,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          color: foregroundColor ?? theme.appBarTheme.foregroundColor,
        ),
      ),
      leading: leading ??
          (automaticallyImplyLeading ? _buildLeading(context) : null),
      actions: _buildActions(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      elevation: elevation ?? theme.appBarTheme.elevation,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    if (!canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new),
      onPressed: () {
        HapticFeedback.lightImpact();
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          Navigator.of(context).pop();
        }
      },
      tooltip: 'Back',
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];

    // Add notification icon if enabled
    if (showNotificationIcon) {
      actionWidgets.add(_buildNotificationIcon(context));
    }

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    // Add profile/menu icon for main screens
    if (_shouldShowProfileIcon()) {
      actionWidgets.add(_buildProfileIcon(context));
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, '/order-tracking');
          },
          tooltip: 'Notifications',
        ),
        if (notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.account_circle_outlined),
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, '/user-profile');
      },
      tooltip: 'Profile',
    );
  }

  bool _shouldShowProfileIcon() {
    // Show profile icon on main screens
    final mainScreenTitles = [
      'Home',
      'Products',
      'Orders',
      'Dashboard',
    ];

    return mainScreenTitles.any((screenTitle) =>
        title.toLowerCase().contains(screenTitle.toLowerCase()));
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}

/// Specialized AppBar for home screen with search functionality
class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;
  final String userName;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onNotificationPressed;
  final int notificationCount;

  const CustomHomeAppBar({
    super.key,
    required this.greeting,
    required this.userName,
    this.onSearchPressed,
    this.onNotificationPressed,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      greeting,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withAlpha(204),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (onSearchPressed != null) {
                    onSearchPressed!();
                  } else {
                    Navigator.pushNamed(context, '/product-catalog');
                  }
                },
                tooltip: 'Search Products',
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (onNotificationPressed != null) {
                        onNotificationPressed!();
                      } else {
                        Navigator.pushNamed(context, '/order-tracking');
                      }
                    },
                    tooltip: 'Notifications',
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          notificationCount > 99
                              ? '99+'
                              : notificationCount.toString(),
                          style: TextStyle(
                            color: colorScheme.onSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
