class AllahName {
  final int number;
  final String arabic;
  final String transliteration;
  final String english;
  final String meaning;

  const AllahName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.english,
    required this.meaning,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      number: json['number'] as int,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      english: json['english'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

class AllahNamesData {
  final String title;
  final String description;
  final String source;
  final String recitationBenefits;
  final String hadith;
  final List<AllahName> names;

  const AllahNamesData({
    required this.title,
    required this.description,
    required this.source,
    required this.recitationBenefits,
    required this.hadith,
    required this.names,
  });

  factory AllahNamesData.fromJson(Map<String, dynamic> root) {
    final data = root['data'] as Map<String, dynamic>;
    return AllahNamesData(
      title: data['english_title'] as String,
      description: data['description'] as String,
      source: data['source'] as String,
      recitationBenefits: data['recitation_benefits'] as String,
      hadith: data['hadith'] as String,
      names: (data['names'] as List)
          .map((e) => AllahName.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
