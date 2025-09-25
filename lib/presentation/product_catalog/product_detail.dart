import 'package:flutter/material.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final product =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return Scaffold(
      appBar: AppBar(title: const Text('Mahsulot')),
      body: product == null
          ? const Center(child: Text('Maʼlumot topilmadi'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((product['image'] as String?)?.isNotEmpty == true)
                    Image.asset(product['image'] as String,
                        height: 200, fit: BoxFit.contain),
                  const SizedBox(height: 12),
                  Text(
                    product['name'] ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Hajm: ${product['tankSize'] ?? ''} kg'),
                  const SizedBox(height: 8),
                  Text('Narx: ${product['price'] ?? ''}'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: const Text("Buyurtma berish"),
                      onPressed: () {
                        Navigator.pushNamed(context, '/order-tracking');
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
