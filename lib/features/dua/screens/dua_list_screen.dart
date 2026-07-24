// lib/features/dua/screens/dua_list_screen.dart
//
// Dua list for a single category, reached from DuaScreen's category tile.
// Data is passed in already-filtered via DuaListArgs — no asset reload here.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/providers/font_size_provider.dart';
import 'package:dhikir_app/core/widgets/font_size_settings_dialog.dart';
import 'package:dhikir_app/features/dua/models/dua_item.dart';
import 'package:dhikir_app/features/dua/widgets/dua_card.dart';

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

  const DuaListScreen({
    super.key,
    required this.categoryName,
    required this.duas,
  });

  @override
  State<DuaListScreen> createState() => _DuaListScreenState();
}

class _DuaListScreenState extends State<DuaListScreen> {
  late final FontSizeProvider _fontSizeProvider =
      FontSizeProvider(_duaFontSizeConfig)..hydrate();

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
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: widget.duas.length,
            itemBuilder: (context, index) {
              final dua = widget.duas[index];
              return DuaCard(dua: dua, categoryName: widget.categoryName);
            },
          ),
        ),
      ),
    );
  }
}
