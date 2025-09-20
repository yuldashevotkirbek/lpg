import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PersonalInfoWidget extends StatefulWidget {
  final String fullName;
  final String email;
  final String phoneNumber;
  final Function(String) onFullNameChanged;
  final Function(String) onEmailChanged;
  final Function(String) onPhoneChanged;

  const PersonalInfoWidget({
    super.key,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.onFullNameChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
  });

  @override
  State<PersonalInfoWidget> createState() => _PersonalInfoWidgetState();
}

class _PersonalInfoWidgetState extends State<PersonalInfoWidget> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.fullName;
    _emailController.text = widget.email;
    _phoneController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'To\'liq ismni kiriting';
    }
    if (value.trim().length < 2) {
      return 'Ism kamida 2 ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'To\'g\'ri email manzilini kiriting';
      }
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon raqamini kiriting';
    }
    final phoneRegex = RegExp(r'^\+998[0-9]{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'To\'g\'ri telefon raqamini kiriting (+998XXXXXXXXX)';
    }
    return null;
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onFullNameChanged(_fullNameController.text.trim());
      widget.onEmailChanged(_emailController.text.trim());
      widget.onPhoneChanged(_phoneController.text.trim());

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ma\'lumotlar muvaffaqiyatli saqlandi'),
          backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'person',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Shaxsiy ma\'lumotlar',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'To\'liq ism',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'badge',
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ),
                validator: _validateFullName,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveChanges();
                  }
                },
              ),
              SizedBox(height: 2.h),
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email (ixtiyoriy)',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'email',
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ),
                validator: _validateEmail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onChanged: (value) {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveChanges();
                  }
                },
              ),
              SizedBox(height: 2.h),
              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Telefon raqami',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'phone',
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                  helperText: 'Masalan: +998901234567',
                ),
                validator: _validatePhone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  if (_formKey.currentState?.validate() ?? false) {
                    _saveChanges();
                  }
                },
              ),
              SizedBox(height: 3.h),
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text('O\'zgarishlarni saqlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
