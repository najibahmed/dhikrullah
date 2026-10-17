// lib/features/recent/models/recent_item.dart
//
// Reference to something the user recently opened. Only ids are stored —
// display text is resolved at render time so it follows the active locale
// and drops entries whose source (e.g. a deleted custom dhikir) is gone.

enum RecentType { dhikir, dua }

class RecentItem {
  final RecentType type;
  final String id; // dhikirId, or dua id as string
  final String? categoryId; // dua only
  final DateTime openedAt;

  const RecentItem({
    required this.type,
    required this.id,
    this.categoryId,
    required this.openedAt,
  });

  RecentItem.dhikir(this.id)
      : type = RecentType.dhikir,
        categoryId = null,
        openedAt = DateTime.now();

  RecentItem.dua(int duaId, String this.categoryId)
      : type = RecentType.dua,
        id = '$duaId',
        openedAt = DateTime.now();

  /// Hive key — one entry per type+id, so re-opening replaces the old one.
  String get key => '${type.name}:$id';

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'id': id,
        'categoryId': categoryId,
        'openedAt': openedAt.millisecondsSinceEpoch,
      };

  /// Returns null for malformed maps or unknown types (e.g. written by a
  /// newer app version), so callers can skip them instead of crashing.
  static RecentItem? fromMap(Map map) {
    final type = RecentType.values.where((t) => t.name == map['type']).firstOrNull;
    final id = map['id'];
    final openedAt = map['openedAt'];
    if (type == null || id is! String || openedAt is! int) return null;
    return RecentItem(
      type: type,
      id: id,
      categoryId: map['categoryId'] as String?,
      openedAt: DateTime.fromMillisecondsSinceEpoch(openedAt),
    );
  }
}
