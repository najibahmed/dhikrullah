// lib/features/my_dhikir/providers/my_dhikir_provider.dart
//
// Custom-dhikir list + CRUD logic shared by MyDhikirScreen and
// AddDhikirScreen. Each screen is a separately-pushed Navigator route
// (not a structural descendant of the other), so a single live instance
// can't be handed down through the widget tree the way a screen-scoped
// provider normally would be — each screen constructs its own instance
// of this class instead, avoiding the persistence-logic duplication that
// previously existed between the two screens. Cross-screen refresh still
// goes through the existing pop-result contract (AddDhikirScreen pops
// `true` on save; MyDhikirScreen reloads when it sees that result).

import 'package:dhikir_app/core/models/custom_dhikir_model.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:flutter/foundation.dart';

class MyDhikirProvider extends ChangeNotifier {
  MyDhikirProvider() {
    _reload();
  }

  late List<CustomDhikirItem> _items;
  List<CustomDhikirItem> get items => _items;

  void _reload() {
    _items = CustomDhikirService.getAll();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await CustomDhikirService.delete(id);
    _reload();
  }

  /// Creates a new custom dhikir, or updates [existing] in place when given.
  Future<void> save({
    CustomDhikirItem? existing,
    required String title,
    required String arabicText,
    required String transliteration,
    required String englishMeaning,
    required String colorHex,
    required String icon,
  }) async {
    if (existing != null) {
      existing.title = title;
      existing.arabicText = arabicText;
      existing.transliteration = transliteration;
      existing.englishMeaning = englishMeaning;
      existing.colorHex = colorHex;
      existing.icon = icon;
      await CustomDhikirService.update(existing);
    } else {
      final item = CustomDhikirItem(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        arabicText: arabicText,
        transliteration: transliteration,
        englishMeaning: englishMeaning,
        colorHex: colorHex,
        icon: icon,
        createdAt: DateTime.now(),
      );
      await CustomDhikirService.add(item);
    }
    _reload();
  }
}
