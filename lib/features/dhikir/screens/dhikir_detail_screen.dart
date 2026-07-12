// lib/features/dhikir/screens/dhikir_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/core/widgets/counter_button.dart';
import 'package:dhikir_app/features/dhikir/providers/dhikir_detail_provider.dart';
import 'package:dhikir_app/features/dhikir/widgets/goal_pick_sheet.dart';
import 'package:dhikir_app/features/dhikir/widgets/mile_stone_dot.dart';
import 'package:dhikir_app/features/dhikir/widgets/pill_widget.dart';

class DhikirDetailScreen extends StatelessWidget {
  final DhikirItem dhikir;
  const DhikirDetailScreen({super.key, required this.dhikir});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Scoped to this screen; auto-disposed when screen is popped.
      create: (_) => DhikirDetailProvider(dhikir),
      child: _DhikirDetailView(dhikir: dhikir),
    );
  }
}

class _DhikirDetailView extends StatefulWidget {
  final DhikirItem dhikir;
  const _DhikirDetailView({required this.dhikir});

  @override
  State<_DhikirDetailView> createState() => _DhikirDetailViewState();
}

class _DhikirDetailViewState extends State<_DhikirDetailView> with TickerProviderStateMixin {
  // Counter animation controllers — kept in the widget since AnimationController
  // needs a TickerProvider (vsync), which DhikirDetailProvider can't supply.
  late AnimationController _pulseCtrl;
  late AnimationController _completionCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _completionAnim;

