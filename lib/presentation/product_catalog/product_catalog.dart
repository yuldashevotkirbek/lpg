import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import '../../core/auth_service.dart';
import '../../core/order_service.dart';
import '../cart/cart_screen.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/floating_cart_widget.dart';
import './widgets/product_card_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/skeleton_card_widget.dart';

class ProductCatalog extends StatefulWidget {
  const ProductCatalog({super.key});

  @override
  State<ProductCatalog> createState() => _ProductCatalogState();
}

class _ProductCatalogState extends State<ProductCatalog> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  Map<String, dynamic> _filters = {};
  List<String> _activeFilterLabels = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  Map<String, int> _cartItems = {};
  Set<String> _favoriteIds = {};
  Map<String, String> _favoriteCategoryById = {};
  // Keeping for future pagination; currently unused
  // ignore: unused_field
  int _currentPage = 1;
  // final int _itemsPerPage = 10;

  // Mock product data
  final List<Map<String, dynamic>> _allProducts = [
    {
      "id": "1",
      "name": "Propan gaz baloni",
      "tankSize": "5",
      "price": "85,000 UZS",
      "priceValue": 85000,
      "availability": true,
      "image":
          "https://images.pexels.com/photos/4254557/pexels-photo-4254557.jpeg?auto=compress&cs=tinysrgb&w=800",
      "category": "Kichik balon",
    },
    {
      "id": "2",
      "name": "Propan gaz baloni",
      "tankSize": "12",
      "price": "165,000 UZS",
      "priceValue": 165000,
      "availability": true,
      "image":
          "https://images.pexels.com/photos/4254557/pexels-photo-4254557.jpeg?auto=compress&cs=tinysrgb&w=800",
      "category": "O'rta balon",
    },
    {
      "id": "3",
      "name": "Propan gaz baloni",
      "tankSize": "27",
      "price": "285,000 UZS",
      "priceValue": 285000,
      "availability": true,
      "image":
          "https://images.pexels.com/photos/4254557/pexels-photo-4254557.jpeg?auto=compress&cs=tinysrgb&w=800",
      "category": "Katta balon",
    },
    {
      "id": "4",
      "name": "Propan gaz baloni",
      "tankSize": "50",
      "price": "425,000 UZS",
      "priceValue": 425000,
      "availability": false,
      "image":
          "https://images.pexels.com/photos/4254557/pexels-photo-4254557.jpeg?auto=compress&cs=tinysrgb&w=800",
      "category": "Juda katta balon",
    },
    {
      "id": "5",
      "name": "Premium propan gaz",
      "tankSize": "12",
      "price": "185,000 UZS",
      "priceValue": 185000,
      "availability": true,
      "image":
          "https://images.pixabay.com/photo/2019/07/02/05/54/tool-4311573_1280.jpg",
      "category": "Premium",
    },
    {
      "id": "6",
      "name": "Uy uchun gaz baloni",
      "tankSize": "27",
      "price": "295,000 UZS",
      "priceValue": 295000,
      "availability": true,
      "image":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
      "category": "Uy uchun",
    },
    {
      "id": "7",
      "name": "Sanoat uchun gaz",
      "tankSize": "50",
      "price": "445,000 UZS",
      "priceValue": 445000,
      "availability": true,
      "image":
          "https://images.pexels.com/photos/4254557/pexels-photo-4254557.jpeg?auto=compress&cs=tinysrgb&w=800",
      "category": "Sanoat",
    },
    {
      "id": "8",
      "name": "Ekonom gaz baloni",
      "tankSize": "5",
      "price": "75,000 UZS",
      "priceValue": 75000,
      "availability": true,
      "image":
          "https://images.pixabay.com/photo/2019/07/02/05/54/tool-4311573_1280.jpg",
      "category": "Ekonom",
    },
  ];

  @override
  void initState() {
    super.initState();
    _products = List.from(_allProducts);
    _filteredProducts = List.from(_products);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more products
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    // Simulate refresh
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _products = List.from(_allProducts);
      _applyFilters();
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  // void _onFiltersChanged(Map<String, dynamic> filters) {
  //   setState(() {
  //     _filters = filters;
  //   });
  //   _updateActiveFilterLabels();
  //   _applyFilters();
  // }

  void _toggleFavorite(String productId) {
    final wasFav = _favoriteIds.contains(productId);
    setState(() {
      if (wasFav) {
        _favoriteIds.remove(productId);
        _favoriteCategoryById.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
    });

    if (!wasFav) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sevimlilarga qo\'shildi'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sevimlilardan olib tashlandi'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _updateActiveFilterLabels() {
    final labels = <String>[];

    if (_filters['tankSizes'] != null &&
        (_filters['tankSizes'] as List).isNotEmpty) {
      final sizes = (_filters['tankSizes'] as List<String>).join(', ');
      labels.add('$sizes kg');
    }

    if (_filters['minPrice'] != null && _filters['maxPrice'] != null) {
      final min = (_filters['minPrice'] as double).round();
      final max = (_filters['maxPrice'] as double).round();
      if (min != 50000 || max != 500000) {
        labels.add('$min - $max UZS');
      }
    }

    if (_filters['availability'] != null && _filters['availability'] != 'all') {
      final availability = _filters['availability'] as String;
      labels.add(availability == 'available' ? 'Mavjud' : 'Mavjud emas');
    }

    setState(() {
      _activeFilterLabels = labels;
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allProducts);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = (product['name'] as String).toLowerCase();
        final category = (product['category'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
    }

    // Apply tank size filter
    if (_filters['tankSizes'] != null &&
        (_filters['tankSizes'] as List).isNotEmpty) {
      final selectedSizes = _filters['tankSizes'] as List<String>;
      filtered = filtered.where((product) {
        return selectedSizes.contains(product['tankSize']);
      }).toList();
    }

    // Apply price range filter
    if (_filters['minPrice'] != null && _filters['maxPrice'] != null) {
      final minPrice = _filters['minPrice'] as double;
      final maxPrice = _filters['maxPrice'] as double;
      filtered = filtered.where((product) {
        final price = product['priceValue'] as int;
        return price >= minPrice && price <= maxPrice;
      }).toList();
    }

    // Apply availability filter
    if (_filters['availability'] != null && _filters['availability'] != 'all') {
      final availability = _filters['availability'] as String;
      filtered = filtered.where((product) {
        final isAvailable = product['availability'] as bool;
        return availability == 'available' ? isAvailable : !isAvailable;
      }).toList();
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _removeFilter(String filterLabel) {
    setState(() {
      _activeFilterLabels.remove(filterLabel);

      // Reset corresponding filter
      if (filterLabel.contains('kg')) {
        _filters['tankSizes'] = <String>[];
      } else if (filterLabel.contains('UZS')) {
        _filters['minPrice'] = 50000.0;
        _filters['maxPrice'] = 500000.0;
      } else if (filterLabel == 'Mavjud' || filterLabel == 'Mavjud emas') {
        _filters['availability'] = 'all';
      }
    });
    _applyFilters();
  }

  void _addToCart(String productId) {
    if (!AuthService.isAuthenticated) {
      _promptLogin();
      return;
    }

    setState(() {
      _cartItems[productId] = (_cartItems[productId] ?? 0) + 1;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mahsulot savatga qo\'shildi'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ko\'rish',
          onPressed: () {
            Navigator.pushNamed(context, '/order-tracking');
          },
        ),
      ),
    );
  }

  void _promptLogin() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ro\'yxatdan o\'tish talab qilinadi'),
        content: const Text(
          'Buyurtma berishdan oldin iltimos ro\'yxatdan o\'ting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/registration-screen');
            },
            child: const Text('Ro\'yxatdan o\'tish'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!AuthService.isAuthenticated) {
      _promptLogin();
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Savatcha bo\'sh. Avval mahsulot qo\'shing.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Prepare order items
      final List<Map<String, dynamic>> orderItems = [];
      for (final entry in _cartItems.entries) {
        final productId = entry.key;
        final quantity = entry.value;
        final product = _allProducts.firstWhere((p) => p['id'] == productId);

        orderItems.add({
          'productId': productId,
          'name': product['name'],
          'price': product['price'],
          'quantity': quantity,
          'image': product['imageUrl'],
        });
      }

      // Get user data for delivery
      final userDoc = await AuthService.getUserData();
      if (userDoc == null || !userDoc.exists) {
        throw Exception('Foydalanuvchi ma\'lumotlari topilmadi');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final deliveryAddress = userData['address'] ?? 'Manzil kiritilmagan';
      final phoneNumber = userData['phone'] ?? '';

      // Create order
      final orderId = await OrderService.createOrder(
        items: orderItems,
        deliveryAddress: deliveryAddress,
        phoneNumber: phoneNumber,
        notes: 'Savatchadan buyurtma',
      );

      // Clear cart
      setState(() {
        _cartItems.clear();
      });

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buyurtma #$orderId muvaffaqiyatli yaratildi!'),
          backgroundColor: AppTheme.getSuccessColor(true),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to home dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home-dashboard',
        (route) => false,
      );
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Buyurtma berishda xatolik: $e'),
          backgroundColor: AppTheme.errorLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _filters,
        onApplyFilters: (filters) {
          setState(() {
            _filters = filters;
          });
          _updateActiveFilterLabels();
          _applyFilters();
        },
      ),
    );
  }

  int get _totalCartItems {
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  String _getTotalPrice() {
    int total = 0;
    for (final entry in _cartItems.entries) {
      final productId = entry.key;
      final quantity = entry.value;
      final product = _allProducts.firstWhere((p) => p['id'] == productId);
      final price = product['price'] as int;
      total += price * quantity;
    }
    return '${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} so\'m';
  }

  String get _totalCartPrice {
    double total = 0;
    _cartItems.forEach((productId, quantity) {
      final product = _allProducts.firstWhere(
        (p) => p['id'] == productId,
        orElse: () => {'priceValue': 0},
      );
      total += (product['priceValue'] as int) * quantity;
    });
    return '${total.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} UZS';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          SizedBox(height: 2.h),
          SearchBarWidget(
            onChanged: _onSearchChanged,
            onFilterTap: _showFilterBottomSheet,
          ),
          if (_activeFilterLabels.isNotEmpty)
            FilterChipsWidget(
              activeFilters: _activeFilterLabels,
              onRemoveFilter: _removeFilter,
            ),
          Expanded(child: _buildProductGrid()),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: BottomNavItem.products,
        onTap: (item) {
          switch (item) {
            case BottomNavItem.home:
              Navigator.pushReplacementNamed(context, '/home-dashboard');
              break;
            case BottomNavItem.products:
              // already here
              break;
            case BottomNavItem.orders:
              if (!AuthService.isAuthenticated) {
                _promptLogin();
                return;
              }
              Navigator.pushReplacementNamed(context, '/order-tracking');
              break;
            case BottomNavItem.profile:
              if (!AuthService.isAuthenticated) {
                _promptLogin();
                return;
              }
              Navigator.pushReplacementNamed(context, '/user-profile');
              break;
          }
        },
      ),
      floatingActionButton: FloatingCartWidget(
        itemCount: _totalCartItems,
        totalPrice: _totalCartPrice,
        onTap: () {
          if (!AuthService.isAuthenticated) {
            _promptLogin();
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartScreen(
                cartItems: _cartItems,
                products: _allProducts,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return _buildSkeletonGrid();
    }

    if (_filteredProducts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 70.h,
            child: EmptyStateWidget(
              title: _searchQuery.isNotEmpty
                  ? 'Hech narsa topilmadi'
                  : 'Mahsulotlar yo\'q',
              subtitle: _searchQuery.isNotEmpty
                  ? 'Boshqa kalit so\'zlarni sinab ko\'ring yoki filtrlarni o\'zgartiring'
                  : 'Hozircha mahsulotlar mavjud emas',
              actionText: _searchQuery.isNotEmpty
                  ? 'Qidiruvni tozalash'
                  : 'Yangilash',
              onActionPressed: _searchQuery.isNotEmpty
                  ? () {
                      setState(() {
                        _searchQuery = '';
                      });
                      _applyFilters();
                    }
                  : _refreshProducts,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshProducts,
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(4.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(),
              crossAxisSpacing: 4.w,
              mainAxisSpacing: 4.w,
              childAspectRatio: 0.70,
            ),
            itemCount: _filteredProducts.length + (_isLoadingMore ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= _filteredProducts.length) {
                return const SkeletonCardWidget();
              }

              final product = _filteredProducts[index];
              final productId = product['id'] as String;
              final isInCart = _cartItems.containsKey(productId);
              final cartQuantity = _cartItems[productId] ?? 0;

              return ProductCardWidget(
                product: product,
                isInCart: isInCart,
                cartQuantity: cartQuantity,
                isFavorite: _favoriteIds.contains(productId),
                onTap: () {
                  // Navigate to product detail with hero animation
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: product,
                  );
                },
                onAddToCart: () => _addToCart(productId),
                onFavorite: () => _toggleFavorite(productId),
                onShare: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mahsulot ulashildi'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Floating cart widget
        FloatingCartWidget(
          itemCount: _totalCartItems,
          totalPrice: _getTotalPrice(),
          onTap: () {
            if (!AuthService.isAuthenticated) {
              _promptLogin();
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartScreen(
                  cartItems: _cartItems,
                  products: _allProducts,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 4.w,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const SkeletonCardWidget(),
    );
  }

  int _getCrossAxisCount() {
    if (100.w > 600) {
      return 3; // Tablet
    }
    return 2; // Phone
  }
}
