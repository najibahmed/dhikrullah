import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'package:dhikir_app/features/allah_names/models/allah_name.dart';

class AllahNamesService {
  const AllahNamesService();

  Future<AllahNamesData> load(String languageCode) async {
    final isBangla = languageCode == 'bn';
    final assetPath = isBangla
        ? 'assets/json/allah_names_bn.json'
        : 'assets/json/allah_names_en.json';
    final raw = await rootBundle.loadString(assetPath);
    final root = jsonDecode(raw) as Map<String, dynamic>;
    return AllahNamesData.fromJson(root);
  }
}
