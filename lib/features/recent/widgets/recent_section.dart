// lib/features/recent/widgets/recent_section.dart
//
// Home "Recently viewed" strip — horizontal cards for the last opened
// dhikir/duas. Dhikir cards push DhikirDetailScreen; dua cards push the
// dua's category list scrolled to that dua. Hidden when empty.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/data/dhikir_localizations.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';
import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/core/theme/theme_colors.dart';
import 'package:dhikir_app/core/utils/time_format.dart';
import 'package:dhikir_app/features/recent/models/recent_item.dart';
import 'package:dhikir_app/features/recent/providers/recent_provider.dart';

/// Base tint for dua cards — same as the Dua quick-action tile border.
const _duaTint = Color(0xFFFFE0B2);

class RecentSection extends StatefulWidget {
  /// Called after returning from an opened dhikir so Home can refresh its grid.
  final VoidCallback onReturn;

  const RecentSection({super.key, required this.onReturn});

  @override
  State<RecentSection> createState() => _RecentSectionState();
}

class _RecentSectionState extends State<RecentSection> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Localizations.localeOf(context).languageCode == 'bn' ? 'bn' : 'en';
    context.read<RecentProvider>().ensureDuaData(lang);
  }

  Future<void> _confirmClear() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.recentClearConfirmTitle, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text(l10n.recentClearConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.recentClear)),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<RecentProvider>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = context.watch<RecentProvider>().entries;
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recentTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(onPressed: _confirmClear, child: Text(l10n.recentClear)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 132,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _RecentCard(entry: entries[i], onReturn: widget.onReturn),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final RecentEntry entry;
  final VoidCallback onReturn;

  const _RecentCard({required this.entry, required this.onReturn});

  Future<void> _open(BuildContext context) async {
    switch (entry) {
      case RecentDhikirEntry(:final dhikir):
        // DhikirDetailScreen records the view itself.
        await Navigator.pushNamed(
          context,
          RouteNames.dhikirDetail,
          arguments: DhikirDetailArgs(dhikir: dhikir),
        );
        onReturn();
      case RecentDuaEntry(:final dua, :final categoryName, :final categoryDuas):
        context.read<RecentProvider>().record(RecentItem.dua(dua.id, dua.category));
        await Navigator.pushNamed(
          context,
          RouteNames.duaList,
          arguments: DuaListArgs(categoryName: categoryName, duas: categoryDuas, initialDuaId: dua.id),
        );
      case RecentPendingEntry():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brightness = Theme.of(context).brightness;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final ago = timeAgo(l10n, entry.item.openedAt);

    // Dhikir cards swap the type chip for today's tap count once counted.
    final todayCount = switch (entry) {
      RecentDhikirEntry(:final dhikir) => HiveService.getProgress(dhikir.id).countForDate(DateTime.now()),
      _ => 0,
    };

    final (Color base, String icon, String type, String title, String meta) = switch (entry) {
      RecentDhikirEntry(:final dhikir) => (
          dhikir.color,
          dhikir.icon,
          l10n.recentTypeDhikir,
          localizedDhikirTitle(context, dhikir.id) ?? dhikir.title,
          ago,
        ),
      RecentDuaEntry(:final dua, :final categoryName) => (
          _duaTint,
          '🤲',
          l10n.recentTypeDua,
          dua.title,
          categoryName.isEmpty ? ago : '$ago · $categoryName',
        ),
      RecentPendingEntry() => (_duaTint, '🤲', l10n.recentTypeDua, '', ago),
    };
    final bg = adjustForBrightness(base, brightness);
    final fg = onColorFor(bg);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _open(context),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: todayCount > 0 ? colorScheme.primary : fg.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      todayCount > 0 ? l10n.todayCountBadge(todayCount) : type.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: todayCount > 0 ? colorScheme.onPrimary : fg,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              // Expanded (not Spacer + fixed text) so taller scripts like
              // Bangla shrink the title area instead of overflowing.
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(color: fg, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: fg.withValues(alpha: 0.75)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
