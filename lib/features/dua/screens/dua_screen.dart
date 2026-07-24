// lib/features/dua/screens/dua_screen.dart
//
// Dua category list — landing page for the Dua feature. Loads
// all_dua_en.json/all_dua_bn.json (picked per app locale by DuaService)
// and shows one tile per category; tapping a category pushes DuaListScreen
// with that category's duas. No "All duas" bypass, no filter/bottom sheet —
// the user always picks a category first.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/routing/app_routes.dart';
import 'package:dhikir_app/core/routing/route_names.dart';
import 'package:dhikir_app/features/dua/models/dua_item.dart';
import 'package:dhikir_app/features/dua/services/dua_service.dart';
import 'package:dhikir_app/features/dua/widgets/dua_category_tile.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  final _service = const DuaService();
  late final Future<DuaData> _future = _service.load(context);

  void _openCategory(DuaData data, DuaCategory category) {
    final duas = data.duas.where((d) => d.category == category.id).toList();
    Navigator.pushNamed(
      context,
      RouteNames.duaList,
      arguments: DuaListArgs(categoryName: category.name, duas: duas),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.duaScreenTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: FutureBuilder<DuaData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: data.categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = data.categories[index];
              return DuaCategoryTile(
                title: category.name,
                description: category.description,
                count: category.count,
                onTap: () => _openCategory(data, category),
              );
            },
          );
        },
      ),
    );
  }
}
