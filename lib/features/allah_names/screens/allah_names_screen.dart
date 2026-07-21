import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/theme/app_colors.dart';
import 'package:dhikir_app/features/allah_names/models/allah_name.dart';
import 'package:dhikir_app/features/allah_names/services/allah_names_service.dart';
import 'package:dhikir_app/features/allah_names/widgets/allah_name_card.dart';

class AllahNamesScreen extends StatefulWidget {
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen> {
  final _service = const AllahNamesService();
  late final Future<AllahNamesData> _future = _service.load(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          context.l10n.names99ScreenTitle,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.dark),
      ),
      body: FutureBuilder<AllahNamesData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: data.names.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _HeaderBanner(data: data);
              }
              return AllahNameCard(name: data.names[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _HeaderBanner extends StatelessWidget {
  final AllahNamesData data;

  const _HeaderBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accentMint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mintBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.4,
              color: AppColors.medium,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.hadith,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              fontStyle: FontStyle.italic,
              color: AppColors.subtle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.source,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.subtle,
            ),
          ),
        ],
      ),
    );
  }
}
