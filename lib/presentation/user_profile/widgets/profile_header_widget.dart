import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final String? profileImageUrl;
  final Function(String) onNameChanged;
  final Function(String) onPhoneChanged;
  final Function(String?) onImageChanged;

  const ProfileHeaderWidget({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.onImageChanged,
  });

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isEditingName = false;
  bool _isEditingPhone = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
    _phoneController.text = widget.phoneNumber;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _showImagePickerBottomSheet() async {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 0.5.h,
                margin: EdgeInsets.only(top: 1.h),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Text(
                      'Profil rasmini o\'zgartirish',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImagePickerOption(
                          icon: 'camera_alt',
                          label: 'Kamera',
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                        _buildImagePickerOption(
                          icon: 'photo_library',
                          label: 'Galereya',
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                        if (widget.profileImageUrl != null)
                          _buildImagePickerOption(
                            icon: 'delete',
                            label: 'O\'chirish',
                            onTap: _removeImage,
                            isDestructive: true,
                          ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: 20.w,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isDestructive
              ? Theme.of(context).colorScheme.error.withOpacity(0.1)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isDestructive
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      bool hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        _showPermissionDialog(source);
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        widget.onImageChanged(image.path);
        _showSuccessSnackBar('Profil rasmi muvaffaqiyatli o\'zgartirildi');
      }
    } catch (e) {
      _showErrorSnackBar('Rasm tanlashda xatolik yuz berdi');
    }
  }

  Future<void> _removeImage() async {
    widget.onImageChanged(null);
    _showSuccessSnackBar('Profil rasmi o\'chirildi');
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  void _showPermissionDialog(ImageSource source) {
    final String permissionName =
    source == ImageSource.camera ? 'kamera' : 'galereya';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ruxsat kerak'),
        content: Text('$permissionName ishlatish uchun ruxsat bering.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Sozlamalar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleNameEdit() {
    setState(() {
      if (_isEditingName) {
        widget.onNameChanged(_nameController.text);
        _showSuccessSnackBar('Ism muvaffaqiyatli o\'zgartirildi');
      }
      _isEditingName = !_isEditingName;
    });
  }

  void _togglePhoneEdit() {
    setState(() {
      if (_isEditingPhone) {
        widget.onPhoneChanged(_phoneController.text);
        _showSuccessSnackBar('Telefon raqami muvaffaqiyatli o\'zgartirildi');
      }
      _isEditingPhone = !_isEditingPhone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          // Profile Image with Camera Overlay
          Stack(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.onPrimary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: widget.profileImageUrl != null
                      ? CustomImageWidget(
                    imageUrl: widget.profileImageUrl!,
                    width: 30.w,
                    height: 30.w,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.1),
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 15.w,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerBottomSheet,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 4.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Name Section
          Row(
            children: [
              Expanded(
                child: _isEditingName
                    ? TextField(
                  controller: _nameController,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  autofocus: true,
                )
                    : Text(
                  widget.userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _toggleNameEdit,
                icon: CustomIconWidget(
                  iconName: _isEditingName ? 'check' : 'edit',
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Phone Section
          Row(
            children: [
              Expanded(
                child: _isEditingPhone
                    ? TextField(
                  controller: _phoneController,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.9),
                  ),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.5),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                )
                    : Text(
                  widget.phoneNumber,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimary
                        .withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: _togglePhoneEdit,
                icon: CustomIconWidget(
                  iconName: _isEditingPhone ? 'check' : 'edit',
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
