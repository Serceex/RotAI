import 'package:flutter/material.dart';
import '../utils/categories.dart';

class CategoryRecommendationsWidget extends StatelessWidget {
  final List<String> recommendedCategoryIds;
  final Function(String categoryId)? onCategoryTap;

  const CategoryRecommendationsWidget({
    super.key,
    required this.recommendedCategoryIds,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final recommendedCategories = recommendedCategoryIds
        .map((id) => Categories.getById(id))
        .where((c) => c != null)
        .cast<Category>()
        .toList();

    if (recommendedCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Sizin İçin Öneriler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendedCategories.length,
            itemBuilder: (context, index) {
              final category = recommendedCategories[index];
              return GestureDetector(
                onTap: () => onCategoryTap?.call(category.id),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

