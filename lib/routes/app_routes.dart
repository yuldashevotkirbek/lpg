import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/product_catalog/product_catalog.dart';
import '../presentation/order_tracking/order_tracking.dart';
import '../presentation/product_catalog/product_detail.dart';
import '../presentation/order_tracking/map_view.dart';
import '../presentation/news_list/news_list.dart';
import '../presentation/cart/cart_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String userProfile = '/user-profile';
  static const String registration = '/registration-screen';
  static const String productCatalog = '/product-catalog';
  static const String orderTracking = '/order-tracking';
  static const String productDetail = '/product-detail';
  static const String mapView = '/map-view';
  static const String newsList = '/news-list';
  static const String cart = '/cart';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    userProfile: (context) => const UserProfile(),
    registration: (context) => const RegistrationScreen(),
    productCatalog: (context) => const ProductCatalog(),
    orderTracking: (context) => const OrderTracking(),
    productDetail: (context) => const ProductDetail(),
    mapView: (context) => const MapView(),
    newsList: (context) => const NewsList(),
    // TODO: Add your other routes here
  };
}
