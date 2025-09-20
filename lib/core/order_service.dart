import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new order
  static Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required String phoneNumber,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderId = _generateOrderId();
      final now = DateTime.now();

      final orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'items': items,
        'deliveryAddress': deliveryAddress,
        'phoneNumber': phoneNumber,
        'notes': notes ?? '',
        'status': 'pending',
        'totalAmount': _calculateTotal(items),
        'deliveryFee': 15000, // Fixed delivery fee
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'estimatedDelivery': Timestamp.fromDate(now.add(Duration(minutes: 30))),
      };

      await _firestore.collection('orders').doc(orderId).set(orderData);

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  // Get user's orders
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting user orders: $e');
      return [];
    }
  }

  // Get current active order
  static Future<Map<String, dynamic>?> getCurrentOrder() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final querySnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where(
            'status',
            whereIn: ['pending', 'confirmed', 'preparing', 'out_for_delivery'],
          )
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        data['id'] = querySnapshot.docs.first.id;
        return data;
      }

      return null;
    } catch (e) {
      print('Error getting current order: $e');
      return null;
    }
  }

  // Update order status
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  // Cancel order
  static Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }

  // Helper methods
  static String _generateOrderId() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (now.millisecondsSinceEpoch % 10000).toString().padLeft(
      4,
      '0',
    );
    return 'PG$year$month$day$random';
  }

  static int _calculateTotal(List<Map<String, dynamic>> items) {
    int total = 0;
    for (final item in items) {
      final price = item['price'] as int;
      final quantity = item['quantity'] as int;
      total += price * quantity;
    }
    return total;
  }

  // Get order by ID
  static Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting order by ID: $e');
      return null;
    }
  }
}
