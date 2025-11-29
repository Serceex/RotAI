import 'package:flutter/material.dart';
import '../../utils/categories.dart';

class UpdateCategoriesScreen extends StatelessWidget {
  const UpdateCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorileri Güncelle'),
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
              subtitle: Text('ID: ${category.id}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Kategori düzenleme işlevi
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

