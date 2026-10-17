// lib/features/recent/services/recent_service.dart
//
// Hive storage for recently viewed items. Values are plain Maps, so no
// type adapter / typeId is needed. The box name is a compatibility
// contract — renaming it drops every install's history.

import 'package:hive_flutter/hive_flutter.dart';

import 'package:dhikir_app/features/recent/models/recent_item.dart';

class RecentService {
  static const String _boxName = 'recent_items_v1';
  static const int maxItems = 10;
  static late Box<Map> _box;

  /// Open the recent-items box. Hive.initFlutter() (HiveService.init) must run first.
  static Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  /// All valid items, newest first.
  static List<RecentItem> getAll() => _box.values.map(RecentItem.fromMap).whereType<RecentItem>().toList()
    ..sort((a, b) => b.openedAt.compareTo(a.openedAt));

  /// Insert or bump [item], then trim the oldest beyond [maxItems].
  static Future<void> record(RecentItem item) async {
    await _box.put(item.key, item.toMap());
    final all = getAll();
    if (all.length > maxItems) {
      await _box.deleteAll(all.skip(maxItems).map((e) => e.key));
    }
  }

  static Future<void> remove(String key) => _box.delete(key);

  static Future<void> clear() => _box.clear();
}
