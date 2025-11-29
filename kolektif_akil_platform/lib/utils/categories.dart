class Category {
  final String id;
  final String name;
  final String icon;
  final String color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Categories {
  static const List<Category> all = [
    Category(
      id: 'career',
      name: 'Kariyer',
      icon: '💼',
      color: '#4A90E2',
    ),
    Category(
      id: 'finance',
      name: 'Finans',
      icon: '💰',
      color: '#50C878',
    ),
    Category(
      id: 'health',
      name: 'Sağlık',
      icon: '🏥',
      color: '#E74C3C',
    ),
    Category(
      id: 'education',
      name: 'Eğitim',
      icon: '📚',
      color: '#9B59B6',
    ),
    Category(
      id: 'relationship',
      name: 'İlişkiler',
      icon: '❤️',
      color: '#E91E63',
    ),
    Category(
      id: 'technology',
      name: 'Teknoloji',
      icon: '💻',
      color: '#3498DB',
    ),
    Category(
      id: 'travel',
      name: 'Seyahat',
      icon: '✈️',
      color: '#16A085',
    ),
    Category(
      id: 'lifestyle',
      name: 'Yaşam Tarzı',
      icon: '🌟',
      color: '#F39C12',
    ),
    Category(
      id: 'business',
      name: 'İş',
      icon: '🏢',
      color: '#2C3E50',
    ),
    Category(
      id: 'other',
      name: 'Diğer',
      icon: '📋',
      color: '#95A5A6',
    ),
  ];

  static Category? getById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}

