// lib/features/dua/screens/dua_screen.dart
//
// Lists all duas from all_dua_en.json/all_dua_bn.json (picked per app
// locale by DuaService), filterable by category via a bottom sheet.
// Screen-local state only (selected category, loaded data) — not hoisted
// into the global Provider tree since only this screen needs it.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/providers/font_size_provider.dart';
import 'package:dhikir_app/core/theme/app_colors.dart';
import 'package:dhikir_app/core/widgets/font_size_settings_dialog.dart';
import 'package:dhikir_app/features/dua/models/dua_item.dart';
import 'package:dhikir_app/features/dua/services/dua_service.dart';
import 'package:dhikir_app/features/dua/widgets/dua_card.dart';
import 'package:dhikir_app/features/dua/widgets/dua_category_sheet.dart';

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

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final _service = const DuaService();
  late final Future<DuaData> _future = _service.load(context);
  late final FontSizeProvider _fontSizeProvider =
      FontSizeProvider(_duaFontSizeConfig)..hydrate();

  String? _selectedCategoryId;

  @override
  void dispose() {
    _fontSizeProvider.dispose();
    super.dispose();
  }

  Future<void> _openCategorySheet(DuaData data) async {
    final result = await showDuaCategorySheet(
      context,
      categories: data.categories,
      selected: _selectedCategoryId,
      totalCount: data.duas.length,
    );
    if (result != _selectedCategoryId) {
      setState(() => _selectedCategoryId = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ChangeNotifierProvider.value(
      value: _fontSizeProvider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            l10n.duaScreenTitle,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.dark),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => showFontSizeSettingsDialog(context),
              ),
            ),
          ],
        ),
        body: FutureBuilder<DuaData>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            final categoryName = _selectedCategoryId == null
                ? l10n.duaCategoryAll
                : data.categories
                    .firstWhere((c) => c.id == _selectedCategoryId)
                    .name;
            final filtered = _selectedCategoryId == null
                ? data.duas
                : data.duas
                    .where((d) => d.category == _selectedCategoryId)
                    .toList();

            return Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: _CategoryFilterButton(
                      label: categoryName,
                      onTap: () => _openCategorySheet(data),
                    ),
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final dua = filtered[index];
                        final catName = data.categories
                            .firstWhere((c) => c.id == dua.category)
                            .name;
                        return DuaCard(dua: dua, categoryName: catName);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryFilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CategoryFilterButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mintBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list_rounded,
                size: 16, color: AppColors.medium),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.medium),
          ],
        ),
      ),
    );
  }
}
