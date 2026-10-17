// lib/features/recent/providers/recent_provider.dart
//
// App-wide recently-viewed state. Holds the stored references
// (RecentService) and resolves them into display entries: dhikir from the
// built-in list / CustomDhikirService, duas from the per-language dua JSON
// (cached here, reloaded when the app locale changes). Entries whose
// source no longer exists are pruned.

import 'package:flutter/foundation.dart';

import 'package:dhikir_app/core/data/dhikir_data.dart' as built_in;
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';
import 'package:dhikir_app/features/dua/models/dua_item.dart';
import 'package:dhikir_app/features/dua/services/dua_service.dart';
import 'package:dhikir_app/features/recent/models/recent_item.dart';
import 'package:dhikir_app/features/recent/services/recent_service.dart';

sealed class RecentEntry {
  final RecentItem item;
  const RecentEntry(this.item);
}

class RecentDhikirEntry extends RecentEntry {
  final SessionDhikir dhikir;
  const RecentDhikirEntry(super.item, this.dhikir);
}

class RecentDuaEntry extends RecentEntry {
  final DuaItem dua;
  final String categoryName;
  final List<DuaItem> categoryDuas;
  const RecentDuaEntry(super.item, this.dua, this.categoryName, this.categoryDuas);
}

/// Dua data not loaded yet — rendered as a placeholder card.
class RecentPendingEntry extends RecentEntry {
  const RecentPendingEntry(super.item);
}

class RecentProvider extends ChangeNotifier {
  final _duaService = const DuaService();

  List<RecentItem> _items = RecentService.getAll();
  String? _duaLanguage;
  DuaData? _duaData;

  bool get isEmpty => _items.isEmpty;

  Future<void> record(RecentItem item) async {
    await RecentService.record(item);
    _reload();
  }

  Future<void> clear() async {
    await RecentService.clear();
    _reload();
  }

  /// Loads dua text for [languageCode] if not already cached.
  Future<void> ensureDuaData(String languageCode) async {
    if (_duaLanguage == languageCode) return;
    _duaLanguage = languageCode;
    _duaData = null;
    final data = await _duaService.load(languageCode);
    if (_duaLanguage != languageCode) return; // locale changed mid-load
    _duaData = data;
    notifyListeners();
  }

  /// Resolved entries, newest first. Stale references are pruned after
  /// this call (asynchronously), not returned.
  List<RecentEntry> get entries {
    final result = <RecentEntry>[];
    final stale = <String>[];
    for (final item in _items) {
      final entry = _resolve(item);
      if (entry == null) {
        stale.add(item.key);
      } else {
        result.add(entry);
      }
    }
    if (stale.isNotEmpty) _prune(stale);
    return result;
  }

  RecentEntry? _resolve(RecentItem item) {
    switch (item.type) {
      case RecentType.dhikir:
        final builtIn = built_in.dhikirList.where((d) => d.id == item.id).firstOrNull;
        if (builtIn != null) return RecentDhikirEntry(item, SessionDhikir.fromItem(builtIn));
        final custom = CustomDhikirService.getById(item.id);
        if (custom != null) return RecentDhikirEntry(item, SessionDhikir.fromCustom(custom));
        return null;
      case RecentType.dua:
        final data = _duaData;
        if (data == null) return RecentPendingEntry(item);
        final id = int.tryParse(item.id);
        final dua = data.duas.where((d) => d.id == id).firstOrNull;
        if (dua == null) return null;
        final category = data.categories.where((c) => c.id == dua.category).firstOrNull;
        return RecentDuaEntry(
          item,
          dua,
          category?.name ?? '',
          data.duas.where((d) => d.category == dua.category).toList(),
        );
    }
  }

  Future<void> _prune(List<String> keys) async {
    for (final key in keys) {
      await RecentService.remove(key);
    }
    _reload();
  }

  void _reload() {
    _items = RecentService.getAll();
    notifyListeners();
  }
}
