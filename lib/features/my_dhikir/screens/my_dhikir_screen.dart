import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dhikir_app/core/data/dhikir_data.dart' as built_in;
import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/core/models/custom_dhikir_model.dart';
import 'package:dhikir_app/core/models/dhikir_model.dart';
import 'package:dhikir_app/core/providers/favorites_provider.dart';
import 'package:dhikir_app/core/persistence/custom_dhikir_service.dart';
import 'package:dhikir_app/core/widgets/section_header.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';

class MyDhikirScreen extends StatefulWidget {
  const MyDhikirScreen({super.key});

  @override
  State<MyDhikirScreen> createState() => _MyDhikirScreenState();
}

class _MyDhikirScreenState extends State<MyDhikirScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  // Which custom dhikir are selected for session
  final Set<String> _selectedIds = {};
  bool _selectionMode = false;

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

  void _refresh() => setState(() {});

  Future<void> _delete(CustomDhikirItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete "${item.title}"?', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: const Text('This will permanently delete this dhikir. Progress data will remain.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53E3E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await CustomDhikirService.delete(item.id);
      _refresh();
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
    final customItems = CustomDhikirService.getAll();
    final favorites = CustomDhikirService.getFavorites();

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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () async {
                    final saved = await Navigator.pushNamed(context, RouteNames.addDhikir);
                    if (saved == true) _refresh();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 5),
                        Text('Add', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 56),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Dhikir',
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
                  child: Text('${customItems.length} custom dhikir', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096))),
                ),
              ),
            ),
            // bottom: PreferredSize(
            //   preferredSize: const Size.fromHeight(52),
            //   child: Container(
            //     margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            //     height: 42,
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(14),
            //       boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            //     ),
            //     child: TabBar(
            //       controller: _tabCtrl,
            //       indicator: BoxDecoration(
            //         color: const Color(0xFF4A5568),
            //         borderRadius: BorderRadius.circular(11),
            //       ),
            //       indicatorSize: TabBarIndicatorSize.tab,
            //       indicatorPadding: const EdgeInsets.all(3),
            //       dividerColor: Colors.transparent,
            //       labelColor: Colors.white,
            //       unselectedLabelColor: const Color(0xFF718096),
            //       labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            //       unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
            //       tabs: const [
            //         Tab(text: 'My Dhikir'),
            //         // Tab(text: 'Favourites')
            //       ],
            //     ),
            //   ),
            // ),
          ),

          SliverFillRemaining(
            child: TabBarView(
              controller: _tabCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // ── Tab 1: All custom dhikir ───────────────────────────
                _CustomDhikirTab(
                  items: customItems,
                  onRefresh: _refresh,
                  onDelete: _delete,
                  onStartSession: (items) => _showSessionSetup(items),
                ),

                // ── Tab 2: Favourites (custom + built-in) ──────────────
                // _FavouritesTab(
                //   favorites: favorites,
                //   builtInList: built_in.dhikirList,
                //   onRefresh: _refresh,
                //   onStartSession: (items) => _showSessionSetup(items),
                // ),
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
  final VoidCallback onRefresh;
  final Future<void> Function(CustomDhikirItem) onDelete;
  final void Function(List<SessionDhikir>) onStartSession;

  const _CustomDhikirTab({
    required this.items,
    required this.onRefresh,
    required this.onDelete,
    required this.onStartSession,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Text('📿', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('No custom dhikir yet',
                style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
            const SizedBox(height: 8),
            Text('Tap the Add button to create your first dhikir',
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
                  Text('Start Session — All ${items.length} Dhikir',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...items.map((item) => _CustomCard(
                item: item,
                onDelete: () => onDelete(item),
                onRefresh: onRefresh,
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
  final VoidCallback onRefresh;
  final VoidCallback onSessionSingle;

  const _CustomCard({
    required this.item,
    required this.onDelete,
    required this.onRefresh,
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
                  label: isFav ? 'Unfav' : 'Favourite',
                  color: isFav ? const Color(0xFFFC8181) : const Color(0xFF718096),
                  onTap: () => context.read<FavoritesProvider>().toggle(item.id),
                ),
                _ActionBtn(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: const Color(0xFF718096),
                  onTap: () async {
                    final saved = await Navigator.pushNamed(
                      context,
                      RouteNames.addDhikir,
                      arguments: AddDhikirArgs(existing: item),
                    );
                    if (saved == true) onRefresh();
                  },
                ),
                _ActionBtn(
                  icon: Icons.play_arrow_rounded,
                  label: 'Counter',
                  color: const Color(0xFF4A5568),
                  onTap: onSessionSingle,
                ),
                _ActionBtn(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
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

// ─── Session Setup Sheet ──────────────────────────────────────────────────────

class SessionSetupSheet extends StatefulWidget {
  final List<SessionDhikir> dhikirList;
  final void Function(int goal) onStart;

  const SessionSetupSheet({required this.dhikirList, required this.onStart});

  @override
  State<SessionSetupSheet> createState() => SessionSetupSheetState();
}

class SessionSetupSheetState extends State<SessionSetupSheet> {
  int _goal = 100;

  static const _goals = [33, 34, 99, 100, -1];
  static const _labels = {33: '33', 34: '34', 99: '99', 100: '100', -1: '∞'};
  static const _desc = {
    33: 'SubhanAllah tasbih',
    34: 'Alhamdulillah tasbih',
    99: 'Names of Allah',
    100: 'Century goal',
    -1: 'No limit',
  };

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF2D3748), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.play_circle_rounded, size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Setup Session',
                          style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                      Text('${widget.dhikirList.length} dhikir • Choose a shared goal',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Goal per Dhikir', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF718096))),
              const SizedBox(height: 8),
              Row(
                children: _goals.map((g) {
                  final isSelected = _goal == g;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _goal = g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2D3748) : const Color(0xFFF6F4F1),
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? null : Border.all(color: const Color(0xFFE2E8F0), width: 1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _labels[g]!,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: g == -1 ? 18 : 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : const Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              _desc[g]!,
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                color: isSelected ? Colors.white60 : const Color(0xFF718096),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Dhikir preview chips
              Text('Session includes', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF718096))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.dhikirList.map((d) {
                  final color = d.color;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(d.icon, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(d.title, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F4F1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Center(
                          child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF718096))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => widget.onStart(_goal),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3748),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFF2D3748).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _goal == -1 ? 'Start (Unlimited)' : 'Start (Goal: ${_labels[_goal]})',
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
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

// ─── Favourites Tab ───────────────────────────────────────────────────────────

// class _FavouritesTab extends StatelessWidget {
//   final List<CustomDhikirItem> favorites;
//   final List<DhikirItem> builtInList;
//   final VoidCallback onRefresh;
//   final void Function(List<SessionDhikir>) onStartSession;

//   const _FavouritesTab({
//     required this.favorites,
//     required this.builtInList,
//     required this.onRefresh,
//     required this.onStartSession,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // All built-in dhikir available as session items
//     final builtInSession = builtInList.map((d) => SessionDhikir.fromItem(d)).toList();
//     final customSession = favorites.map((d) => SessionDhikir.fromCustom(d)).toList();
//     final combined = [...builtInSession, ...customSession];

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Quick session: all built-in
//             GestureDetector(
//               onTap: () => onStartSession(combined),
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF2D3748),
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [BoxShadow(color: const Color(0xFF2D3748).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.play_circle_rounded, color: Colors.white, size: 20),
//                     const SizedBox(width: 8),
//                     Text('Start Full Session — ${combined.length} Dhikir',
//                         style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Built-in section
//             SectionHeader(
//               title: 'Built-in Dhikir',
//               count: builtInList.length,
//               onSession: () => onStartSession(builtInSession),
//             ),
//             const SizedBox(height: 8),
//             ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [
//               ...builtInList.map((item) => FavRow(
//                     id: item.id,
//                     title: item.title,
//                     arabic: item.arabicText,
//                     transliteration: item.transliteration,
//                     icon: item.icon,
//                     colorHex: item.colorHex,
//                     isFavourite: false,
//                     showFavBtn: false,
//                     onSession: () => onStartSession([SessionDhikir.fromItem(item)]),
//                   )),
//             ]),
//             if (favorites.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               SectionHeader(
//                 title: 'My Favourite Dhikir',
//                 count: favorites.length,
//                 onSession: () => onStartSession(customSession),
//               ),
//               const SizedBox(height: 8),
//               ...favorites.map((item) => FavRow(
//                     id: item.id,
//                     title: item.title,
//                     arabic: item.arabicText,
//                     transliteration: item.transliteration,
//                     icon: item.icon,
//                     colorHex: item.colorHex,
//                     isFavourite: true,
//                     showFavBtn: true,
//                     onSession: () => onStartSession([SessionDhikir.fromCustom(item)]),
//                     onToggleFav: () async {
//                       await CustomDhikirService.toggleFavorite(item.id);
//                       onRefresh();
//                     },
//                   )),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
