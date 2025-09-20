import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/account_actions_widget.dart';
import './widgets/app_preferences_widget.dart';
import './widgets/delivery_addresses_widget.dart';
import './widgets/personal_info_widget.dart';
import './widgets/profile_header_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final ScrollController _scrollController = ScrollController();

  // Real user data from Firebase
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      if (!AuthService.isAuthenticated) {
        setState(() {
          _userData = null;
          _isLoading = false;
        });
        return;
      }

      final userDoc = await AuthService.getUserData();
      if (userDoc != null && userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userData = {
            'userName': data['fullName'] ?? AuthService.currentUser?.displayName ?? 'Foydalanuvchi',
            'fullName': data['fullName'] ?? AuthService.currentUser?.displayName ?? 'Foydalanuvchi',
            'phoneNumber': data['phone'] ?? '',
            'email': data['email'] ?? AuthService.currentUser?.email ?? '',
            'profileImageUrl': data['photoUrl'] ?? AuthService.currentUser?.photoURL,
            'addresses': data['addresses'] ?? [],
            'preferences':
                data['preferences'] ??
                {
                  'orderNotifications': true,
                  'promotionNotifications': false,
                  'deliveryReminders': true,
                  'selectedLanguage': 'uz_latn',
                },
          };
          _isLoading = false;
        });
      } else {
        // If user document doesn't exist but user is authenticated,
        // create basic user data from Firebase Auth
        if (AuthService.currentUser != null) {
          setState(() {
            _userData = {
              'userName': AuthService.currentUser?.displayName ?? 'Foydalanuvchi',
              'fullName': AuthService.currentUser?.displayName ?? 'Foydalanuvchi',
              'phoneNumber': '',
              'email': AuthService.currentUser?.email ?? '',
              'profileImageUrl': AuthService.currentUser?.photoURL,
              'addresses': [],
              'preferences': {
                'orderNotifications': true,
                'promotionNotifications': false,
                'deliveryReminders': true,
                'selectedLanguage': 'uz_latn',
              },
            };
            _isLoading = false;
          });
          
          // Create user document in Firestore
          _createUserDocument();
        } else {
          setState(() {
            _userData = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil ma\'lumotlarini yuklashda xatolik yuz berdi'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() {
        _userData = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _createUserDocument() async {
    if (AuthService.currentUser == null) return;
    
    try {
      await AuthService.updateUserData({
        'fullName': _userData!['fullName'],
        'phone': _userData!['phoneNumber'],
        'email': _userData!['email'],
        'photoUrl': _userData!['profileImageUrl'],
        'addresses': _userData!['addresses'],
        'preferences': _userData!['preferences'],
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  void _updateUserName(String newName) {
    if (_userData != null) {
      setState(() {
        _userData!['userName'] = newName;
        _userData!['fullName'] = newName;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _updatePhoneNumber(String newPhone) {
    if (_userData != null) {
      setState(() {
        _userData!['phoneNumber'] = newPhone;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _updateProfileImage(String? imagePath) {
    if (_userData != null) {
      setState(() {
        _userData!['profileImageUrl'] = imagePath;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _updateFullName(String newFullName) {
    if (_userData != null) {
      setState(() {
        _userData!['fullName'] = newFullName;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _updateEmail(String newEmail) {
    if (_userData != null) {
      setState(() {
        _userData!['email'] = newEmail;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _addAddress(Map<String, dynamic> newAddress) {
    if (_userData != null) {
      setState(() {
        if (newAddress['isPrimary'] as bool) {
          // Set all other addresses as non-primary
          for (var address in (_userData!['addresses'] as List)) {
            address['isPrimary'] = false;
          }
        }
        (_userData!['addresses'] as List).add(newAddress);
        _hasUnsavedChanges = true;
      });
    }
  }

  void _deleteAddress(int index) {
    if (_userData != null) {
      setState(() {
        final addresses = _userData!['addresses'] as List;
        final wasRemovingPrimary = addresses[index]['isPrimary'] as bool;
        addresses.removeAt(index);

        // If we removed the primary address and there are still addresses left,
        // make the first one primary
        if (wasRemovingPrimary && addresses.isNotEmpty) {
          addresses[0]['isPrimary'] = true;
        }

        _hasUnsavedChanges = true;
      });
    }
  }

  void _setPrimaryAddress(int index) {
    if (_userData != null) {
      setState(() {
        final addresses = _userData!['addresses'] as List;
        // Set all addresses as non-primary
        for (var address in addresses) {
          address['isPrimary'] = false;
        }
        // Set selected address as primary
        addresses[index]['isPrimary'] = true;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _updateOrderNotifications(bool value) {
    if (_userData != null) {
      setState(() {
        (_userData!['preferences'] as Map)['orderNotifications'] = value;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _updatePromotionNotifications(bool value) {
    if (_userData != null) {
      setState(() {
        (_userData!['preferences'] as Map)['promotionNotifications'] = value;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _updateDeliveryReminders(bool value) {
    if (_userData != null) {
      setState(() {
        (_userData!['preferences'] as Map)['deliveryReminders'] = value;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _updateLanguage(String language) {
    if (_userData != null) {
      setState(() {
        (_userData!['preferences'] as Map)['selectedLanguage'] = language;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveUserData() async {
    if (_userData == null) return;

    try {
      await AuthService.updateUserData({
        'fullName': _userData!['fullName'],
        'phone': _userData!['phoneNumber'],
        'email': _userData!['email'],
        'photoUrl': _userData!['profileImageUrl'],
        'addresses': _userData!['addresses'],
        'preferences': _userData!['preferences'],
      });

      setState(() {
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ma\'lumotlar saqlandi'),
            backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Save user data error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ma\'lumotlarni saqlashda xatolik'),
            backgroundColor: AppTheme.errorLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleLogout() async {
    HapticFeedback.lightImpact();

    try {
      await AuthService.logOut();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/registration-screen',
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Muvaffaqiyatli chiqildi'),
            backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chiqishda xatolik yuz berdi'),
            backgroundColor: AppTheme.errorLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Saqlanmagan o\'zgarishlar'),
          content: Text(
            'O\'zgarishlaringiz saqlanmagan. Chiqishni xohlaysizmi?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context, true);
                await _saveUserData();
              },
              child: Text('Saqlab chiqish'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Chiqish'),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: BottomNavItem.profile,
          onTap: (item) {
            switch (item) {
              case BottomNavItem.home:
                Navigator.pushReplacementNamed(context, '/home-dashboard');
                break;
              case BottomNavItem.products:
                Navigator.pushReplacementNamed(context, '/product-catalog');
                break;
              case BottomNavItem.orders:
                Navigator.pushReplacementNamed(context, '/order-tracking');
                break;
              case BottomNavItem.profile:
                break;
            }
          },
        ),
      );
    }

    if (!AuthService.isAuthenticated || _userData == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'person_outline',
                  color: Theme.of(context).colorScheme.primary,
                  size: 18.w,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Profil ma\'lumotlari mavjud emas',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Buyurtma berish yoki profilni ko\'rish uchun ro\'yxatdan o\'ting yoki tizimga kiring.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registration-screen');
                    },
                    child: const Text('Ro\'yxatdan o\'tish / Kirish'),
                  ),
                ),
                SizedBox(height: 1.h),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home-dashboard');
                  },
                  child: const Text('Bosh sahifaga qaytish'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: BottomNavItem.profile,
          onTap: (item) {
            switch (item) {
              case BottomNavItem.home:
                Navigator.pushReplacementNamed(context, '/home-dashboard');
                break;
              case BottomNavItem.products:
                Navigator.pushReplacementNamed(context, '/product-catalog');
                break;
              case BottomNavItem.orders:
                Navigator.pushReplacementNamed(context, '/order-tracking');
                break;
              case BottomNavItem.profile:
                // already here
                break;
            }
          },
        ),
      );
    }

    final preferences = _userData!['preferences'] as Map<String, dynamic>;
    final addresses = _userData!['addresses'] as List<Map<String, dynamic>>;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: ProfileHeaderWidget(
                userName: _userData!['userName'] as String,
                phoneNumber: _userData!['phoneNumber'] as String,
                profileImageUrl: _userData!['profileImageUrl'] as String?,
                onNameChanged: _updateUserName,
                onPhoneChanged: _updatePhoneNumber,
                onImageChanged: _updateProfileImage,
              ),
            ),

            // Personal Information
            SliverToBoxAdapter(
              child: PersonalInfoWidget(
                fullName: _userData!['fullName'] as String,
                email: _userData!['email'] as String,
                phoneNumber: _userData!['phoneNumber'] as String,
                onFullNameChanged: _updateFullName,
                onEmailChanged: _updateEmail,
                onPhoneChanged: _updatePhoneNumber,
              ),
            ),

            // Delivery Addresses
            SliverToBoxAdapter(
              child: DeliveryAddressesWidget(
                addresses: addresses,
                onAddressAdded: _addAddress,
                onAddressDeleted: _deleteAddress,
                onPrimaryChanged: _setPrimaryAddress,
              ),
            ),

            // App Preferences
            SliverToBoxAdapter(
              child: AppPreferencesWidget(
                orderNotifications: preferences['orderNotifications'] as bool,
                promotionNotifications:
                    preferences['promotionNotifications'] as bool,
                deliveryReminders: preferences['deliveryReminders'] as bool,
                selectedLanguage: preferences['selectedLanguage'] as String,
                onOrderNotificationsChanged: _updateOrderNotifications,
                onPromotionNotificationsChanged: _updatePromotionNotifications,
                onDeliveryRemindersChanged: _updateDeliveryReminders,
                onLanguageChanged: _updateLanguage,
              ),
            ),

            // Account Actions
            SliverToBoxAdapter(
              child: AccountActionsWidget(onLogout: _handleLogout),
            ),

            // Bottom spacing for floating bottom bar
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          ],
        ),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: BottomNavItem.profile,
          onTap: (item) {
            if (item != BottomNavItem.profile) {
              String route;
              switch (item) {
                case BottomNavItem.home:
                  route = '/home-dashboard';
                  break;
                case BottomNavItem.products:
                  route = '/product-catalog';
                  break;
                case BottomNavItem.orders:
                  route = '/order-tracking';
                  break;
                case BottomNavItem.profile:
                  return;
              }

              if (_hasUnsavedChanges) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Saqlanmagan o\'zgarishlar'),
                    content: Text(
                      'O\'zgarishlaringiz saqlanmagan. Davom etishni xohlaysizmi?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Bekor qilish'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            route,
                            (route) => false,
                          );
                        },
                        child: Text('Davom etish'),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  route,
                  (route) => false,
                );
              }
            }
          },
        ),
      ),
    );
  }
}
