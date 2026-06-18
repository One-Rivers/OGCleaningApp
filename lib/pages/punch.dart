/********************************************************************
* TITLE: Punch Clock Page
* FILENAME: punch.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   The logged-in employee. The page then fetches all shifts
*           from the server and finds this person's shift for today.
* OUTPUTS:  A punch clock screen: greeting, today's shift card, and
*           Punch In / Punch Out buttons that update the shift on
*           the server.
* DESCRIPTION: Punch In runs the on-site location verification first
*           (LocationPopup) and only sends the punch if the employee
*           is really at the site. Punch Out skips the check.
* NOTES:    UPDATED: confirmOnSite now gets the shift's locationId so
*           it knows WHICH site to measure distance to. Also added
*           mounted guards after the shift fetch.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* Translates the server's JSON text into Dart lists and maps. */
import 'dart:convert';

/* Flutter's standard UI toolkit. */
import 'package:flutter/material.dart';

/* Google fonts (Inter) without bundling font files. */
import 'package:google_fonts/google_fonts.dart';

/* How we talk to the server. */
import 'package:http/http.dart' as http;

/* Our Shift class and the server address (baseUrl). */
import '../shift_model.dart';

/* The location verification popup we just rebuilt. */
import 'Locationpopup.dart';

/********************************************************************************/
/* THE PAGE — what the rest of the app opens                                    */
/********************************************************************************/

/* Stateful because this page remembers things: today's shift and
   whether it's still loading. */
class PunchPage extends StatefulWidget {
  const PunchPage({super.key, required this.employee});

  /* The logged-in worker, passed in by whoever opened this page. */
  final Map<String, dynamic> employee;

  /* Boilerplate: connects this widget to its "brain" class below. */
  @override
  State<PunchPage> createState() => _PunchPageState();
}

/********************************************************************************/
/* THE BRAIN — the page's memory and all its actions                            */
/********************************************************************************/

class _PunchPageState extends State<PunchPage> {
  /* Today's shift for this employee. The "?" means it might be null
     (no shift scheduled today). */
  Shift? _todayShift;

  /* True while we wait on the server — controls the spinner. */
  bool _loading = true;

  /* Runs once when the page opens: go look up today's shift. */
  @override
  void initState() {
    super.initState();
    _findTodayShift();
  }

/********************************************************************************/
/* FINDING TODAY'S SHIFT — download all shifts, keep this person's              */
/********************************************************************************/

  Future<void> _findTodayShift() async {
    setState(() => _loading = true);
    try {
      /* Ask the server for every shift. */
      final response = await http.get(Uri.parse('$baseUrl/getShifts'));

      /* If the user already left this page while we waited, bail. */
      if (!mounted) return;

      if (response.statusCode == 200) {
        /* JSON text → list of real Shift objects. */
        final List<dynamic> data = jsonDecode(response.body);
        final shifts = data.map((j) => Shift.fromJson(j)).toList();

        final now = DateTime.now();
        Shift? found;

        /* Walk the list until we hit a shift that belongs to THIS
           employee AND starts today. "break" = stop looking. */
        for (final s in shifts) {
          if (s.employeeId == widget.employee['employeeId'] &&
              s.scheduleStart.year == now.year &&
              s.scheduleStart.month == now.month &&
              s.scheduleStart.day == now.day) {
            found = s;
            break;
          }
        }

        /* Save what we found (or null) and stop the spinner. */
        setState(() {
          _todayShift = found;
          _loading = false;
        });
      } else {
        /* Server answered with an error — stop the spinner anyway. */
        setState(() => _loading = false);
      }
    } catch (e) {
      /* No internet / server down — stop the spinner, don't crash. */
      if (mounted) setState(() => _loading = false);
    }
  }

/********************************************************************************/
/* THE PUNCH — what happens when a punch button gets tapped                     */
/********************************************************************************/

  Future<void> _punch({required bool punchingIn}) async {
    final shift = _todayShift;

    /* No shift today, or it has no database id → nothing to punch. */
    if (shift == null || shift.id == null) return;

    /* Punching IN requires the location check first. THE UPDATE:
       we now hand it the shift's site name (locationId) so it can
       fetch that site's coordinates and measure the distance. */
    if (punchingIn) {
      final onSite = await LocationPopup.confirmOnSite(
        context,
        locationId: shift.locationId,
      );

      /* Not verified on site → punch is off. */
      if (!onSite) return;
    }
    if (!mounted) return;

    try {
      /* Tell the server to update this shift: punching in flips
         clockIn on (and clockOut off); punching out flips clockOut on. */
      final response = await http.patch(
        Uri.parse('$baseUrl/updateShift/${shift.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(punchingIn
            ? {'clockIn': true, 'clockOut': false}
            : {'clockOut': true}),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        /* Success — little message at the bottom of the screen. */
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(punchingIn
                  ? 'Punched in! Have a great shift.'
                  : 'Punched out. See you next time!')),
        );

        /* Re-fetch the shift so the status card updates. */
        _findTodayShift();
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

/********************************************************************************/
/* LITTLE HELPERS — time formatting and the button builder                      */
/********************************************************************************/

  /* Turns a date into "HH:MM" text (09:05 instead of 9:5). */
  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  /* A factory for the two buttons — same shape, different label,
     color, and tap action. Saves writing it twice. */
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

/********************************************************************************/
/* BUILD — the actual screen layout                                             */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    /* The worker's name for the greeting; blank if missing. */
    final name = widget.employee['name'] ?? '';

    return Scaffold(
      /* Dark teal background for the whole page. */
      backgroundColor: const Color(0xFF12343B),

      /* Top bar: title in night blue, white text. */
      appBar: AppBar(
        title: const Text('Punch Clock'),
        backgroundColor: const Color(0xFF2D545E),
        foregroundColor: Colors.white,
      ),

      /* Still loading? Spinner. Otherwise the real content. */
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(24),

              /* Everything stacked vertically, centered, stretched
                 to full width. */
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /* The greeting. */
                  Text('Hello, $name',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  /* No shift today → just say so. The "...[ ]" spread
                     below means "otherwise show ALL of these widgets". */
                  if (_todayShift == null)
                    Text('No shift scheduled for today.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Colors.white70, fontSize: 16))
                  else ...[
/********************************************************************************/
/* THE SHIFT CARD — today's hours, site, and status                             */
/********************************************************************************/

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D545E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          /* Small faded label. */
                          Text("Today's shift",
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 6),

                          /* The hours, big and bold. The "!" means
                             "trust me, it's not null here" — we already
                             checked above. */
                          Text(
                              '${_time(_todayShift!.scheduleStart)} – ${_time(_todayShift!.scheduleEnd)}',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),

                          /* Where the shift is. */
                          Text(_todayShift!.locationId,
                              style: GoogleFonts.inter(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),

                          /* Clocked in or not, in sand gold. */
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

                    /* The two buttons, built by the helper up top. */
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
