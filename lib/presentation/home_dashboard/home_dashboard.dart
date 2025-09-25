import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../core/auth_service.dart';
import '../../core/order_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/delivery_status_card.dart';
import './widgets/news_section.dart';
import './widgets/product_categories_grid.dart';
import './widgets/quick_action_buttons.dart';
import './widgets/recent_orders_section.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _notificationCount = 0;
  Map<String, dynamic>? _currentOrder;
  List<Map<String, dynamic>> _recentOrders = [];
  bool _isLoading = true;

  // Yangiliklar/aksiyalar – test kontent yo'q, bo'sh ro'yxat
  final List<Map<String, dynamic>> _newsItems = [];

  // Kategoriyalar – minimal, so'zsiz narx ko'rsatmaymiz (narxlar katalogda)
  final List<Map<String, dynamic>> _productCategories = [
    {"id": 1, "name": "5 kg balon", "imageUrl": null},
    {"id": 2, "name": "10 kg balon", "imageUrl": null},
    {"id": 3, "name": "27 kg balon", "imageUrl": null},
    {"id": 4, "name": "50 kg balon", "imageUrl": null},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      if (!AuthService.isAuthenticated) {
        setState(() {
          _currentOrder = null;
          _recentOrders = [];
          _isLoading = false;
        });
        return;
      }

      // Load current active order
      final currentOrder = await OrderService.getCurrentOrder();

      // Load recent orders
      final allOrders = await OrderService.getUserOrders();
      final recentOrders = allOrders.take(3).toList();

      setState(() {
        _currentOrder = currentOrder;
        _recentOrders = recentOrders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomHomeAppBar(
          greeting: _getGreeting(),
          userName: AuthService.isAuthenticated
          ? (AuthService.currentUser?.displayName?.isNotEmpty == true 
              ? AuthService.currentUser!.displayName! 
                : "Foydalanuvchi")
            : "Mehmon",
          notificationCount: _notificationCount,
          onNotificationPressed: () {
            Navigator.pushNamed(context, '/order-tracking');
          },
          onSearchPressed: () {
            Navigator.pushNamed(context, '/product-catalog');
          },
        ),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: BottomNavItem.home,
          onTap: (item) {
            switch (item) {
              case BottomNavItem.home:
                break;
              case BottomNavItem.products:
                Navigator.pushReplacementNamed(context, '/product-catalog');
                break;
              case BottomNavItem.orders:
                if (!AuthService.isAuthenticated) {
                  Navigator.pushNamed(context, '/registration-screen');
                  return;
                }
                Navigator.pushReplacementNamed(context, '/order-tracking');
                break;
              case BottomNavItem.profile:
                if (!AuthService.isAuthenticated) {
                  Navigator.pushNamed(context, '/registration-screen');
                  return;
                }
                Navigator.pushReplacementNamed(context, '/user-profile');
                break;
            }
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomHomeAppBar(
        greeting: _getGreeting(),
        userName: AuthService.isAuthenticated
            ? (AuthService.currentUser?.displayName?.isNotEmpty == true 
                ? AuthService.currentUser!.displayName! 
                : "Foydalanuvchi")
            : "Mehmon",
        notificationCount: _notificationCount,
        onNotificationPressed: () {
          Navigator.pushNamed(context, '/order-tracking');
        },
        onSearchPressed: () {
          Navigator.pushNamed(context, '/product-catalog');
        },
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: colorScheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 1.h),

                  // Delivery Status Card - only show if there's an active order
                  if (_currentOrder != null)
                    DeliveryStatusCard(
                      currentOrder: _currentOrder,
                      onTap: () {
                        Navigator.pushNamed(context, '/order-tracking');
                      },
                    ),

                  SizedBox(height: 2.h),

                  // Quick Action Buttons
                  QuickActionButtons(
                    onReorderLast: _handleReorderLast,
                    onScheduleDelivery: _handleScheduleDelivery,
                  ),

                  SizedBox(height: 3.h),

                  // News Section
                  NewsSection(
                    newsItems: _newsItems,
                    onNewsItemTap: _handleNewsItemTap,
                  ),

                  SizedBox(height: 3.h),

                  // Product Categories Grid
                  ProductCategoriesGrid(
                    categories: _productCategories,
                    onCategoryTap: _handleCategoryTap,
                  ),

                  SizedBox(height: 3.h),

                  // Recent Orders Section - only show if there are orders
                  if (_recentOrders.isNotEmpty)
                    RecentOrdersSection(
                      recentOrders: _recentOrders,
                      onOrderTap: _handleOrderTap,
                      onReorderTap: _handleReorderTap,
                      onTrackTap: _handleTrackTap,
                      onRateTap: _handleRateTap,
                    ),

                  SizedBox(height: 10.h), // Bottom padding for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pushNamed(context, '/product-catalog');
        },
        icon: CustomIconWidget(
          iconName: 'add_shopping_cart',
          color: colorScheme.onSecondary,
          size: 24,
        ),
        label: Text(
          'Buyurtma berish',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: BottomNavItem.home,
        onTap: (item) {
          switch (item) {
            case BottomNavItem.home:
              // already here
              break;
            case BottomNavItem.products:
              Navigator.pushReplacementNamed(context, '/product-catalog');
              break;
            case BottomNavItem.orders:
              if (!AuthService.isAuthenticated) {
                Navigator.pushNamed(context, '/registration-screen');
                return;
              }
              Navigator.pushReplacementNamed(context, '/order-tracking');
              break;
            case BottomNavItem.profile:
              if (!AuthService.isAuthenticated) {
                Navigator.pushNamed(context, '/registration-screen');
                return;
              }
              Navigator.pushReplacementNamed(context, '/user-profile');
              break;
          }
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Xayrli tong,';
    } else if (hour < 17) {
      return 'Xayrli kun,';
    } else {
      return 'Xayrli kech,';
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });

    await _loadOrders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ma\'lumotlar yangilandi'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleReorderLast() {
    if (_recentOrders.isNotEmpty) {
      final lastOrder = _recentOrders.first;
      _showReorderDialog(lastOrder);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avvalgi buyurtmalar topilmadi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Shoshilinch gaz funksiyasi talab bo'yicha olib tashlandi

  void _handleScheduleDelivery() {
    Navigator.pushNamed(context, '/product-catalog');
  }

  void _handleNewsItemTap(Map<String, dynamic> newsItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newsItem["title"] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (newsItem["imageUrl"] != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: newsItem["imageUrl"] as String,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 2.h),
            ],
            Text('Sana: ${newsItem["date"]}'),
            SizedBox(height: 1.h),
            Text('Kategoriya: ${newsItem["category"]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Yopish'),
          ),
        ],
      ),
    );
  }

  void _handleCategoryTap(Map<String, dynamic> category) {
    Navigator.pushNamed(context, '/product-catalog');
  }

  void _handleOrderTap(Map<String, dynamic> order) {
    Navigator.pushNamed(context, '/order-tracking');
  }

  void _handleReorderTap(Map<String, dynamic> order) {
    _showReorderDialog(order);
  }

  void _handleTrackTap(Map<String, dynamic> order) {
    Navigator.pushNamed(context, '/order-tracking');
  }

  void _handleRateTap(Map<String, dynamic> order) {
    _showRatingDialog(order);
  }

  void _showReorderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buyurtmani takrorlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buyurtma: #${order["orderNumber"]}'),
            SizedBox(height: 1.h),
            Text('Mahsulot: ${order["productName"]}'),
            SizedBox(height: 1.h),
            Text('Miqdor: ${order["quantity"]}'),
            SizedBox(height: 1.h),
            Text('Narx: ${order["totalPrice"]}'),
            SizedBox(height: 2.h),
            Text('Ushbu buyurtmani takrorlashni xohlaysizmi?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/product-catalog');
            },
            child: Text('Takrorlash'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(Map<String, dynamic> order) {
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Xizmatni baholang'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Buyurtma #${order["orderNumber"]} uchun baho bering:'),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: CustomIconWidget(
                        iconName: index < rating ? 'star' : 'star_border',
                        color: AppTheme.warningLight,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Rahmat! Sizning bahongiz qabul qilindi.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text('Yuborish'),
            ),
          ],
        ),
      ),
    );
  }
}
