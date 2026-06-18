import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/modifyschedule.dart';

class ChangeScheduleButton extends StatelessWidget {
  const ChangeScheduleButton({super.key, required this.employee});

  final Map<String, dynamic> employee;

  @override
  Widget build(BuildContext context) {
    final bool certified = employee['certification'] ?? false;

    // Not certified → render nothing, only Punch In is visible
    if (!certified) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ModifySchedulePage()),
        );
      },
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color(0xFF2D545E), // night blue
        ),
        child: Text('Modify Schedule',
            style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
