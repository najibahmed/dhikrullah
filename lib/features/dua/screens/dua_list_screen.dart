// lib/features/dua/screens/dua_list_screen.dart
//
// Dua list for a single category, reached from DuaScreen's category tile.
// Data is passed in already-filtered via DuaListArgs — no asset reload here.
// Tapping a card records it in Recently viewed; opening with initialDuaId
// (from Home's Recently viewed strip) scrolls to and briefly highlights it.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/providers/font_size_provider.dart';
import 'package:dhikir_app/core/widgets/font_size_settings_dialog.dart';
import 'package:dhikir_app/features/dua/models/dua_item.dart';
import 'package:dhikir_app/features/dua/widgets/dua_card.dart';
import 'package:dhikir_app/features/recent/models/recent_item.dart';
import 'package:dhikir_app/features/recent/providers/recent_provider.dart';

const _duaFontSizeConfig = FontSizeConfig(
  id: 'dua',
  arabicDefault: 22,
  arabicMin: 16,
  arabicMax: 32,
  transliterationDefault: 12,
  transliterationMin: 10,
  transliterationMax: 20,
  meaningDefault: 13,
  meaningMin: 11,
  meaningMax: 20,
);

class DuaListScreen extends StatefulWidget {
  final String categoryName;
  final List<DuaItem> duas;
  final int? initialDuaId;

  const DuaListScreen({
    super.key,
    required this.categoryName,
    required this.duas,
    this.initialDuaId,
  });

  @override
  State<DuaListScreen> createState() => _DuaListScreenState();
}

class _DuaListScreenState extends State<DuaListScreen> {
  late final FontSizeProvider _fontSizeProvider =
      FontSizeProvider(_duaFontSizeConfig)..hydrate();

  final _targetKey = GlobalKey();
  late int? _highlightId = widget.initialDuaId;

  @override
  void initState() {
    super.initState();
    if (_highlightId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _targetKey.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          alignment: 0.1,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _highlightId = null);
    });
  }

  @override
  void dispose() {
    _fontSizeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _fontSizeProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.categoryName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => showFontSizeSettingsDialog(context),
              ),
            ),
          ],
        ),
        body: Scrollbar(
          thumbVisibility: true,
          // Non-lazy Column (categories hold only a handful of duas) so the
          // initialDuaId card is always built and can be scrolled to — a
          // ListView only builds cards near the viewport.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                for (final dua in widget.duas)
                  DuaCard(
                    key: dua.id == widget.initialDuaId ? _targetKey : null,
                    dua: dua,
                    categoryName: widget.categoryName,
                    highlighted: dua.id == _highlightId,
                    onTap: () => context.read<RecentProvider>().record(RecentItem.dua(dua.id, dua.category)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
