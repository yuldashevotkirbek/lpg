import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/form_field_widget.dart';
import './widgets/password_strength_widget.dart';
import './widgets/profile_photo_widget.dart';
import './widgets/terms_checkbox_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  // Form state
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isTermsAccepted = false;
  bool _isFormValid = false;
  XFile? _selectedPhoto;

  // Field validation states
  bool _isFullNameValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isAddressValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '+998 ';
    _setupFormListeners();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupFormListeners() {
    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _addressController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid =
          _isFullNameValid &&
          _isEmailValid &&
          _isPhoneValid &&
          _isPasswordValid &&
          _isConfirmPasswordValid &&
          _isAddressValid &&
          _isTermsAccepted;
    });
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      _isFullNameValid = false;
      return 'To\'liq ismni kiriting';
    }
    if (value.trim().length < 2) {
      _isFullNameValid = false;
      return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
    }
    if (!RegExp(r'^[a-zA-ZА-Яа-яЁё\s]+$').hasMatch(value.trim())) {
      _isFullNameValid = false;
      return 'Ismda faqat harflar bo\'lishi mumkin';
    }
    _isFullNameValid = true;
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      _isEmailValid = false;
      return 'Email manzilini kiriting';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value.trim())) {
      _isEmailValid = false;
      return 'To\'g\'ri email manzilini kiriting';
    }
    _isEmailValid = true;
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      _isPhoneValid = false;
      return 'Telefon raqamini kiriting';
    }

    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!cleanPhone.startsWith('998')) {
      _isPhoneValid = false;
      return 'Telefon raqami +998 bilan boshlanishi kerak';
    }
    if (cleanPhone.length != 12) {
      _isPhoneValid = false;
      return 'Telefon raqami 9 ta raqamdan iborat bo\'lishi kerak';
    }

    _isPhoneValid = true;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      _isPasswordValid = false;
      return 'Parolni kiriting';
    }
    if (value.length < 8) {
      _isPasswordValid = false;
      return 'Parol kamida 8 ta belgidan iborat bo\'lishi kerak';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      _isPasswordValid = false;
      return 'Parolda kichik harf bo\'lishi kerak';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      _isPasswordValid = false;
      return 'Parolda katta harf bo\'lishi kerak';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      _isPasswordValid = false;
      return 'Parolda raqam bo\'lishi kerak';
    }

    _isPasswordValid = true;
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      _isConfirmPasswordValid = false;
      return 'Parolni tasdiqlang';
    }
    if (value != _passwordController.text) {
      _isConfirmPasswordValid = false;
      return 'Parollar mos kelmaydi';
    }

    _isConfirmPasswordValid = true;
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      _isAddressValid = false;
      return 'Yetkazib berish manzilini kiriting';
    }
    if (value.trim().length < 10) {
      _isAddressValid = false;
      return 'Manzil kamida 10 ta belgidan iborat bo\'lishi kerak';
    }

    _isAddressValid = true;
    return null;
  }

  void _onPhotoSelected(XFile? photo) {
    setState(() {
      _selectedPhoto = photo;
    });
  }

  void _onTermsChanged(bool value) {
    setState(() {
      _isTermsAccepted = value;
    });
    _validateForm();
  }

  void _onFieldChanged(String value) {
    _validateForm();
  }

  void _formatPhoneNumber(String value) {
    final oldText = _phoneController.text;
    final oldSelection = _phoneController.selection;

    // Keep only digits; compute how many digits were before caret
    // String digitsOnlyOld = oldText.replaceAll(RegExp(r'[^\d]'), '');
    String digitsOnlyNew = value.replaceAll(RegExp(r'[^\d]'), '');

    // Ensure country code 998 prefix
    if (!digitsOnlyNew.startsWith('998')) {
      digitsOnlyNew = '998$digitsOnlyNew';
    }

    // Limit total to +998 plus 9 digits = 12 digits
    if (digitsOnlyNew.length > 12) {
      digitsOnlyNew = digitsOnlyNew.substring(0, 12);
    }

    // Build formatted string: +998 XX XXX XX XX
    String formatted = '+998';
    String local = digitsOnlyNew.length > 3 ? digitsOnlyNew.substring(3) : '';
    if (local.isNotEmpty) {
      formatted += ' ';
      if (local.length <= 2) {
        formatted += local;
      } else if (local.length <= 5) {
        formatted += local.substring(0, 2) + ' ' + local.substring(2);
      } else if (local.length <= 7) {
        formatted +=
            local.substring(0, 2) +
            ' ' +
            local.substring(2, 5) +
            ' ' +
            local.substring(5);
      } else {
        // up to 9 digits
        final part1 = local.substring(0, 2);
        final part2 = local.substring(2, 5);
        final part3 = local.substring(5, 7);
        final part4 = local.substring(7);
        formatted += '$part1 $part2 $part3';
        if (part4.isNotEmpty) formatted += ' $part4';
      }
    }

    // Compute new caret position preserving number of digits before caret
    int digitsBeforeCaret = 0;
    if (oldSelection.start >= 0) {
      final substringBeforeCaret = oldText.substring(0, oldSelection.start);
      digitsBeforeCaret = substringBeforeCaret
          .replaceAll(RegExp(r'[^\d]'), '')
          .length;
    }
    // Clamp to new digits length
    digitsBeforeCaret = digitsBeforeCaret.clamp(0, digitsOnlyNew.length);

    // Map nth digit to index in formatted string
    int targetOffset = formatted.length;
    int seenDigits = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        seenDigits++;
        if (seenDigits == digitsBeforeCaret + 0) {
          targetOffset = i + 1; // place caret right after that digit
          break;
        }
      }
    }

    if (formatted != oldText ||
        _phoneController.selection.start != targetOffset) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: targetOffset),
      );
    }
  }

  void _continueRegistration() async {
    if (!_isFormValid) return;

    HapticFeedback.mediumImpact();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Debug: Print form data
      print('=== REGISTRATION DEBUG ===');
      print('Email: ${_emailController.text.trim()}');
      print('Password: ${_passwordController.text}');
      print('Full Name: ${_fullNameController.text.trim()}');
      print('Phone: ${_phoneController.text.trim()}');
      print('Address: ${_addressController.text.trim()}');
      print('========================');

      // Register user with Firebase
      final userCredential = await AuthService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        photoUrl: null, // TODO: Upload photo to Firebase Storage
      );

      // Ensure display name is set
      if (userCredential?.user != null) {
        await userCredential!.user!.updateDisplayName(
          _fullNameController.text.trim(),
        );
        await userCredential.user!.reload();
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ro\'yxatdan o\'tish muvaffaqiyatli yakunlandi!',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppTheme.getSuccessColor(true),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to home after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home-dashboard',
            (route) => false,
          );
        }
      });
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Debug: Print full error
      print('=== REGISTRATION ERROR ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('=========================');

      // Show error message
      String errorMessage = 'Ro\'yxatdan o\'tishda xatolik yuz berdi';

      // Parse Firebase error messages
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Bu email manzili allaqachon ro\'yxatdan o\'tgan';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Parol juda zaif. Kuchliroq parol kiriting';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Noto\'g\'ri email manzili';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Internet aloqasi yo\'q. Qayta urinib ko\'ring';
      } else if (e.toString().contains('FirebaseException')) {
        errorMessage = 'Firebase xatoligi. Internet aloqasini tekshiring';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Ruxsat yo\'q. Firebase sozlamalarini tekshiring';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppTheme.getErrorColor(true),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Chiqishni tasdiqlang',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Kiritilgan ma\'lumotlar saqlanmaydi. Rostdan ham chiqmoqchimisiz?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Bekor qilish',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Chiqish',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Hisob yaratish',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        leading: IconButton(
          onPressed: _showExitConfirmation,
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '1-qadam',
                        style: AppTheme.lightTheme.textTheme.labelMedium
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        ' / 2',
                        style: AppTheme.lightTheme.textTheme.labelMedium
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                    minHeight: 4,
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile photo section
                      Center(
                        child: ProfilePhotoWidget(
                          onPhotoSelected: _onPhotoSelected,
                          selectedPhoto: _selectedPhoto,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Full name field
                      FormFieldWidget(
                        label: 'To\'liq ism',
                        hint: 'Ismingiz va familiyangizni kiriting',
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        isRequired: true,
                        validator: _validateFullName,
                        onChanged: _onFieldChanged,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-ZА-Яа-яЁё\s]'),
                          ),
                          LengthLimitingTextInputFormatter(50),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Phone number field
                      FormFieldWidget(
                        label: 'Telefon raqami',
                        hint: '+998 XX XXX XX XX',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isRequired: true,
                        validator: _validatePhone,
                        onChanged: (value) {
                          _formatPhoneNumber(value);
                          _onFieldChanged(value);
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[\d\s\+]'),
                          ),
                          LengthLimitingTextInputFormatter(17),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Email field
                      FormFieldWidget(
                        label: 'Email manzili',
                        hint: 'example@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: true,
                        validator: _validateEmail,
                        onChanged: _onFieldChanged,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9@._-]'),
                          ),
                          LengthLimitingTextInputFormatter(100),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Password field
                      FormFieldWidget(
                        label: 'Parol',
                        hint: 'Kuchli parol yarating',
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !_isPasswordVisible,
                        isRequired: true,
                        validator: _validatePassword,
                        onChanged: _onFieldChanged,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: CustomIconWidget(
                            iconName: _isPasswordVisible
                                ? 'visibility_off'
                                : 'visibility',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                      ),

                      // Password strength indicator
                      PasswordStrengthWidget(
                        password: _passwordController.text,
                      ),

                      SizedBox(height: 3.h),

                      // Confirm password field
                      FormFieldWidget(
                        label: 'Parolni tasdiqlang',
                        hint: 'Parolni qayta kiriting',
                        controller: _confirmPasswordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !_isConfirmPasswordVisible,
                        isRequired: true,
                        validator: _validateConfirmPassword,
                        onChanged: _onFieldChanged,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                          icon: CustomIconWidget(
                            iconName: _isConfirmPasswordVisible
                                ? 'visibility_off'
                                : 'visibility',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Address field
                      FormFieldWidget(
                        label: 'Yetkazib berish manzili',
                        hint: 'To\'liq manzilni kiriting (ko\'cha, uy raqami)',
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 3,
                        isRequired: true,
                        validator: _validateAddress,
                        onChanged: _onFieldChanged,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
                        suffixIcon: IconButton(
                          onPressed: () {
                            // Location picker functionality would be implemented here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Joylashuvni tanlash funksiyasi tez orada qo\'shiladi',
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                ),
                                backgroundColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                              ),
                            );
                          },
                          icon: CustomIconWidget(
                            iconName: 'location_on',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Terms and conditions checkbox
                      TermsCheckboxWidget(
                        isChecked: _isTermsAccepted,
                        onChanged: _onTermsChanged,
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isFormValid ? _continueRegistration : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.surface.withValues(
                        alpha: 0.5,
                      ),
                foregroundColor: _isFormValid
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.onSurface.withValues(
                        alpha: 0.4,
                      ),
                elevation: _isFormValid ? 4 : 0,
                shadowColor: _isFormValid
                    ? AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.3,
                      )
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Davom etish',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: _isFormValid
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: 'arrow_forward',
                    color: _isFormValid
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
