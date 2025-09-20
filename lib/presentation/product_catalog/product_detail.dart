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
                  Text(
                    product['name'] ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text('Narx: ${product['price'] ?? ''}'),
                  const SizedBox(height: 12),
                  Text('Hajm: ${product['tankSize'] ?? ''} kg'),
                ],
              ),
            ),
    );
  }
}
