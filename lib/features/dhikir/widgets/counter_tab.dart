// ─── _CounterTab ──────────────────────────────────────────────────────────────

import 'package:dhikir_app/core/data/dhikir_data.dart';
import 'package:dhikir_app/core/widgets/fav_row.dart';
import 'package:dhikir_app/core/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/theme/app_colors.dart';
import 'package:dhikir_app/core/providers/favorites_provider.dart';
import 'package:dhikir_app/features/my_dhikir/screens/my_dhikir_screen.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';

/// Shows all dhikir as a list with per-item session-start buttons.
class CounterTab extends StatefulWidget {
  final Future<void> Function(List<SessionDhikir>) onStartSession;

  const CounterTab({super.key, required this.onStartSession});

  @override
  State<CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<CounterTab> {
  @override
  Widget build(BuildContext context) {
    final builtIn = dhikirList.map(SessionDhikir.fromItem).toList();
    final custom = CustomDhikirService.getAll().map(SessionDhikir.fromCustom).toList();
    final all = [...builtIn, ...custom];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-session button
            _SessionStartButton(
              label: 'Start Full Session — ${all.length} Dhikir',
              onTap: () => widget.onStartSession(all),
            ),
            const SizedBox(height: 16),

            SectionHeader(
              title: 'All Dhikir',
              count: all.length,
              onSession: () => widget.onStartSession(all),
            ),
            const SizedBox(height: 8),

            // List of FavRow items (reused from my_dhikir_screen)
            ...all.map((item) {
              return FavRow(
                  id: item.id,
                  title: item.title,
                  arabic: item.arabicText,
                  transliteration: item.transliteration,
                  icon: item.icon,
                  colorHex: item.colorHex,
                  onSession: () => widget.onStartSession([item]),
                  onToggleFav: () {
                    context.read<FavoritesProvider>().toggle(item.id);
                    setState(() {});
                  });
            }),
          ],
        ),
      ),
    );
  }
}

/// Full-width "start session" button.
class _SessionStartButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SessionStartButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.dark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
