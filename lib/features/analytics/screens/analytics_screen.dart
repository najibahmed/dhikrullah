// lib/features/analytics/screens/analytics_screen.dart
import 'dart:math' as math;
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dhikir_app/core/data/dhikir_data.dart';
import 'package:dhikir_app/features/analytics/providers/analytics_provider.dart';

// ─── Main Screen ─────────────────────────────────────────────────────────────
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Scoped to this screen; auto-disposed when screen is popped.
      create: (_) => AnalyticsProvider(),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView();

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  static const _periodLabels = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        context.read<AnalyticsProvider>().period = AnalyticsPeriod.values[_tabCtrl.index];
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final period = provider.period;
    final bars = provider.buildBars();
    final (from, to) = provider.currentRange();
    final stats = provider.buildStats(from, to);
    final grandTotal = provider.grandTotal(stats);
    final maxBar = bars.isEmpty ? 1 : bars.map((b) => b.total).reduce(math.max).clamp(1, 999999);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 170,
              collapsedHeight: 75,
              backgroundColor: const Color(0xFFF6F4F1),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 64,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))]),
                  child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF2D3748)),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 24, bottom: 56),
                title: Text(
                  'Counter Analytics',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                // background: Align(
                //   alignment: Alignment.center,
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 24, bottom: 16),
                //     child: Text(
                //       'ذكر الله • إحصاءات',
                //       style: GoogleFonts.amiri(fontSize: 14, color: const Color(0xFF718096)),
                //     ),
                //   ),
                // ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: _PeriodTabBar(
                  controller: _tabCtrl,
                  labels: _periodLabels,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary pills ──────────────────────────────────
                    _SummaryRow(
                      stats: stats,
                      grandTotal: grandTotal,
                      period: period,
                    ),

                    const SizedBox(height: 20),

                    // ── Bar chart ──────────────────────────────────────
                    // Container(
                    //   padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(24),
                    //     boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Text(
                    //             _chartTitle(),
                    //             style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748)),
                    //           ),
                    //           Text(
                    //             'Total: $grandTotal',
                    //             style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096)),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 20),
                    //       _BarChart(bars: bars, maxVal: maxBar.toDouble()),
                    //     ],
                    //   ),
                    // ),

                    const SizedBox(height: 20),

                    // ── Per-dhikir breakdown list ──────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'By Dhikir',
                                  style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748)),
                                ),
                                Text(
                                  _periodLabel(period),
                                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096)),
                                ),
                              ],
                            ),
                          ),
                          // Header row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Text('Dhikir',
                                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFA0AEC0)))),
                                Expanded(
                                    child: Center(
                                        child: Text('Count',
                                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFA0AEC0))))),
                                Expanded(
                                    child: Center(
                                        child: Text('Days',
                                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFA0AEC0))))),
                                Expanded(
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text('Share',
                                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFA0AEC0))))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1, color: Color(0xFFF0EEEB)),
                          ...stats.asMap().entries.map((entry) {
                            final i = entry.key;
                            final stat = entry.value;
                            final maxCount = stats.isNotEmpty && stats.first.count > 0 ? stats.first.count : 1;
                            return _DhikirStatRow(
                              stat: stat,
                              rank: i + 1,
                              maxCount: maxCount,
                              grandTotal: grandTotal,
                              isLast: i == stats.length - 1,
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Daily breakdown for current period ────────────
                    if (period != AnalyticsPeriod.daily) ...[
                      _DailyBreakdownCard(period: period),
                      const SizedBox(height: 20),
                    ],

                    // ── All-time totals ────────────────────────────────
                    _AllTimeTotals(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return 'Today';
      case AnalyticsPeriod.weekly:
        return 'This Week';
      case AnalyticsPeriod.monthly:
        return 'This Month';
    }
  }
}

// ─── Period Tab Bar ───────────────────────────────────────────────────────────

class _PeriodTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> labels;

  const _PeriodTabBar({required this.controller, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: const Color(0xFF4A5568),
          borderRadius: BorderRadius.circular(11),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF718096),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: labels.map((l) => Tab(text: l)).toList(),
      ),
    );
  }
}

