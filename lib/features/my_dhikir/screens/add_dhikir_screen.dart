// lib/screens/add_dhikir_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dhikir_app/core/models/custom_dhikir_model.dart';
import 'package:dhikir_app/features/my_dhikir/providers/my_dhikir_provider.dart';
import 'package:dhikir_app/core/l10n/l10n_extensions.dart';
import 'package:dhikir_app/l10n/generated/app_localizations.dart';

class AddDhikirScreen extends StatelessWidget {
  final CustomDhikirItem? existing; // non-null = edit mode
  const AddDhikirScreen({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Scoped to this screen; auto-disposed when screen is popped.
      create: (_) => MyDhikirProvider(),
      child: _AddDhikirView(existing: existing),
    );
  }
}

class _AddDhikirView extends StatefulWidget {
  final CustomDhikirItem? existing;
  const _AddDhikirView({this.existing});

  @override
  State<_AddDhikirView> createState() => _AddDhikirViewState();
}

class _AddDhikirViewState extends State<_AddDhikirView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _arabicCtrl = TextEditingController();
  final _translitCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();

  late AnimationController _saveAnim;
  bool _saving = false;

  String _selectedColor = '#E8F5E9';
  String _selectedIcon = '🤍';

  static const List<String> _colorOptions = [
    '#E8F5E9',
    '#E3F2FD',
    '#FFF3E0',
    '#F3E5F5',
    '#E0F7FA',
    '#FFF8E1',
    '#FCE4EC',
    '#E8EAF6',
    '#F1F8E9',
    '#E0F2F1',
    '#FBE9E7',
    '#EDE7F6',
  ];

  static const List<String> _iconOptions = [
    '🤍',
    '⭐',
    '🌙',
    '☪️',
    '🤲',
    '✨',
    '💧',
    '🛡️',
    '💪',
    '🌿',
    '🕊️',
    '📿',
    '🌸',
    '🌺',
    '🌻',
    '🌟',
    '💫',
    '🔮',
    '🕌',
    '🌄',
    '🌅',
    '🙏',
  ];

  bool get _isEdit => widget.existing != null;

  String _colorLabel(AppLocalizations l10n, int i) => [
        l10n.colorMint,
        l10n.colorSky,
        l10n.colorSand,
        l10n.colorLavender,
        l10n.colorAqua,
        l10n.colorCream,
        l10n.colorRose,
        l10n.colorPeriwinkle,
        l10n.colorLime,
        l10n.colorTeal,
        l10n.colorCoral,
        l10n.colorViolet,
      ][i];

  @override
  void initState() {
    super.initState();
    _saveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (_isEdit) {
      final e = widget.existing!;
      _titleCtrl.text = e.title;
      _arabicCtrl.text = e.arabicText;
      _translitCtrl.text = e.transliteration;
      _meaningCtrl.text = e.englishMeaning;
      _selectedColor = e.colorHex;
      _selectedIcon = e.icon;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _arabicCtrl.dispose();
    _translitCtrl.dispose();
    _meaningCtrl.dispose();
    _saveAnim.dispose();
    super.dispose();
  }

  Color get _accentColor =>
      Color(int.parse(_selectedColor.replaceFirst('#', 'FF'), radix: 16));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    await context.read<MyDhikirProvider>().save(
          existing: widget.existing,
          title: _titleCtrl.text.trim(),
          arabicText: _arabicCtrl.text.trim(),
          transliteration: _translitCtrl.text.trim(),
          englishMeaning: _meaningCtrl.text.trim(),
          colorHex: _selectedColor,
          icon: _selectedIcon,
        );

    if (mounted) {
      HapticFeedback.heavyImpact();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F1),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: _accentColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.close_rounded,
                    size: 18, color: Color(0xFF2D3748)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: _saving ? null : _save,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _saving
                          ? Colors.white.withValues(alpha: 0.4)
                          : const Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isEdit ? l10n.addDhikirAppBarUpdate : l10n.commonSave,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: _accentColor,
                padding: const EdgeInsets.fromLTRB(24, 90, 24, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_selectedIcon,
                            style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEdit ? l10n.addDhikirEditTitle : l10n.addDhikirNewTitle,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3748),
                              ),
                            ),
                            Text(
                              _isEdit
                                  ? l10n.addDhikirEditSubtitle
                                  : l10n.addDhikirNewSubtitle,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF4A5568),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Icon picker ────────────────────────────────
                    _SectionLabel(l10n.chooseIconLabel),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _iconOptions.length,
                        itemBuilder: (_, i) {
                          final icon = _iconOptions[i];
                          final selected = icon == _selectedIcon;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = icon),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: selected
                                    ? _accentColor
                                    : const Color(0xFFF6F4F1),
                                borderRadius: BorderRadius.circular(10),
                                border: selected
                                    ? Border.all(
                                        color: const Color(0xFF4A5568),
                                        width: 1.5)
                                    : null,
                              ),
                              child: Center(
                                child: Text(icon,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Color picker ───────────────────────────────
                    _SectionLabel(l10n.chooseColorLabel),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: _colorOptions.length,
                        itemBuilder: (_, i) {
                          final hex = _colorOptions[i];
                          final color = Color(int.parse(
                              hex.replaceFirst('#', 'FF'),
                              radix: 16));
                          final selected = hex == _selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColor = hex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                                border: selected
                                    ? Border.all(
                                        color: const Color(0xFF2D3748),
                                        width: 2)
                                    : Border.all(
                                        color: Colors.transparent, width: 2),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                            color: color.withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1)
                                      ]
                                    : [],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (selected)
                                    const Icon(Icons.check_rounded,
                                        size: 12, color: Color(0xFF2D3748)),
                                  if (selected) const SizedBox(width: 4),
                                  Text(
                                    _colorLabel(l10n, i),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4A5568),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Form fields ────────────────────────────────
                    _SectionLabel(l10n.dhikirDetailsSection),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        children: [
                          _FormField(
                            controller: _titleCtrl,
                            label: l10n.titleFieldLabel,
                            maxLines: 2,
                            hint: l10n.titleFieldHint,
                            icon: Icons.title_rounded,
                            accentColor: _accentColor,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.titleRequiredError;
                              }
                              if (v.trim().length < 2) {
                                return l10n.titleTooShortError;
                              }
                              if (v.trim().length > 60) {
                                return l10n.titleTooLongError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            controller: _arabicCtrl,
                            label: l10n.arabicTextFieldLabel,
                            hint: l10n.arabicTextFieldHint,
                            icon: Icons.text_fields_rounded,
                            accentColor: _accentColor,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            fontFamily: 'Amiri',
                            maxLines: 4,
                            fontSize: 20,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.arabicTextRequiredError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            controller: _translitCtrl,
                            label: l10n.transliterationFieldLabel,
                            hint: l10n.transliterationFieldHint,
                            icon: Icons.translate_rounded,
                            accentColor: _accentColor,
                            maxLines: 4,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.transliterationRequiredError;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _FormField(
                            controller: _meaningCtrl,
                            label: l10n.meaningFieldLabel,
                            hint: l10n.meaningFieldHint,
                            icon: Icons.menu_book_rounded,
                            accentColor: _accentColor,
                            maxLines: 4,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return l10n.meaningRequiredError;
                              }
                              if (v.trim().length < 10) {
                                return l10n.meaningTooShortError;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Preview card ───────────────────────────────
                    _SectionLabel(l10n.previewSection),
                    const SizedBox(height: 10),
                    _PreviewCard(
                      title: _titleCtrl.text.isEmpty
                          ? l10n.previewDefaultTitle
                          : _titleCtrl.text,
                      arabicText: _arabicCtrl.text.isEmpty
                          ? l10n.previewDefaultArabic
                          : _arabicCtrl.text,
                      transliteration: _translitCtrl.text.isEmpty
                          ? l10n.previewDefaultTransliteration
                          : _translitCtrl.text,
                      icon: _selectedIcon,
                      color: _accentColor,
                    ),

                    const SizedBox(height: 20),

                    // ── Save button ────────────────────────────────
                    GestureDetector(
                      onTap: _saving ? null : _save,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _saving
                              ? const Color(0xFF718096)
                              : const Color(0xFF2D3748),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D3748)
                                  .withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Center(
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(_selectedIcon,
                                        style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isEdit ? l10n.addDhikirUpdateButton : l10n.addDhikirSaveButton,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.playfairDisplay(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2D3748),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color accentColor;
  final String? Function(String?)? validator;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final String? fontFamily;
  final double fontSize;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.accentColor,
    this.validator,
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.fontFamily,
    this.fontSize = 14,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF718096)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          textAlign: textAlign,
          textDirection: textDirection,
          maxLines: maxLines,
          style: fontFamily == 'Amiri'
              ? GoogleFonts.amiri(
                  fontSize: fontSize, color: const Color(0xFF2D3748))
              : GoogleFonts.inter(
                  fontSize: fontSize, color: const Color(0xFF2D3748)),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: fontSize,
              color: const Color(0xFFCBD5E0),
            ),
            filled: true,
            fillColor: const Color(0xFFF6F4F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFFC8181), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFC8181), width: 2),
            ),
            errorStyle:
                GoogleFonts.inter(fontSize: 11, color: const Color(0xFFE53E3E)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String title;
  final String arabicText;
  final String transliteration;
  final String icon;
  final Color color;

  const _PreviewCard({
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arabicText,
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D3748),
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                Text(
                  transliteration,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF718096),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
