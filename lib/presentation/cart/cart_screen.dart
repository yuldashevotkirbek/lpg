import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/auth_service.dart';
import '../../core/order_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';

class CartScreen extends StatefulWidget {
  final Map<String, int> cartItems;
  final List<Map<String, dynamic>> products;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.products,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Map<String, int> _cartItems;
  final TextEditingController _notesController = TextEditingController();
  String? _selectedAddress;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _cartItems = Map.from(widget.cartItems);
    _loadUserAddress();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _loadUserAddress() async {
    try {
      final userData = await AuthService.getUserData();
      if (userData != null && userData.exists) {
        final data = userData.data() as Map<String, dynamic>;
        final addresses = data['addresses'] as List<dynamic>?;
        if (addresses != null && addresses.isNotEmpty) {
          // Find primary address or use first one
          final primaryAddress = addresses.firstWhere(
            (addr) => addr['isPrimary'] == true,
            orElse: () => addresses.first,
          );
          setState(() {
            _selectedAddress = primaryAddress['fullAddress'];
          });
        }
      }
    } catch (e) {
      print('Error loading user address: $e');
    }
  }

  List<Map<String, dynamic>> get _cartProducts {
    return widget.products
        .where((product) => _cartItems.containsKey(product['id']))
        .map((product) => {
              ...product,
              'quantity': _cartItems[product['id']] ?? 0,
            })
        .toList();
  }

  int get _totalPrice {
    int total = 0;
    for (final product in _cartProducts) {
      total += (product['priceValue'] as int) * (product['quantity'] as int);
    }
    return total;
  }

  int get _totalItems {
    return _cartItems.values.fold(0, (sum, quantity) => sum + quantity);
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )} UZS';
  }

  void _updateQuantity(String productId, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        _cartItems.remove(productId);
      } else {
        _cartItems[productId] = newQuantity;
      }
    });
  }

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buyurtmani tasdiqlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Umumiy summa: ${_formatPrice(_totalPrice + 15000)}'),
            SizedBox(height: 1.h),
            Text('Yetkazib berish: ${_formatPrice(15000)}'),
            SizedBox(height: 1.h),
            if (_selectedAddress != null)
              Text('Manzil: $_selectedAddress')
            else
              Text('Manzil: Tanlanmagan', style: TextStyle(color: Colors.red)),
            SizedBox(height: 2.h),
            Text('Buyurtmangizni bermoqchimisiz?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: _selectedAddress != null ? _placeOrder : null,
            child: Text('Tasdiqlash'),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    if (!AuthService.isAuthenticated) {
      Navigator.pop(context); // Close confirmation dialog
      Navigator.pushNamed(context, '/registration-screen');
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Iltimos, yetkazib berish manzilini tanlang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Prepare order items
      final orderItems = _cartProducts.map((product) {
        return {
          'productId': product['id'],
          'name': product['name'],
          'tankSize': product['tankSize'],
          'price': product['priceValue'],
          'quantity': product['quantity'],
        };
      }).toList();

      final orderId = await OrderService.createOrder(
        items: orderItems,
        deliveryAddress: _selectedAddress!,
        phoneNumber: AuthService.currentUser?.phoneNumber ?? '',
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Close confirmation dialog
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/order-tracking',
          (route) => route.isFirst,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Buyurtma muvaffaqiyatli berildi! #$orderId'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error placing order: $e');
      if (mounted) {
        Navigator.pop(context); // Close confirmation dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Buyurtma berishda xatolik yuz berdi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_cartItems.isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: 'Savatcha'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'shopping_cart',
                color: colorScheme.primary.withAlpha(100),
                size: 20.w,
              ),
              SizedBox(height: 2.h),
              Text(
                'Savatcha bo\'sh',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Mahsulotlar qo\'shish uchun katalogga o\'ting',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/product-catalog',
                ),
                child: Text('Katalogga o\'tish'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Savatcha ($_totalItems ta)'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _cartProducts.length,
              itemBuilder: (context, index) {
                final product = _cartProducts[index];
                final quantity = product['quantity'] as int;
                final totalPrice = (product['priceValue'] as int) * quantity;

                return Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product['image'],
                            width: 20.w,
                            height: 20.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 20.w,
                              height: 20.w,
                              color: colorScheme.surfaceVariant,
                              child: Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${product['tankSize']} kg',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                _formatPrice(totalPrice),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _updateQuantity(
                                    product['id'],
                                    quantity - 1,
                                  ),
                                  icon: Icon(Icons.remove_circle_outline),
                                  color: colorScheme.primary,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 3.w,
                                    vertical: 1.w,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colorScheme.outline,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _updateQuantity(
                                    product['id'],
                                    quantity + 1,
                                  ),
                                  icon: Icon(Icons.add_circle_outline),
                                  color: colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Order notes
          Container(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Buyurtma haqida izoh (ixtiyoriy)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_add),
              ),
              maxLines: 2,
            ),
          ),
          // Order summary
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withAlpha(50),
              border: Border(
                top: BorderSide(color: colorScheme.outline.withAlpha(50)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mahsulotlar:'),
                    Text(_formatPrice(_totalPrice)),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Yetkazib berish:'),
                    Text(_formatPrice(15000)),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jami:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatPrice(_totalPrice + 15000),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isPlacingOrder ? null : _showOrderConfirmation,
                    child: _isPlacingOrder
                        ? CircularProgressIndicator(color: colorScheme.onPrimary)
                        : Text('Buyurtma berish'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
