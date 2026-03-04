import 'package:dhikir_app/screens/my_dhikir_screen.dart';
import 'package:dhikir_app/screens/session_counter_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/dhikir_data.dart' as built_in;
import '../providers/favorites_provider.dart';
import '../services/custom_dhikir_service.dart';
import '../widgets/fav_row.dart';
import '../widgets/section_header.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({
    super.key,
  });

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
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

  void _startSession(List<SessionDhikir> list, int goal) {
    if (list.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SessionCounterScreen(
          dhikirList: list,
          sharedGoal: goal,
        ),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider so UI rebuilds on any favourite change.
    final favProvider = context.watch<FavoritesProvider>();
    final favIds = favProvider.all;

    final customFavorites = CustomDhikirService.getFavorites();
    final builtInFavorites = built_in.dhikirList.where((d) => favIds.contains(d.id)).toList();
    final favBuiltInSession = builtInFavorites.map((d) => SessionDhikir.fromItem(d)).toList();
    final customSession = customFavorites.map((d) => SessionDhikir.fromCustom(d)).toList();
    final List<SessionDhikir> combined = [...customSession, ...favBuiltInSession];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: combined.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Icon(
                    Icons.favorite,
                    size: 70,
                  ),
                  const SizedBox(height: 16),
                  Text('No favorite dhikir yet',
                      style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                  const SizedBox(height: 8),
                  Text('Tap the heart icon to favorite your dhikir',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF718096), height: 1.5), textAlign: TextAlign.center)
                ],
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      // Quick session: all built-in
                      [
                    if (combined.isNotEmpty)
                      GestureDetector(
                        onTap: () => _showSessionSetup(combined),
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
                              Text('Start Full Session — ${combined.length} Dhikir',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (customFavorites.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: 'Custom Favourite Dhikir',
                        count: customSession.length,
                        onSession: () => _showSessionSetup(customSession),
                      ),
                      const SizedBox(height: 8),
                      ...customFavorites.map((item) => FavRow(
                            id: item.id,
                            title: item.title,
                            arabic: item.arabicText,
                            transliteration: item.transliteration,
                            icon: item.icon,
                            colorHex: item.colorHex,
                            onSession: () => _showSessionSetup([SessionDhikir.fromCustom(item)]),
                            onToggleFav: () => context.read<FavoritesProvider>().toggle(item.id),
                          )),
                    ],
                    if (favBuiltInSession.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: 'Favourite Dhikir',
                        count: favBuiltInSession.length,
                        onSession: () => _showSessionSetup(favBuiltInSession),
                      ),
                      const SizedBox(height: 8),
                      ...favBuiltInSession.map((item) => FavRow(
                            id: item.id,
                            title: item.title,
                            arabic: item.arabicText,
                            transliteration: item.transliteration,
                            icon: item.icon,
                            colorHex: item.colorHex,
                            onSession: () => _showSessionSetup([item]),
                            onToggleFav: () => context.read<FavoritesProvider>().toggle(item.id),
                          )),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
