// lib/screens/home_screen.dart
//
// Root scaffold with a bottom navigation bar hosting three tabs:
//   0 → HomeWidget  (dhikir grid)
//   1 → _CounterTab (session launcher list)
//   2 → FavouritesScreen
//
// Session setup and navigation are handled here so tab widgets remain
// stateless / presentation-only.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dhikir_app/core/theme/app_colors.dart';
import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/core/data/dhikir_data.dart' as built_in;
import 'package:dhikir_app/core/providers/theme_provider.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:dhikir_app/core/persistence/hive_service.dart';
import 'package:dhikir_app/core/widgets/session_setup_sheet.dart';
import 'package:dhikir_app/core/widgets/date_header_row.dart';
import 'package:dhikir_app/features/dhikir/widgets/counter_tab.dart';
import 'package:dhikir_app/features/favorites/screens/favorite_screen.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';
import 'package:dhikir_app/features/alarm/services/alarm_scheduler.dart';
import 'package:dhikir_app/features/alarm/services/alarm_service.dart';
import 'package:dhikir_app/features/alarm/services/alarm_settings_repository.dart';
import 'package:dhikir_app/features/prayer_time/providers/prayer_time_provider.dart';
import 'package:dhikir_app/features/prayer_time/widgets/prayer_time_card.dart';
import 'package:dhikir_app/features/prayer_time/widgets/prayer_schedule_cards.dart';
import 'package:dhikir_app/features/prayer_time/widgets/forbidden_times_card.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/data/dhikir_localizations.dart';

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Tab pages — rebuilt on each setState so they pick up fresh data.
  List<Widget> get _pages => [
        const HomeWidget(),
        CounterTab(onStartSession: _showSessionSetup),
        const FavouritesScreen(),
      ];

  // ── Session helpers ──────────────────────────────────────────────────────────

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

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.play_arrow_outlined),
            activeIcon: const Icon(Icons.play_arrow_rounded),
            label: l10n.navCounter,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite),
            label: l10n.navFavorites,
          ),
        ],
      ),
    );
  }
}

// ─── HomeWidget ───────────────────────────────────────────────────────────────

/// Scrollable grid of all dhikir (built-in + custom).
class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  void initState() {
    super.initState();
    final prayerTimeProvider = context.read<PrayerTimeProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await prayerTimeProvider.init();
      if (!mounted) return;
      // Alarms depend on today/tomorrow's prayer times, so reschedule right
      // after they're resolved — matches alarm_implementation.md's "on app
      // open" trigger. Failures (e.g. no alarms enabled) are silent no-ops.
      await AlarmService(
        scheduler: AlarmScheduler(
          prayerTimeProvider: prayerTimeProvider,
          settingsRepository: AlarmSettingsRepository(),
        ),
      ).rescheduleAllPrayerAlarms(locale: Localizations.localeOf(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final builtIn = built_in.dhikirList.map(SessionDhikir.fromItem).toList();
    final custom =
        CustomDhikirService.getAll().map(SessionDhikir.fromCustom).toList();
    final allDhikir = [...builtIn, ...custom];

    return CustomScrollView(
      slivers: [
        // ── App bar ───────────────────────────────────────────────────────
        // SliverAppBar(
        //   // expandedHeight: 130,
        //   pinned: true,
        //   floating: false,
        //   backgroundColor: AppColors.background,
        //   surfaceTintColor: Colors.transparent,
        //   elevation: 0,
        //   actions: [
        // _ThemeToggleButton(),
        // IconButton(
        //   tooltip: 'About',
        //   icon: const Icon(Icons.info_outline, color: AppColors.dark),
        //   onPressed: () => Navigator.pushNamed(context, RouteNames.about),
        // ),
        // const SizedBox(width: 8),
        // _NavButton(
        //   label: 'My Dhikir',
        //   icon: Icons.add_rounded,
        //   backgroundColor: AppColors.accentMint,
        //   foregroundColor: AppColors.medium,
        //   border: Border.all(color: AppColors.mintBorder),
        //   onTap: () async {
        //     await Navigator.pushNamed(context, RouteNames.myDhikir);
        //     setState(() {});
        //   },
        // ),
        // const SizedBox(width: 8),
        // _NavButton(
        //   label: 'Analytics',
        //   icon: Icons.bar_chart_rounded,
        //   backgroundColor: AppColors.dark,
        //   foregroundColor: Colors.white,
        //   onTap: () async {
        //     await Navigator.pushNamed(context, RouteNames.analytics);
        //     setState(() {});
        //   },
        // ),
        // const SizedBox(width: 16),
        // ],
        // flexibleSpace: FlexibleSpaceBar(
        //   titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        //   title: Text(
        //     'Daily Dhikir',
        //     style: GoogleFonts.playfairDisplay(
        //       fontSize: 26,
        //       fontWeight: FontWeight.w700,
        //       color: AppColors.dark,
        //     ),
        //   ),
        // ),
        // ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Spacer(),
                _NavButton(
                  label: l10n.navMyDhikir,
                  icon: Icons.add_rounded,
                  backgroundColor: AppColors.accentMint,
                  foregroundColor: AppColors.medium,
                  border: Border.all(color: AppColors.mintBorder),
                  onTap: () async {
                    await Navigator.pushNamed(context, RouteNames.myDhikir);
                    setState(() {});
                  },
                ),
                IconButton(
                  tooltip: l10n.aboutTitle,
                  icon: const Icon(Icons.info_outline, color: AppColors.dark),
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.about),
                ),
                const SizedBox(width: 8)
              ],
            ),
          ),
        ),
        // ── Date + prayer time ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: DateHeaderRow(
              hijriOffsetDays:
                  context.watch<PrayerTimeProvider>().displayHijriOffsetDays,
              sunrise:
                  context.watch<PrayerTimeProvider>().today?.sunrise.toLocal(),
              sunset:
                  context.watch<PrayerTimeProvider>().today?.sunset.toLocal(),
              onHijriTap: () =>
                  Navigator.pushNamed(context, RouteNames.hijriSettings),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: PrayerTimeCard()),
        const SliverToBoxAdapter(child: PrayerScheduleSection()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _QuickActionsSection(onReturn: () => setState(() {})),
          ),
        ),

        const SliverToBoxAdapter(child: ForbiddenTimesCard()),

        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Text(l10n.homeSectionTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        )),

        // ── Dhikir grid ───────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _DhikirGridCard(
                item: allDhikir[i],
                year: now.year,
                month: now.month,
                onReturn: () => setState(() {}),
              ),
              childCount: allDhikir.length,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── _DhikirGridCard ──────────────────────────────────────────────────────────

