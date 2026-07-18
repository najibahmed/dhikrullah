// lib/features/counter/screens/session_counter_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/core/models/custom_dhikir_model.dart';
import 'package:dhikir_app/core/widgets/counter_button.dart';
import 'package:dhikir_app/features/counter/providers/session_counter_provider.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/data/dhikir_localizations.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

// ─── Unified dhikir wrapper ───────────────────────────────────────────────────

class SessionDhikir implements DhikirItem {
  @override
  final String id;
  @override
  final String title;
  @override
  final String arabicText;
  @override
  final String transliteration;
  @override
  final String englishMeaning;
  @override
  final String colorHex;
  @override
  final String icon;

  const SessionDhikir({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.englishMeaning,
    required this.colorHex,
    required this.icon,
  });

  factory SessionDhikir.fromItem(DhikirItem d) => SessionDhikir(
        id: d.id,
        title: d.title,
        arabicText: d.arabicText,
        transliteration: d.transliteration,
        englishMeaning: d.englishMeaning,
        colorHex: d.colorHex,
        icon: d.icon,
      );

  factory SessionDhikir.fromCustom(CustomDhikirItem d) => SessionDhikir(
        id: d.id,
        title: d.title,
        arabicText: d.arabicText,
        transliteration: d.transliteration,
        englishMeaning: d.englishMeaning,
        colorHex: d.colorHex,
        icon: d.icon,
      );

  Color get color => Color(int.parse(colorHex.replaceFirst('#', 'FF'), radix: 16));
}

// ─── Session Counter Screen ───────────────────────────────────────────────────

class SessionCounterScreen extends StatelessWidget {
  final List<SessionDhikir> dhikirList;
  final int initialIndex;
  final int sharedGoal; // -1 = unlimited

  const SessionCounterScreen({
    super.key,
    required this.dhikirList,
    this.initialIndex = 0,
    this.sharedGoal = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Scoped to this screen; auto-disposed when screen is popped.
      create: (_) => SessionCounterProvider(
        dhikirList: dhikirList,
        initialIndex: initialIndex,
        sharedGoal: sharedGoal,
      ),
      child: const _SessionCounterView(),
    );
  }
}

class _SessionCounterView extends StatefulWidget {
  const _SessionCounterView();

  @override
  State<_SessionCounterView> createState() => _SessionCounterViewState();
}

class _SessionCounterViewState extends State<_SessionCounterView> with TickerProviderStateMixin {
  late PageController _pageCtrl;

