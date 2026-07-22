// lib/core/widgets/font_size_settings_dialog.dart
//
// Shared font-size settings dialog — 3 sliders (Arabic/transliteration/
// meaning) bound to whichever screen-scoped FontSizeProvider is above it in
// the tree. Any screen that constructs its own FontSizeProvider (Dua, Allah
// Names, ...) can open this same dialog via showFontSizeSettingsDialog
// (context); ranges/labels come from that provider's FontSizeConfig.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/core/providers/font_size_provider.dart';
import 'package:dhikir_app/core/theme/app_colors.dart';

const _kSliderActiveColor = Color(0xFF3D8B7D);

Future<void> showFontSizeSettingsDialog(BuildContext context) {
  // showDialog defaults to the root navigator, whose route sits outside the
  // caller's screen-scoped Provider subtree — so the provider instance must
  // be captured here and re-supplied explicitly to the dialog's subtree.
  final provider = context.read<FontSizeProvider>();
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => ChangeNotifierProvider.value(
      value: provider,
      child: const _FontSizeSettingsDialog(),
    ),
  );
}

class _FontSizeSettingsDialog extends StatelessWidget {
  const _FontSizeSettingsDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fontSize = context.watch<FontSizeProvider>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.fontSettingsTitle,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 16),
            _FontSizeSliderRow(
              label: l10n.arabicFontSizeLabel,
              value: fontSize.arabicFontSize,
              min: fontSize.config.arabicMin,
              max: fontSize.config.arabicMax,
              onChanged: (v) =>
                  context.read<FontSizeProvider>().setArabicFontSize(v),
            ),
            const SizedBox(height: 12),
            _FontSizeSliderRow(
              label: l10n.transliterationFontSizeLabel,
              value: fontSize.transliterationFontSize,
              min: fontSize.config.transliterationMin,
              max: fontSize.config.transliterationMax,
              onChanged: (v) => context
                  .read<FontSizeProvider>()
                  .setTransliterationFontSize(v),
            ),
            const SizedBox(height: 12),
            _FontSizeSliderRow(
              label: l10n.meaningFontSizeLabel,
              value: fontSize.meaningFontSize,
              min: fontSize.config.meaningMin,
              max: fontSize.config.meaningMax,
              onChanged: (v) =>
                  context.read<FontSizeProvider>().setMeaningFontSize(v),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontSizeSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _FontSizeSliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.medium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.round()}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _kSliderActiveColor,
            inactiveTrackColor: AppColors.accentMint,
            thumbColor: _kSliderActiveColor,
            overlayColor: _kSliderActiveColor.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
