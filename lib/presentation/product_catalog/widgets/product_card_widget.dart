import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProductCardWidget extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isInCart;
  final int cartQuantity;
  final bool isFavorite;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.onShare,
    this.isInCart = false,
    this.cartQuantity = 0,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAvailable = (product["availability"] as bool?) ?? true;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showQuickActions(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductInfo(context),
                    const Spacer(),
                    _buildPriceAndCart(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAvailable = (product["availability"] as bool?) ?? true;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomImageWidget(
                  imageUrl: (product["image"] as String?) ?? "",
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (!isAvailable)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Text(
                        'Mavjud emas',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 2.w,
          right: 2.w,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onFavorite?.call();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomIconWidget(
                  iconName: isFavorite ? 'favorite' : 'favorite_border',
                  color: isFavorite ? Colors.red : colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        if (isInCart && cartQuantity > 0)
          Positioned(
            top: 2.w,
            left: 2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$cartQuantity',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    final theme = Theme.of(context);
    final tankSize = (product["tankSize"] as String?) ?? "";
    final name = (product["name"] as String?) ?? "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1.w),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'local_gas_station',
              color: theme.colorScheme.primary,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              '$tankSize kg',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceAndCart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final price = (product["price"] as String?) ?? "";
    final isAvailable = (product["availability"] as bool?) ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          price,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.w),
        SizedBox(
          width: double.infinity,
          height: 8.w,
          child: ElevatedButton(
            onPressed: isAvailable
                ? () {
                    HapticFeedback.lightImpact();
                    onAddToCart?.call();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              foregroundColor: isAvailable
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.5),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'add_shopping_cart',
                  color: isAvailable
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  isInCart ? 'Savatda' : 'Savatga qo\'shish',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 1.w,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 4.w),
            _buildQuickActionItem(
              context,
              icon: 'favorite_border',
              title: 'Sevimlilar ro\'yxatiga qo\'shish',
              onTap: () {
                Navigator.pop(context);
                onFavorite?.call();
              },
            ),
            _buildQuickActionItem(
              context,
              icon: 'share',
              title: 'Ulashish',
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            _buildQuickActionItem(
              context,
              icon: 'info_outline',
              title: 'Batafsil ma\'lumot',
              onTap: () {
                Navigator.pop(context);
                onTap?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 3.w, horizontal: 2.w),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            SizedBox(width: 4.w),
            Text(title, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