  late AnimationController _pulseCtrl;
  late AnimationController _completionCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _completionAnim;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SessionCounterProvider>();
    _pageCtrl = PageController(initialPage: provider.currentIndex, viewportFraction: 1.0);

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.93).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _completionCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _completionAnim = CurvedAnimation(parent: _completionCtrl, curve: Curves.elasticOut);

    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _pulseCtrl.dispose();
    _completionCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final provider = context.read<SessionCounterProvider>();
    final count = provider.todayCount;
    final isUnlimited = provider.isUnlimited;
    final goal = provider.goal;

    if (!isUnlimited && count >= goal) {
      HapticFeedback.lightImpact();
      _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());
      return;
    }

    final newCount = count + 1;

    if (!isUnlimited && newCount >= goal) {
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

    _pulseCtrl.forward().then((_) => _pulseCtrl.reverse());

    final justCompleted = await provider.incrementCurrent();
    if (justCompleted) {
      _completionCtrl.forward(from: 0);
      // Auto-advance to next dhikir after 1.5s if not last
      final currentIndex = provider.currentIndex;
      if (currentIndex < provider.dhikirList.length - 1) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) _navigateTo(currentIndex + 1);
        });
      }
    }
  }

  void _navigateTo(int index) {
    final provider = context.read<SessionCounterProvider>();
    if (index < 0 || index >= provider.dhikirList.length) return;
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
    provider.setIndex(index);
    _completionCtrl.reset();
  }

  Future<void> _resetCurrent() async {
    final provider = context.read<SessionCounterProvider>();
    final l10n = context.l10n;
    final currentTitle = localizedDhikirTitle(context, provider.current.id) ?? provider.current.title;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.resetTodayCountTitle, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text(l10n.counterResetBody(currentTitle)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4A5568), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonReset),
          ),
        ],
      ),
    );
    if (ok == true) {
      await provider.resetCurrent();
      _completionCtrl.reset();
    }
  }

  Future<void> _showGoalDialog() async {
    final provider = context.read<SessionCounterProvider>();
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GoalSheet(
        current: provider.goal,
        accentColor: provider.current.color,
      ),
    );
    if (selected != null && selected != provider.goal) {
      provider.setGoal(selected);
      _completionCtrl.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionCounterProvider>();
    final l10n = context.l10n;
    final dhikirList = provider.dhikirList;
    final dhikir = provider.current;
    final currentIndex = provider.currentIndex;
    final count = provider.todayCount;
    final goal = provider.goal;
    final isUnlimited = provider.isUnlimited;
    final isGoalMet = provider.isGoalMet;
    final total = dhikirList.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A202C),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        l10n.counterProgressLabel(currentIndex + 1, total),
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showGoalDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: dhikir.color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: dhikir.color.withValues(alpha: 0.6), width: 1)),
                      child: Row(
                        children: [
                          const Icon(Icons.flag_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            isUnlimited ? '∞' : '$goal',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress dots ─────────────────────────────────────────
            if (!isUnlimited)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(total, (i) {
                    final d = dhikirList[i];
                    final done = provider.isCompleted(d.id);
                    final isCurrent = i == currentIndex;
                    return GestureDetector(
                      onTap: () => _navigateTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isCurrent ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: done
                              ? d.color
                              : isCurrent
                                  ? Colors.white
                                  : Colors.white24,
                        ),
                        child: done && !isCurrent ? const Icon(Icons.check_rounded, size: 6, color: Colors.white) : null,
                      ),
                    );
                  }),
                ),
              ),

            // ── PageView with dhikir cards ─────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: total,
                onPageChanged: (i) {
                  provider.setIndex(i);
                  _completionCtrl.reset();
                },
                itemBuilder: (_, i) {
                  final d = dhikirList[i];
                  final dCount = provider.countFor(d.id);
                  final dGoalMet = !isUnlimited && dCount >= goal;

                  return _DhikirPage(
                    dhikir: d,
                    count: dCount,
                    goal: goal,
                    isGoalMet: dGoalMet,
                    isUnlimited: isUnlimited,
                    progress: provider.progressFor(dCount),
                    pulseAnim: _pulseAnim,
                    completionAnim: _completionAnim,
                    isCurrent: i == currentIndex,
                    onTap: i == currentIndex ? _onTap : null,
                  );
                },
              ),
            ),

            // ── Bottom nav bar ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  // Previous
                  GestureDetector(
                    onTap: currentIndex > 0 ? () => _navigateTo(currentIndex - 1) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: currentIndex > 0 ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: currentIndex > 0 ? Colors.white24 : Colors.white.withValues(alpha: 0.06), width: 1),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: currentIndex > 0 ? Colors.white : Colors.white24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Center: reset + info
                  Expanded(
                    child: GestureDetector(
                      onTap: _resetCurrent,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh_rounded, size: 16, color: Colors.white.withValues(alpha: 0.6)),
                            const SizedBox(width: 6),
                            Text(
                              l10n.counterResetHint(count),
                              style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Next
                  GestureDetector(
                    onTap: currentIndex < total - 1 ? () => _navigateTo(currentIndex + 1) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: currentIndex < total - 1 ? dhikir.color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: currentIndex < total - 1 ? dhikir.color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.06), width: 1),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: currentIndex < total - 1 ? Colors.white : Colors.white24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dhikir Page (inside PageView) ───────────────────────────────────────────

class _DhikirPage extends StatelessWidget {
  final SessionDhikir dhikir;
  final int count;
  final int goal;
  final bool isGoalMet;
  final bool isUnlimited;
  final double progress;
  final Animation<double> pulseAnim;
  final Animation<double> completionAnim;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _DhikirPage({
    required this.dhikir,
    required this.count,
    required this.goal,
    required this.isGoalMet,
    required this.isUnlimited,
    required this.progress,
    required this.pulseAnim,
    required this.completionAnim,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localizedTitle = localizedDhikirTitle(context, dhikir.id) ?? dhikir.title;
    final localizedTransliteration =
        localizedDhikirTransliteration(context, dhikir.id) ?? dhikir.transliteration;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(
            height: 22,
          ),
          // Dhikir info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dhikir.color,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: dhikir.color.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(dhikir.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedTitle,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            localizedTransliteration,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF718096),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  dhikir.arabicText,
                  style: GoogleFonts.amiri(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 10),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A5568)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isUnlimited ? l10n.counterCountedUnlimited(count) : '$count / $goal',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF4A5568),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Big counter button
          CounterButton(
            count: count,
            target: goal,
            progress: progress,
            isGoalMet: isGoalMet,
            isUnlimited: isUnlimited,
            accentColor: dhikir.color,
            pulseAnim: pulseAnim,
            completionAnim: completionAnim,
            onTap: onTap,
          ),

          const Spacer(),

          // Status text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isGoalMet
                ? Container(
                    key: const ValueKey('done'),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: dhikir.color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF2D3748)),
                        const SizedBox(width: 6),
                        Text(
                          l10n.counterGoalReachedBanner,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748)),
                        ),
                      ],
                    ),
                  )
                : Text(
                    key: const ValueKey('remaining'),
                    isUnlimited ? l10n.tapNoLimit : l10n.remainingCount(goal - count),
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
                  ),
          ),

          const SizedBox(height: 16),
          if (isGoalMet)
            // Milestone dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(10, (i) {
                final milestone = (i + 1) *
                    (goal == -1
                        ? 10
                        : goal ~/ 10 < 1
                            ? 1
                            : goal ~/ 10);
                final reached = count >= milestone;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: reached ? 14 : 8,
                  height: reached ? 14 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reached ? dhikir.color : Colors.white.withValues(alpha: 0.15),
                  ),
                  child: reached ? const Icon(Icons.check_rounded, size: 8, color: Colors.white) : null,
                );
              }),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Arc Painter ──────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isGoalMet;

  _ArcPainter({required this.progress, required this.color, required this.isGoalMet});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 8.0;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);

    // Fill
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = isGoalMet ? color : Colors.white.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }

    // Tick marks every 10%
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (int i = 1; i < 10; i++) {
      final angle = startAngle + 2 * math.pi * (i / 10);
      canvas.drawLine(
        Offset(center.dx + (radius - 5) * math.cos(angle), center.dy + (radius - 5) * math.sin(angle)),
        Offset(center.dx + (radius + 5) * math.cos(angle), center.dy + (radius + 5) * math.sin(angle)),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress || old.isGoalMet != isGoalMet;
}

// ─── Goal Sheet ───────────────────────────────────────────────────────────────

class _GoalSheet extends StatefulWidget {
  final int current;
  final Color accentColor;
  const _GoalSheet({required this.current, required this.accentColor});

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  late int _selected;

  static const _options = [33, 34, 99, 100, -1];
  static const _labels = {33: '33', 34: '34', 99: '99', 100: '100', -1: '∞'};

  String _subtitleFor(AppLocalizations l10n, int goal) => switch (goal) {
        33 => l10n.goalSubtitleTasbihSubhanallah,
        34 => l10n.goalSubtitleTasbihAlhamdulillah,
        99 => l10n.goalSubtitleNamesOfAllah,
        100 => l10n.goalSubtitleDailyCentury,
        -1 => l10n.goalSubtitleNoLimit,
        _ => '',
      };

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
              ),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: widget.accentColor, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.flag_rounded, size: 20, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.sessionGoalSheetTitle,
                          style: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                      Text(l10n.sessionGoalSheetSubtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ..._options.map((goal) {
                final isSelected = _selected == goal;
                return GestureDetector(
                  onTap: () => setState(() => _selected = goal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2D3748) : const Color(0xFFF6F4F1),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? widget.accentColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _labels[goal]!,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: goal == -1 ? 24 : 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal == -1 ? l10n.goalLabelUnlimited : l10n.goalLabelTimes(goal),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF2D3748),
                                ),
                              ),
                              Text(
                                _subtitleFor(l10n, goal),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isSelected ? Colors.white60 : const Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, size: 12, color: Color(0xFF2D3748)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, null),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4F1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Center(
                          child: Text(l10n.commonCancel, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF718096))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, _selected),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3748),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            _selected == -1
                                ? l10n.setUnlimitedButton
                                : l10n.setGoalButton(_labels[_selected]!),
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
