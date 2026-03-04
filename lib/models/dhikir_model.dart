// lib/models/dhikir_model.dart
import 'package:hive/hive.dart';

part 'dhikir_model.g.dart';

@HiveType(typeId: 0)
class DhikirProgress extends HiveObject {
  @HiveField(0)
  final String dhikirId;

  @HiveField(1)
  List<String> completedDates; // "yyyy-MM-dd"

  /// Daily tap counts: key = "yyyy-MM-dd", value = count
  @HiveField(2)
  Map<String, int> dailyCounts;

  DhikirProgress({
    required this.dhikirId,
    required this.completedDates,
    required this.dailyCounts,
  });

  factory DhikirProgress.create(String id) => DhikirProgress(
        dhikirId: id,
        completedDates: [],
        dailyCounts: {},
      );

  static String dateKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool isDateCompleted(DateTime date) => completedDates.contains(dateKey(date));

  int countForDate(DateTime date) => dailyCounts[dateKey(date)] ?? 0;

  List<int> completedDaysInMonth(int year, int month) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    return completedDates.where((d) => d.startsWith(prefix)).map((d) => int.parse(d.split('-')[2])).toList();
  }

  int completedCountInMonth(int year, int month) => completedDaysInMonth(year, month).length;

  Set<String> get activeMonths => completedDates.map((d) => d.substring(0, 7)).toSet();

  int get totalCompleted => completedDates.length;
}

class DhikirItem {
  final String id;
  final String title;
  final String arabicText;
  final String transliteration;
  final String englishMeaning;
  final String icon;
  final String colorHex;

  const DhikirItem({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.englishMeaning,
    required this.icon,
    required this.colorHex,
  });
}
