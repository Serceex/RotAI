import 'package:flutter/material.dart';
import '../../utils/categories.dart';

class CategoryStatisticsScreen extends StatelessWidget {
  const CategoryStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori İstatistikleri'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: Categories.all.length,
        itemBuilder: (context, index) {
          final category = Categories.all[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Text(
                category.icon,
                style: const TextStyle(fontSize: 32),
              ),
              title: Text(category.name),
              subtitle: const Text('0 karar, 0 oy'), // Gerçek verilerle doldurulabilir
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}

