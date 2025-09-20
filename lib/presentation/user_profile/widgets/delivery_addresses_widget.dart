import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeliveryAddressesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> addresses;
  final Function(Map<String, dynamic>) onAddressAdded;
  final Function(int) onAddressDeleted;
  final Function(int) onPrimaryChanged;

  const DeliveryAddressesWidget({
    super.key,
    required this.addresses,
    required this.onAddressAdded,
    required this.onAddressDeleted,
    required this.onPrimaryChanged,
  });

  @override
  State<DeliveryAddressesWidget> createState() =>
      _DeliveryAddressesWidgetState();
}

class _DeliveryAddressesWidgetState extends State<DeliveryAddressesWidget> {
  void _showAddAddressDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Yangi manzil qo\'shish'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Manzil nomi',
                    hintText: 'Uy, Ish, Boshqa...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Manzil nomini kiriting';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'To\'liq manzil',
                    hintText: 'Ko\'cha, uy raqami, kvartira...',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'To\'liq manzilni kiriting';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon raqami',
                    hintText: '+998901234567',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Telefon raqamini kiriting';
                    }
                    final phoneRegex = RegExp(r'^\+998[0-9]{9}$');
                    if (!phoneRegex.hasMatch(value.trim())) {
                      return 'To\'g\'ri telefon raqamini kiriting';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                final newAddress = {
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'title': titleController.text.trim(),
                  'address': addressController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'isPrimary': widget.addresses.isEmpty,
                };

                widget.onAddressAdded(newAddress);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Manzil muvaffaqiyatli qo\'shildi'),
                    backgroundColor: AppTheme.getSuccessColor(
                        Theme.of(context).brightness == Brightness.light),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Qo\'shish'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAddress(int index) {
    final address = widget.addresses[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manzilni o\'chirish'),
        content:
        Text('${address['title']} manzilini o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onAddressDeleted(index);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Manzil o\'chirildi'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('O\'chirish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Yetkazib berish manzillari',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _showAddAddressDialog,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            widget.addresses.isEmpty
                ? _buildEmptyState()
                : Column(
              children: widget.addresses.asMap().entries.map((entry) {
                final index = entry.key;
                final address = entry.value;
                return _buildAddressCard(address, index);
              }).toList(),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showAddAddressDialog,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                label: Text('Yangi manzil qo\'shish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'location_off',
            color:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Hech qanday manzil qo\'shilmagan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Yetkazib berish uchun manzil qo\'shing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    return Dismissible(
      key: Key(address['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Theme.of(context).colorScheme.onError,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        _confirmDeleteAddress(index);
        return false;
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (address['isPrimary'] as bool)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: (address['isPrimary'] as bool) ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        address['title'] as String,
                        style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (address['isPrimary'] as bool) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Asosiy',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              color:
                              Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!(address['isPrimary'] as bool))
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onPrimaryChanged(index);
                    },
                    child: Text('Asosiy qilish'),
                  ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              address['address'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'phone',
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  address['phone'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
