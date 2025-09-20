import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/auth_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/delivery_map_widget.dart';
import './widgets/driver_card_widget.dart';
import './widgets/estimated_arrival_widget.dart';
import './widgets/order_details_widget.dart';
import './widgets/order_progress_widget.dart';
import './widgets/rating_dialog_widget.dart';

class OrderTracking extends StatefulWidget {
  const OrderTracking({super.key});

  @override
  State<OrderTracking> createState() => _OrderTrackingState();
}

class _OrderTrackingState extends State<OrderTracking>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  bool _isRefreshing = false;

  // Mock data for order tracking
  final List<Map<String, dynamic>> _orderStages = [
    {
      'title': 'Buyurtma tasdiqlandi',
      'description': 'Buyurtmangiz qabul qilindi va tasdiqlanmoqda',
      'timestamp': '19/09/2025 14:30',
      'status': 'completed',
    },
    {
      'title': 'Buyurtma tayyorlanmoqda',
      'description': 'Mahsulotlar yig\'ilmoqda va tekshirilmoqda',
      'timestamp': '19/09/2025 15:15',
      'status': 'completed',
    },
    {
      'title': 'Yetkazib berish uchun jo\'natildi',
      'description': 'Haydovchi buyurtmangizni olib kelmoqda',
      'timestamp': '19/09/2025 16:00',
      'status': 'active',
    },
    {
      'title': 'Yetkazib berildi',
      'description': 'Buyurtma muvaffaqiyatli yetkazib berildi',
      'timestamp': null,
      'status': 'pending',
    },
  ];

  final Map<String, dynamic> _driverInfo = {
    'name': 'Akmal Karimov',
    'avatar':
        'https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'rating': 4.8,
    'totalTrips': 245,
    'phone': '+998 90 123 45 67',
    'vehicleModel': 'Isuzu NPR',
    'plateNumber': '01A789BC',
    'vehicleColor': 'oq',
  };

  final Map<String, dynamic> _orderData = {
    'orderNumber': 'PG2025091901',
    'status': 'out_for_delivery',
    'estimatedArrival': DateTime.now().add(const Duration(minutes: 25)),
    'items': [
      {
        'name': '12kg LPG Gaz Balloni',
        'quantity': 2,
        'price': 85000,
        'image':
            'https://images.pexels.com/photos/5025639/pexels-photo-5025639.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      },
      {
        'name': '5kg LPG Gaz Balloni',
        'quantity': 1,
        'price': 45000,
        'image':
            'https://images.pexels.com/photos/5025639/pexels-photo-5025639.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
      },
    ],
    'subtotal': 215000,
    'deliveryFee': 15000,
    'totalAmount': 230000,
    'deliveryAddress': {
      'street': 'Amir Temur ko\'chasi, 15-uy',
      'city': 'Toshkent',
      'region': 'Toshkent viloyati',
    },
  };

  final LatLng _driverLocation = const LatLng(41.2995, 69.2401);
  final LatLng _deliveryLocation = const LatLng(41.3111, 69.2797);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLocationUpdates();
  }

  void _initializeAnimations() {
    _refreshController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  void _startLocationUpdates() {
    // Simulate real-time location updates every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _orderData['status'] == 'out_for_delivery') {
        _updateDriverLocation();
        _startLocationUpdates();
      }
    });
  }

  void _updateDriverLocation() {
    setState(() {
      // Simulate driver movement
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.isAuthenticated) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Buyurtmalarni ko\'rish uchun ro\'yxatdan o\'ting yoki tizimga kiring',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration-screen');
                  },
                  child: const Text('Ro\'yxatdan o\'tish / Kirish'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _refreshOrderStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              _buildOrderHeader(context),
              SizedBox(height: 2.h),
              OrderProgressWidget(
                orderStages: _orderStages,
                currentStageIndex: 2,
              ),
              if (_shouldShowDriverCard())
                DriverCardWidget(
                  driverInfo: _driverInfo,
                  onCallDriver: _callDriver,
                ),
              if (_shouldShowMap())
                DeliveryMapWidget(
                  driverLocation: _driverLocation,
                  deliveryLocation: _deliveryLocation,
                  onExpandMap: _expandMap,
                ),
              EstimatedArrivalWidget(
                estimatedTime: _orderData['estimatedArrival'] as DateTime,
                status: _getStatusText(_orderData['status'] as String),
              ),
              OrderDetailsWidget(orderData: _orderData),
              ActionButtonsWidget(
                orderStatus: _orderData['status'] as String,
                onCallDriver: _callDriver,
                onCallSupport: _callSupport,
                onCancelOrder: _cancelOrder,
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        'Buyurtmani kuzatish',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimary,
        ),
      ),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      leading: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        icon: CustomIconWidget(
          iconName: 'arrow_back_ios',
          color: colorScheme.onPrimary,
          size: 6.w,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _shareOrder,
          icon: CustomIconWidget(
            iconName: 'share',
            color: colorScheme.onPrimary,
            size: 6.w,
          ),
          tooltip: 'Buyurtmani ulashish',
        ),
        IconButton(
          onPressed: _refreshOrderStatus,
          icon: AnimatedBuilder(
            animation: _refreshController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _refreshController.value * 2 * 3.14159,
                child: CustomIconWidget(
                  iconName: 'refresh',
                  color: colorScheme.onPrimary,
                  size: 6.w,
                ),
              );
            },
          ),
          tooltip: 'Yangilash',
        ),
      ],
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'local_shipping',
              color: colorScheme.onPrimary,
              size: 8.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buyurtma #${_orderData['orderNumber']}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _getStatusText(_orderData['status'] as String),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Faol',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDriverCard() {
    return ['out_for_delivery', 'dispatched'].contains(_orderData['status']);
  }

  bool _shouldShowMap() {
    return ['out_for_delivery', 'dispatched'].contains(_orderData['status']);
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Tasdiqlandi';
      case 'prepared':
        return 'Tayyorlanmoqda';
      case 'out_for_delivery':
        return 'Yetkazib berilmoqda';
      case 'delivered':
        return 'Yetkazib berildi';
      case 'cancelled':
        return 'Bekor qilindi';
      default:
        return 'Noma\'lum holat';
    }
  }

  Future<void> _refreshOrderStatus() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshController.forward();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
      _refreshController.reset();

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buyurtma holati yangilandi'),
          duration: Duration(seconds: 2),
        ),
      );

      // Check if order is delivered and show rating dialog
      if (_orderData['status'] == 'delivered') {
        _showRatingDialog();
      }
    }
  }

  void _callDriver() {
    HapticFeedback.lightImpact();
    // Implement call driver functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Haydovchiga qo\'ng\'iroq qilinmoqda: ${_driverInfo['phone']}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _callSupport() {
    HapticFeedback.lightImpact();
    // Implement call support functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Qo\'llab-quvvatlash xizmatiga qo\'ng\'iroq qilinmoqda...',
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _cancelOrder() {
    HapticFeedback.lightImpact();
    // Implement cancel order functionality
    setState(() {
      _orderData['status'] = 'cancelled';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buyurtma bekor qilindi'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _shareOrder() {
    HapticFeedback.lightImpact();
    // Implement share order functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Buyurtma ma\'lumotlari ulashildi'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _expandMap() {
    HapticFeedback.lightImpact();
    // Navigate to full-screen map view
    Navigator.pushNamed(context, '/map-view');
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RatingDialogWidget(
          onSubmitRating: () {
            // Handle rating submission
          },
          onSkip: () {
            // Handle skip rating
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
