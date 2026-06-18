import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/punch.dart';

class PunchButton extends StatelessWidget {
  const PunchButton({super.key, required this.employee});

  final Map<String, dynamic> employee;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PunchPage(employee: employee)),
        );
      },
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color(0xFFC89666), // sand tan shadow
        ),
        child: Text('Punch In',
            style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
