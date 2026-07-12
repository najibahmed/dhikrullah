// lib/core/widgets/session_setup_sheet.dart
//
// Goal-picker bottom sheet shown before starting a counter session.
// Shared by the dhikir (home), my-dhikir, and favorites features, so it
// lives in core/widgets rather than any single feature folder.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dhikir_app/features/counter/screens/session_counter_screen.dart';

class SessionSetupSheet extends StatefulWidget {
  final List<SessionDhikir> dhikirList;
  final void Function(int goal) onStart;

  const SessionSetupSheet({super.key, required this.dhikirList, required this.onStart});

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
