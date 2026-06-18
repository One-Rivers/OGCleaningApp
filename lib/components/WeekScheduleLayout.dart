import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shift_model.dart';

class WeekScheduleLayout extends StatelessWidget {
  const WeekScheduleLayout({super.key, required this.shifts});

  final List<Shift> shifts;

  static const List<String> dayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // DateTime.weekday: Mon=1 ... Sun=7, so weekday % 7 = days since Sunday
    final sunday = today.subtract(Duration(days: today.weekday % 7));

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: 7,
        itemBuilder: (context, i) {
          final day = sunday.add(Duration(days: i));
          final isToday = day == today;
          final dayShifts = shifts
              .where((s) =>
                  s.scheduleStart.year == day.year &&
                  s.scheduleStart.month == day.month &&
                  s.scheduleStart.day == day.day)
              .toList()
            ..sort((a, b) => a.scheduleStart.compareTo(b.scheduleStart));

          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color:
                  isToday ? const Color(0xFF2D545E) : const Color(0xFF12343B),
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(color: const Color(0xFFE1B382), width: 2)
                  : null,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(dayNames[i],
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      Text('${day.month}/${day.day}',
                          style: GoogleFonts.inter(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                Expanded(
                  child: dayShifts.isEmpty
                      ? Center(
                          child: Text('No shifts',
                              style: GoogleFonts.inter(
                                  color: Colors.white38, fontSize: 12)))
                      : ListView(
                          padding: const EdgeInsets.all(6),
                          children: dayShifts.map((s) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC89666),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Emp #${s.employeeId}',
                                      style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12)),
                                  Text(
                                      '${_time(s.scheduleStart)} – ${_time(s.scheduleEnd)}',
                                      style: GoogleFonts.inter(
                                          color: Colors.white, fontSize: 11)),
                                  Text(s.locationId,
                                      style: GoogleFonts.inter(
                                          color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