/// Single card in the home grid. Tapping opens [DhikirDetailScreen].
class _DhikirGridCard extends StatelessWidget {
  final SessionDhikir item;
  final int year;
  final int month;
  final VoidCallback onReturn;

  const _DhikirGridCard({
    required this.item,
    required this.year,
    required this.month,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = HiveService.getProgress(item.id);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final completed = progress.completedCountInMonth(year, month);
    final todayCount = progress.countForDate(DateTime.now());
    final ratio = daysInMonth > 0 ? completed / daysInMonth : 0.0;
    final bgColor = item.color;

    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          RouteNames.dhikirDetail,
          arguments: DhikirDetailArgs(dhikir: item),
        );
        onReturn();
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + progress badges row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.icon, style: const TextStyle(fontSize: 28)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Month completion badge
                    _Badge(
                      label: '$completed/$daysInMonth',
                      bgColor: Colors.white.withValues(alpha: 0.7),
                      textColor: AppColors.medium,
                    ),
                    if (todayCount > 0) ...[
                      const SizedBox(height: 3),
                      _Badge(
                        label: l10n.todayCountBadge(todayCount),
                        bgColor: AppColors.dark,
                        textColor: Colors.white,
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              localizedDhikirTitle(context, item.id) ?? item.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            // Monthly progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.medium.withValues(alpha: 0.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

/// Pill-shaped text badge used inside the grid card.
class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}

/// Pill button used in the app-bar action area.
class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: foregroundColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Quick Actions" row shown between the prayer cards and the dhikir grid.
class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onReturn;

  const _QuickActionsSection({required this.onReturn});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActionsTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _QuickActionTile(
              icon: Icons.schedule,
              label: l10n.quickActionPrayerTime,
              backgroundColor: AppColors.dark,
              foregroundColor: Colors.white,
              onTap: () async {
                await Navigator.pushNamed(context, RouteNames.prayerTime);
                onReturn();
              },
            ),
            const SizedBox(width: 16),
            _QuickActionTile(
              icon: Icons.explore,
              label: l10n.quickActionQibla,
              backgroundColor: AppColors.accentMint,
              foregroundColor: AppColors.medium,
              border: Border.all(color: AppColors.mintBorder),
              onTap: () => Navigator.pushNamed(context, RouteNames.qibla),
            ),
          ],
        ),
      ],
    );
  }
}

/// Square icon-filled tile with its title below — single item in
/// [_QuickActionsSection].
class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: border,
            ),
            child: Icon(icon, color: foregroundColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Theme-toggle icon button (moon/sun).
class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final l10n = context.l10n;
    return IconButton(
      tooltip: theme.isDark
          ? l10n.themeToggleSwitchToLight
          : l10n.themeToggleSwitchToDark,
      icon: Icon(
        theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
        color: AppColors.dark,
        size: 22,
      ),
      onPressed: () => context.read<ThemeProvider>().toggle(),
    );
  }
}
