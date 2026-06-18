import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../shift_model.dart';
import 'Locationpopup.dart';

class PunchPage extends StatefulWidget {
  const PunchPage({super.key, required this.employee});

  final Map<String, dynamic> employee;

  @override
  State<PunchPage> createState() => _PunchPageState();
}

class _PunchPageState extends State<PunchPage> {
  Shift? _todayShift;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _findTodayShift();
  }

  // Find this employee's shift scheduled for today
  Future<void> _findTodayShift() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse('$baseUrl/getShifts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final shifts = data.map((j) => Shift.fromJson(j)).toList();
        final now = DateTime.now();
        Shift? found;
        for (final s in shifts) {
          if (s.employeeId == widget.employee['employeeId'] &&
              s.scheduleStart.year == now.year &&
              s.scheduleStart.month == now.month &&
              s.scheduleStart.day == now.day) {
            found = s;
            break;
          }
        }
        setState(() {
          _todayShift = found;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _punch({required bool punchingIn}) async {
    final shift = _todayShift;
    if (shift == null || shift.id == null) return;

    // Punching in requires the location check first
    if (punchingIn) {
      final onSite = await LocationPopup.confirmOnSite(context);
      if (!onSite) return;
    }
    if (!mounted) return;

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/updateShift/${shift.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(punchingIn
            ? {'clockIn': true, 'clockOut': false}
            : {'clockOut': true}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(punchingIn
                  ? 'Punched in! Have a great shift.'
                  : 'Punched out. See you next time!')),
        );
        _findTodayShift(); // refresh the status display
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Punch failed — try again')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reach server')),
        );
      }
    }
  }

  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _punchButton(String label, Color color, VoidCallback onTap) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color,
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.employee['name'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF12343B),
      appBar: AppBar(
        title: const Text('Punch Clock'),
        backgroundColor: const Color(0xFF2D545E),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Hello, $name',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  if (_todayShift == null)
                    Text('No shift scheduled for today.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 16))
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D545E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text("Today's shift",
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(
                              '${_time(_todayShift!.scheduleStart)} – ${_time(_todayShift!.scheduleEnd)}',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          Text(_todayShift!.locationId,
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                              _todayShift!.clockIn
                                  ? 'Status: Clocked in ✓'
                                  : 'Status: Not clocked in',
                              style: GoogleFonts.inter(
                                  color: const Color(0xFFE1B382),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _punchButton('Punch In', const Color(0xFFC89666),
                        () => _punch(punchingIn: true)),
                    const SizedBox(height: 12),
                    _punchButton('Punch Out', const Color(0xFF2D545E),
                        () => _punch(punchingIn: false)),
                  ],
                ],
              ),
            ),
    );
  }
}
