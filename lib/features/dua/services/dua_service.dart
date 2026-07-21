import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

import 'package:dhikir_app/features/dua/models/dua_item.dart';

class DuaService {
  const DuaService();

  Future<DuaData> load(BuildContext context) async {
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    final assetPath = isBangla
        ? 'assets/json/all_dua_bn.json'
        : 'assets/json/all_dua_en.json';
    final raw = await rootBundle.loadString(assetPath);
    final root = jsonDecode(raw) as Map<String, dynamic>;
    return DuaData.fromJson(root);
  }
}
