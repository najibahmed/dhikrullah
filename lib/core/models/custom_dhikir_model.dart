// lib/models/custom_dhikir_model.dart
import 'package:hive/hive.dart';

part 'custom_dhikir_model.g.dart';

@HiveType(typeId: 1)
class CustomDhikirItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String arabicText;

  @HiveField(3)
  String transliteration;

  @HiveField(4)
  String englishMeaning;

  @HiveField(5)
  String colorHex;

  @HiveField(6)
  String icon;

  @HiveField(7)
  bool isFavorite;

  @HiveField(8)
  DateTime createdAt;

  CustomDhikirItem({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.englishMeaning,
    required this.colorHex,
    required this.icon,
    this.isFavorite = false,
    required this.createdAt,
  });
}