// ─── Summary Row ─────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final List<DhikirStat> stats;
  final int grandTotal;
  final AnalyticsPeriod period;

  const _SummaryRow({required this.stats, required this.grandTotal, required this.period});

  String _avgLabel() {
    switch (period) {
      case AnalyticsPeriod.daily:
        return 'Today';
      case AnalyticsPeriod.weekly:
        return '/ day avg';
      case AnalyticsPeriod.monthly:
        return '/ day avg';
    }
  }

  int _activeDhikir() => stats.where((s) => s.count > 0).length;

  String _avgCount() {
    if (period == AnalyticsPeriod.daily) return '$grandTotal';
    final days = period == AnalyticsPeriod.weekly ? 7 : 30;
    return (grandTotal / days).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            value: '$grandTotal',
            label: 'Total Count',
            icon: Icons.tag_rounded,
            color: const Color(0xFFE8F5E9),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: _avgCount(),
            label: _avgLabel(),
            icon: Icons.trending_up_rounded,
            color: const Color(0xFFE3F2FD),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '${_activeDhikir()}',
            label: 'Active Types',
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFFFFF8E1),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4A5568)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF718096))),
        ],
      ),
    );
  }
}

// ─── Bar Chart ────────────────────────────────────────────────────────────────

// class _BarChart extends StatelessWidget {
//   final List<PeriodBar> bars;
//   final double maxVal;
//   const _BarChart({required this.bars, required this.maxVal});
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 160,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: bars.asMap().entries.map((entry) {
//           final bar = entry.value;
//           final ratio = bar.total / maxVal;
//           final isLast = entry.key == bars.length - 1;
//           return Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(right: isLast ? 0 : 6),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   if (bar.total > 0)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 4),
//                       child: Text(
//                         '${bar.total}',
//                         style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF4A5568)),
//                       ),
//                     ),
//                   Flexible(
//                     child: FractionallySizedBox(
//                       heightFactor: ratio.clamp(0.04, 1.0),
//                       child: _StackedBar(
//                         bar: bar,
//                         maxVal: maxVal,
//                         isHighlighted: isLast,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     bar.label,
//                     style: GoogleFonts.inter(
//                       fontSize: 9,
//                       fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
//                       color: isLast ? const Color(0xFF2D3748) : const Color(0xFFA0AEC0),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

class _StackedBar extends StatelessWidget {
  final PeriodBar bar;
  final double maxVal;
  final bool isHighlighted;

  const _StackedBar({required this.bar, required this.maxVal, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    final builtInSession = dhikirList.map((d) => SessionDhikir.fromItem(d)).toList();
    final customItems = CustomDhikirService.getAll();
    final customSession = customItems.map((d) => SessionDhikir.fromCustom(d)).toList();
    final combined = [...builtInSession, ...customSession];
    if (bar.total == 0) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0EEEB),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    // Build stacked segments per dhikir
    final segments = <Widget>[];
    final entries = bar.countsByDhikir.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final dhikir = combined.firstWhere((d) => d.id == entry.key, orElse: () => combined.first);
      final segColor = Color(int.parse(dhikir.colorHex.replaceFirst('#', 'FF'), radix: 16));
      final flex = (entry.value * 100 / bar.total).round().clamp(1, 100);

      segments.add(Flexible(
        flex: flex,
        child: Container(color: isHighlighted ? const Color(0xFF4A5568) : segColor),
      ));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: segments.reversed.toList(),
      ),
    );
  }
}

// ─── Dhikir Stat Row ──────────────────────────────────────────────────────────

class _DhikirStatRow extends StatelessWidget {
  final DhikirStat stat;
  final int rank;
  final int maxCount;
  final int grandTotal;
  final bool isLast;

  const _DhikirStatRow({
    required this.stat,
    required this.rank,
    required this.maxCount,
    required this.grandTotal,
    required this.isLast,
  });

  Color get _accentColor => Color(int.parse(stat.dhikir.colorHex.replaceFirst('#', 'FF'), radix: 16));

