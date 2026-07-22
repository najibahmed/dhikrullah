// lib/features/dhikir/screens/counter_screen.dart
//
// Standalone screen hosting the dhikir session launcher (CounterTab),
// reached via the "Tasbih" quick-action tile on Home. Owns a fixed bottom
// action bar for the destinations that used to live on Home's bottom nav:
// Add Custom Dhikir, My Dhikir, Favorite.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/theme/app_colors.dart';
import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/core/widgets/session_setup_sheet.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/features/dhikir/widgets/counter_tab.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  /// Shows the goal-picker sheet, then launches the session screen.
  Future<void> _showSessionSetup(List<SessionDhikir> list) async {
    if (list.isEmpty) return;
    int goal = 100;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SessionSetupSheet(
        dhikirList: list,
        onStart: (g) {
          goal = g;
          Navigator.pop(ctx, true);
        },
      ),
    );

    if (confirmed == true && mounted) {
      await Navigator.pushNamed(
        context,
        RouteNames.sessionCounter,
        arguments: SessionCounterArgs(dhikirList: list, sharedGoal: goal),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.quickActionTasbih),
      ),
      body: SafeArea(child: CounterTab(onStartSession: _showSessionSetup)),
      bottomNavigationBar: _CounterActionBar(
        onAddDhikir: () async {
          await Navigator.pushNamed(context, RouteNames.addDhikir);
          setState(() {});
        },
        onMyDhikir: () async {
          await Navigator.pushNamed(context, RouteNames.myDhikir);
          setState(() {});
        },
        onFavorite: () async {
          await Navigator.pushNamed(context, RouteNames.favorites);
          setState(() {});
        },
        onAnalytics: () async {
          await Navigator.pushNamed(context, RouteNames.analytics);
          setState(() {});
        },
      ),
    );
  }
}

/// Fixed bottom bar with three independent navigation actions.
class _CounterActionBar extends StatelessWidget {
  final VoidCallback onAddDhikir;
  final VoidCallback onMyDhikir;
  final VoidCallback onFavorite;
  final VoidCallback onAnalytics;

  const _CounterActionBar({
    required this.onAddDhikir,
    required this.onMyDhikir,
    required this.onFavorite,
    required this.onAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(top: BorderSide(color: AppColors.mintBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CounterActionButton(
              icon: Icons.add_circle_outline,
              label: l10n.counterAddCustomDhikir,
              onTap: onAddDhikir,
            ),
            _CounterActionButton(
              icon: Icons.menu_book_outlined,
              label: l10n.navMyDhikir,
              onTap: onMyDhikir,
            ),
            _CounterActionButton(
              icon: Icons.favorite_border,
              label: l10n.navFavorites,
              onTap: onFavorite,
            ),
            _CounterActionButton(
              icon: Icons.bar_chart_rounded,
              label: l10n.counterAnalytics,
              onTap: onAnalytics,
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CounterActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.dark, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.dark),
            ),
          ],
        ),
      ),
    );
  }
}
