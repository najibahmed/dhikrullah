import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/core/models/custom_dhikir_model.dart';
import 'package:dhikir_app/core/providers/favorites_provider.dart';
import 'package:dhikir_app/core/widgets/session_setup_sheet.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';
import 'package:dhikir_app/features/my_dhikir/providers/my_dhikir_provider.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';

class MyDhikirScreen extends StatelessWidget {
  const MyDhikirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Scoped to this screen; auto-disposed when screen is popped.
      create: (_) => MyDhikirProvider(),
      child: const _MyDhikirView(),
    );
  }
}

class _MyDhikirView extends StatefulWidget {
  const _MyDhikirView();

  @override
  State<_MyDhikirView> createState() => _MyDhikirViewState();
}

class _MyDhikirViewState extends State<_MyDhikirView> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _delete(CustomDhikirItem item) async {
    final provider = context.read<MyDhikirProvider>();
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteDhikirTitle(item.title), style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text(l10n.deleteDhikirBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await provider.delete(item.id);
    }
  }

  void _startSession(List<SessionDhikir> list, int goal) {
    if (list.isEmpty) return;
    Navigator.pushNamed(
      context,
      RouteNames.sessionCounter,
      arguments: SessionCounterArgs(dhikirList: list, sharedGoal: goal),
    ).then((_) => setState(() {}));
  }

  Future<void> _showSessionSetup(List<SessionDhikir> list) async {
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
    if (confirmed == true) {
      _startSession(list, goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final customItems = context.watch<MyDhikirProvider>().items;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: const Color(0xFFF6F4F1),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
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
            // actions: [
            //   Padding(
            //     padding: const EdgeInsets.only(right: 16),
            //     child: GestureDetector(
            //       onTap: () => Navigator.pushNamed(context, RouteNames.addDhikir),
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //         decoration: BoxDecoration(
            //           color: const Color(0xFF2D3748),
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         child: Row(
            //           children: [
            //             const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            //             const SizedBox(width: 5),
            //             Text(l10n.commonAdd, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 56),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.navMyDhikir,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              background: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, bottom: 18),
                  child: Text(l10n.myDhikirCountSubtitle(customItems.length), style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096))),
                ),
              ),
            ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ── Tab 1: All custom dhikir ───────────────────────────
                _CustomDhikirTab(
                  items: customItems,
                  onDelete: _delete,
                  onStartSession: (items) => _showSessionSetup(items),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Dhikir Tab ────────────────────────────────────────────────────────

class _CustomDhikirTab extends StatelessWidget {
  final List<CustomDhikirItem> items;
  final Future<void> Function(CustomDhikirItem) onDelete;
  final void Function(List<SessionDhikir>) onStartSession;

  const _CustomDhikirTab({
    required this.items,
    required this.onDelete,
    required this.onStartSession,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text('📿', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(l10n.myDhikirEmptyTitle,
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
            const SizedBox(height: 8),
            Text(l10n.myDhikirEmptySubtitle,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF718096), height: 1.5), textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final sessionList = items.map((i) => SessionDhikir.fromCustom(i)).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        children: [
          // Start session button
          GestureDetector(
            onTap: () => onStartSession(sessionList),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF2D3748).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_circle_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(l10n.myDhikirStartSession(items.length),
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => _CustomCard(
                item: item,
                onDelete: () => onDelete(item),
                onSessionSingle: () => onStartSession([SessionDhikir.fromCustom(item)]),
              )),
        ],
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  final CustomDhikirItem item;
  final VoidCallback onDelete;
  final VoidCallback onSessionSingle;

  const _CustomCard({
    required this.item,
    required this.onDelete,
    required this.onSessionSingle,
  });

  Color get _color => Color(int.parse(item.colorHex.replaceFirst('#', 'FF'), radix: 16));

  @override
  Widget build(BuildContext context) {
    // Read favourite state from provider (rebuilds automatically on change).
    final isFav = context.watch<FavoritesProvider>().isFavorite(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(14)),
                  child: Center(child: Text(item.icon, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.title,
                                style: GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                          ),
                          if (isFav) const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFFC8181)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(item.arabicText,
                          style: GoogleFonts.amiri(fontSize: 16, color: const Color(0xFF4A5568)),
                          textDirection: TextDirection.rtl,
                          overflow: TextOverflow.ellipsis),
                      Text(item.transliteration,
                          style: GoogleFonts.inter(fontSize: 11, fontStyle: FontStyle.italic, color: const Color(0xFF718096)),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action row
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF6F4F1), width: 1)),
            ),
            child: Row(
              children: [
                _ActionBtn(
                  icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: isFav ? context.l10n.unfavAction : context.l10n.favouriteAction,
                  color: isFav ? const Color(0xFFFC8181) : const Color(0xFF718096),
                  onTap: () => context.read<FavoritesProvider>().toggle(item.id),
                ),
                _ActionBtn(
                  icon: Icons.edit_rounded,
                  label: context.l10n.commonEdit,
                  color: const Color(0xFF718096),
                  onTap: () => Navigator.pushNamed(
                    context,
                    RouteNames.addDhikir,
                    arguments: AddDhikirArgs(existing: item),
                  ),
                ),
                _ActionBtn(
                  icon: Icons.play_arrow_rounded,
                  label: context.l10n.navCounter,
                  color: const Color(0xFF4A5568),
                  onTap: onSessionSingle,
                ),
                _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  label: context.l10n.commonDelete,
                  color: const Color(0xFFE53E3E),
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 3),
              Text(label, style: GoogleFonts.inter(fontSize: 10, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