  @override
  Widget build(BuildContext context) {
    final pct = grandTotal > 0 ? (stat.count / grandTotal * 100).round() : 0;
    final barWidth = maxCount > 0 ? stat.count / maxCount : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: rank == 1
                          ? const Color(0xFFFFF8E1)
                          : rank == 2
                              ? const Color(0xFFF0F4F8)
                              : rank == 3
                                  ? const Color(0xFFFCE4EC)
                                  : const Color(0xFFF6F4F1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank',
                        style: GoogleFonts.inter(fontSize: rank <= 3 ? 13 : 11, fontWeight: FontWeight.w600, color: const Color(0xFF718096)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Icon + name
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _accentColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(stat.dhikir.icon, style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.dhikir.title,
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                stat.dhikir.arabicText,
                                style: GoogleFonts.amiri(fontSize: 11, color: const Color(0xFF718096)),
                                textDirection: TextDirection.rtl,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Count
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            '${stat.count}',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 18, fontWeight: FontWeight.w700, color: stat.count > 0 ? const Color(0xFF2D3748) : const Color(0xFFCBD5E0)),
                          ),
                          Text('$pct%', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFA0AEC0))),
                        ],
                      ),
                    ),
                  ),

                  // Sessions/days
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            '${stat.sessions}',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: stat.sessions > 0 ? const Color(0xFF4A5568) : const Color(0xFFCBD5E0)),
                          ),
                          Text('days', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFA0AEC0))),
                        ],
                      ),
                    ),
                  ),

                  // Share pct bar
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            width: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EEEB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: 6,
                            width: 50 * barWidth,
                            decoration: BoxDecoration(
                              color: stat.count > 0 ? const Color(0xFF4A5568) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(height: 1, color: Color(0xFFF6F4F1)),
          ),
      ],
    );
  }
}

// ─── Daily Breakdown Card (for weekly/monthly period) ────────────────────────

class _DailyBreakdownCard extends StatefulWidget {
  final AnalyticsPeriod period;
  const _DailyBreakdownCard({required this.period});

  @override
  State<_DailyBreakdownCard> createState() => _DailyBreakdownCardState();
}

class _DailyBreakdownCardState extends State<_DailyBreakdownCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<AnalyticsProvider>().buildDayEntries(widget.period);
    final shown = _expanded ? entries : entries.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Day-by-Day Log',
                  style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748)),
                ),
                Text(
                  widget.period == AnalyticsPeriod.weekly ? 'Last 7 days' : 'Last 30 days',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0EEEB)),
          ...shown.map((e) => _DayLogRow(entry: e)),
          if (entries.length > 5)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _expanded ? 'Show less' : 'Show all ${entries.length} days',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF4A5568)),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: const Color(0xFF4A5568),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DayLogRow extends StatelessWidget {
  final DayEntry entry;
  const _DayLogRow({required this.entry});

  String _dateLabel() {
    final now = DateTime.now();
    if (entry.date.day == now.day && entry.date.month == now.month) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (entry.date.day == yesterday.day && entry.date.month == yesterday.month) {
      return 'Yesterday';
    }
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[entry.date.weekday - 1]} ${entry.date.day}/${entry.date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final combined = context.watch<AnalyticsProvider>().combined;
    final sorted = entry.byDhikir.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              SizedBox(
                width: 72,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_dateLabel(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
                    Text(
                      '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                      style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFA0AEC0)),
                    ),
                  ],
                ),
              ),
              // Dhikir chips
              Expanded(
                child: entry.total == 0
                    ? Text('No counts recorded', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFCBD5E0), fontStyle: FontStyle.italic))
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: sorted.map((e) {
                          final dhikir = combined.firstWhere((d) => d.id == e.key, orElse: () => combined.first);
                          final color = Color(int.parse(dhikir.colorHex.replaceFirst('#', 'FF'), radix: 16));
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(dhikir.icon, style: const TextStyle(fontSize: 11)),
                                const SizedBox(width: 4),
                                Text(
                                  '${e.value}×',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              // Total
              if (entry.total > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '${entry.total}',
                    style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748)),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF6F4F1)),
      ],
    );
  }
}

// ─── All-Time Totals ──────────────────────────────────────────────────────────

class _AllTimeTotals extends StatelessWidget {
  const _AllTimeTotals();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<AnalyticsProvider>().buildAllTime();
    final grandTotal = stats.fold(0, (s, e) => s + e.count);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF2D3748).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All-Time Totals', style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$grandTotal total',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          ...stats.where((s) => s.count > 0).map((stat) {
            final color = Color(int.parse(stat.dhikir.colorHex.replaceFirst('#', 'FF'), radix: 16));
            final pct = grandTotal > 0 ? stat.count / grandTotal : 0.0;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(stat.dhikir.icon, style: const TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(stat.dhikir.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                      Text('${stat.count}', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (stats.every((s) => s.count == 0))
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Text(
                'Start counting to see your all-time stats.',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white38, fontStyle: FontStyle.italic),
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