  Color get _accent => Color(int.parse(widget.dhikir.colorHex.replaceFirst('#', 'FF'), radix: 16));

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _completionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _completionAnim = CurvedAnimation(
      parent: _completionCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _completionCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCounterTap() async {
    final provider = context.read<DhikirDetailProvider>();
    final count = provider.todayCount;
    final isUnlimited = provider.isUnlimited;
    final target = provider.target;

    if (!isUnlimited && count >= target) {
      // Already completed — just pulse
      HapticFeedback.lightImpact();
      _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
      return;
    }

    // Haptic: stronger every 10, milestone at target
    final newCount = count + 1;
    if (!isUnlimited && newCount >= target) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    } else if (newCount % 10 == 0) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    // is Unlimited and reset animation + Haptic: stronger every 100, milestone at target
    if (isUnlimited && newCount % 100 == 0) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
      _completionCtrl.reset();
    }
    // Pulse animation
    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());

    final justCompleted = await provider.incrementCounter();
    if (justCompleted) {
      _completionCtrl.forward(from: 0);
    }
  }

  Future<void> _resetCounter() async {
    final provider = context.read<DhikirDetailProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Reset Today's Count?", style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: const Text("This resets today's tap counter to 0."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4A5568), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await provider.resetCounter();
      _completionCtrl.reset();
    }
  }

  Future<void> _showGoalDialog() async {
    final provider = context.read<DhikirDetailProvider>();
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GoalPickerSheet(
        currentTarget: provider.target,
        accentColor: _accent,
        goalOptions: DhikirDetailProvider.goalOptions,
      ),
    );
    if (selected != null && selected != provider.target) {
      provider.setTarget(selected);
      _completionCtrl.reset();
    }
  }

  Future<void> _resetMonth() async {
    final provider = context.read<DhikirDetailProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset This Month?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: const Text('This clears all checkmarks for this month.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4A5568), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.resetMonth();
      _completionCtrl.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DhikirDetailProvider>();
    final bgColor = _accent;
    final today = provider.today;
    final year = today.year;
    final month = today.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final completed = provider.progress.completedCountInMonth(year, month);
    final todayCount = provider.todayCount;
    final target = provider.target;
    final isUnlimited = provider.isUnlimited;
    final isGoalMet = provider.isGoalMet;
    final progress = provider.progressRatio;
    final isFavourite = provider.isFavourite;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF2D3748)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 18,
                    color: isFavourite ? const Color(0xFFFC8181) : const Color(0xFFCBD5E0),
                  ),
                ),
                onPressed: () => context.read<DhikirDetailProvider>().toggleFavourite(),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.calendar_month_rounded, size: 18, color: Color(0xFF4A5568)),
                ),
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    RouteNames.dhikirCalendar,
                    arguments: DhikirCalendarArgs(dhikir: widget.dhikir),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFF4A5568)),
                ),
                onPressed: _resetMonth,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: bgColor,
                padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.dhikir.title,
                                  style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                              const SizedBox(height: 2),
                              Wrap(
                                children: [
                                  Text(widget.dhikir.transliteration,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 4,
                                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF718096), fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(widget.dhikir.icon, style: const TextStyle(fontSize: 36)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Month progress bar
                Container(
                  color: bgColor,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: daysInMonth > 0 ? completed / daysInMonth : 0,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.6),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A5568)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$completed / $daysInMonth days',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4A5568))),
                    ],
                  ),
                ),

                Container(
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F4F1),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                ),

                // ── Arabic text card ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Pill(label: 'Arabic', color: bgColor),
                        const SizedBox(height: 16),
                        Text(
                          widget.dhikir.arabicText,
                          style: GoogleFonts.amiri(fontSize: 32, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748), height: 1.6),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 12),
                        Text(widget.dhikir.transliteration,
                            style: GoogleFonts.inter(fontSize: 15, fontStyle: FontStyle.italic, color: const Color(0xFF718096)),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Meaning card ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Pill(label: 'Meaning & Significance', color: bgColor),
                        const SizedBox(height: 14),
                        Text(widget.dhikir.englishMeaning, style: GoogleFonts.inter(fontSize: 14.5, color: const Color(0xFF4A5568), height: 1.7)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ═══════════════════════════════════════════════════════
                // ── DHIKIR COUNTER CARD ─────────────────────────────────
                // ═══════════════════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Pill(label: "Today's Counter", color: bgColor),
                            Row(
                              children: [
                                // Goal setting button
                                GestureDetector(
                                  onTap: _showGoalDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D3748),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.flag_rounded, size: 12, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          isUnlimited ? 'Goal: ∞' : 'Goal: $target',
                                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Reset button
                                GestureDetector(
                                  onTap: _resetCounter,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6F4F1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.refresh_rounded, size: 12, color: Color(0xFF718096)),
                                        const SizedBox(width: 4),
                                        Text('Reset', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF718096))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // The big circular counter button
                        CounterButton(
                          count: todayCount,
                          target: target,
                          progress: progress,
                          isGoalMet: isGoalMet,
                          isUnlimited: isUnlimited,
                          accentColor: bgColor,
                          pulseAnim: _pulseAnim,
                          completionAnim: _completionAnim,
                          onTap: _onCounterTap,
                        ),

                        const SizedBox(height: 20),

                        // Goal met banner
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isGoalMet
                              ? Container(
                                  key: const ValueKey('done'),
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF2D3748)),
                                      const SizedBox(width: 8),
                                      Text(
                                        "MāshāAllah! $target completed today",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Padding(
                                  key: const ValueKey('remaining'),
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    isUnlimited ? 'Keep going — no limit set' : '${target - todayCount} remaining',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF718096),
                                    ),
                                  ),
                                ),
                        ),

                        const SizedBox(height: 12),

                        // Mini dots milestone row
                        if (target != -1)
                          MilestoneDots(
                            count: todayCount,
                            target: target,
                            accentColor: bgColor,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── This Month tracker ──────────────────────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Pill(label: 'This Month', color: bgColor),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    RouteNames.dhikirCalendar,
                                    arguments: DhikirCalendarArgs(dhikir: widget.dhikir),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4A5568),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text('History', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: daysInMonth,
                            itemBuilder: (context, index) {
                              final day = index + 1;
                              final date = DateTime(year, month, day);
                              final isDone = provider.progress.isDateCompleted(date);
                              final isToday = day == today.day;
                              final isFuture = date.isAfter(today);

                              return GestureDetector(
                                onTap: isFuture ? null : () => context.read<DhikirDetailProvider>().toggleDay(day),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? const Color(0xFF4A5568)
                                        : isFuture
                                            ? const Color(0xFFF8F8F8)
                                            : bgColor.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isToday && !isDone
                                          ? const Color(0xFF4A5568)
                                          : isDone
                                              ? const Color(0xFF4A5568)
                                              : isFuture
                                                  ? const Color(0xFFE2E8F0)
                                                  : bgColor,
                                      width: isToday ? 2 : 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: isDone
                                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                        : Text(
                                            '$day',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                                              color: isFuture ? const Color(0xFFCBD5E0) : const Color(0xFF718096),
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const LegendDot(color: Color(0xFF4A5568), label: 'Done'),
                              const SizedBox(width: 14),
                              LegendDot(color: bgColor, label: 'Pending'),
                              const SizedBox(width: 14),
                              const LegendDot(color: Color(0xFFF8F8F8), label: 'Future', bordered: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
