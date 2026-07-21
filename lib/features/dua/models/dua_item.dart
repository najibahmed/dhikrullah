class DuaCategory {
  final String id;
  final String name;
  final String description;
  final int count;

  const DuaCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.count,
  });

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      count: json['count'] as int,
    );
  }
}

class DuaItem {
  final int id;
  final String category;
  final String title;
  final String arabic;
  final String transliteration;
  final String translation;
  final String source;
  final int repeat;

  const DuaItem({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.source,
    required this.repeat,
  });

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'] as int,
      category: json['category'] as String,
      title: json['title'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      source: json['source'] as String,
      repeat: json['repeat'] as int,
    );
  }
}

class DuaData {
  final List<DuaCategory> categories;
  final List<DuaItem> duas;

  const DuaData({required this.categories, required this.duas});

  factory DuaData.fromJson(Map<String, dynamic> root) {
    final data = root['data'] as Map<String, dynamic>;
    return DuaData(
      categories: (data['categories'] as List)
          .map((e) => DuaCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      duas: (data['duas'] as List)
          .map((e) => DuaItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
