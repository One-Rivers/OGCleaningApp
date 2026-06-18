/********************************************************************
* TITLE: Employee Status List
* FILENAME: EmployeeStatusList.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   The logged-in employee (to check if they are a manager)
*           and the full list of shifts the main page already fetched.
* OUTPUTS:  A scrollable "Team Status" list showing every employee
*           and whether they are clocked in or out. Managers only —
*           regular employees see nothing.
* DESCRIPTION: Pulls the employee list from the server, then matches
*           each person against the shifts to label them clocked
*           in (teal) or clocked out (sand).
* NOTES:    Needs the http and google_fonts packages. The server
*           address (baseUrl) comes from shift_model.dart.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* Lets us translate the server's JSON text into Dart lists and maps. */
import 'dart:convert';

/* Flutter's standard UI toolkit. */
import 'package:flutter/material.dart';

/* Google fonts (Inter) without bundling font files. */
import 'package:google_fonts/google_fonts.dart';

/* The http package — how we talk to the server. The "as http" part
   just gives it a nickname so we can write http.get(...). */
import 'package:http/http.dart' as http;

/* Our own Shift class and the server address (baseUrl). */
import '../shift_model.dart';

/********************************************************************************/
/* THE WIDGET — the public face other files use                                 */
/********************************************************************************/

/* "StatefulWidget" means this one DOES have memory — it needs to
   remember the employee list it downloads and whether it's still
   loading. */
class EmployeeStatusList extends StatefulWidget {
  const EmployeeStatusList({
    super.key,
    required this.employee,
    required this.shifts,
  });

  /* The logged-in user. We only care about their role here. */
  final Map<String, dynamic> employee;

  /* All shifts — the main page already fetched these, so we just
     reuse them instead of asking the server twice. */
  final List<Shift> shifts;

  /* Boilerplate: connects this widget to its "brain" class below. */
  @override
  State<EmployeeStatusList> createState() => _EmployeeStatusListState();
}

/********************************************************************************/
/* THE BRAIN — where the data lives and the screen gets built                   */
/********************************************************************************/

class _EmployeeStatusListState extends State<EmployeeStatusList> {
  /* The list of employees we download from the server. Starts empty. */
  List<dynamic> _employees = [];

  /* True while we're still waiting on the server. Controls the
     spinning loading circle. */
  bool _loading = true;

  /* A quick yes/no: is the logged-in user a manager? */
  bool get _isManager => widget.employee['role'] == 'manager';

  /* Runs ONCE when this widget first appears on screen. If the user
     is a manager, go download the employee list right away. */
  @override
  void initState() {
    super.initState();
    if (_isManager) _fetchEmployees();
  }

/********************************************************************************/
/* FETCHING — asking the server for the list of employees                       */
/********************************************************************************/

  Future<void> _fetchEmployees() async {
    /* try/catch = "attempt this, and if the internet blows up,
       don't crash the app". */
    try {
      /* Knock on the server's door at /getEmployees and wait
         for an answer. */
      final response = await http.get(Uri.parse('$baseUrl/getEmployees'));

      /* If the user already left this screen while we waited,
         bail out quietly. */
      if (!mounted) return;

      /* 200 = the server said "all good, here's your data". */
      if (response.statusCode == 200) {
        /* setState = "I changed something, redraw the screen". */
        setState(() {
          /* Turn the JSON text into a real Dart list. */
          _employees = jsonDecode(response.body);
          /* Done loading — hide the spinner. */
          _loading = false;
        });
      } else {
        /* Server answered but with an error — stop the spinner anyway. */
        setState(() => _loading = false);
      }
    } catch (e) {
      /* No internet / server down — stop the spinner so the screen
         isn't stuck spinning forever. */
      if (mounted) setState(() => _loading = false);
    }
  }

/********************************************************************************/
/* STATUS CHIP — the little "Clocked in / Clocked out" label                    */
/********************************************************************************/

  /* Every employee gets a status: clocked in if ANY of their shifts
     is punched in and not yet punched out — otherwise clocked out. */
  Widget _statusChip(int employeeId) {
    /* Scan all shifts: does this person have one that's started
       but not finished? */
    final working = widget.shifts
        .any((s) => s.employeeId == employeeId && s.clockIn && !s.clockOut);

    /* Pick the words... */
    final String label = working ? 'Clocked in ✓' : 'Clocked out';

    /* ...and the color: teal for working, sandy tan for off. */
    final Color color =
        working ? const Color(0xFF7BF4DF) : const Color(0xFFE1B382);

    /* Hand back a small bold piece of text in that color. */
    return Text(label,
        style: GoogleFonts.inter(
            color: color, fontSize: 12, fontWeight: FontWeight.w600));
  }

/********************************************************************************/
/* BUILD — where the whole list actually gets drawn on screen                   */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    /* Not a manager? Render an invisible nothing-box. Only managers
       see the team list. */
    if (!_isManager) return const SizedBox.shrink();

    /* Still waiting on the server? Show a white spinning circle. */
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    /* A Column stacks things vertically: title on top, list below. */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* The "Team Status" title with some breathing room around it. */
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Team Status',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ),

        /* Expanded = "take up all the leftover space on screen". */
        Expanded(
          /* ListView.builder only builds the rows you can actually
             see — efficient even with a huge team. */
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            /* How many rows to make: one per employee. */
            itemCount: _employees.length,

            /* The recipe for building row number i. */
            itemBuilder: (_, i) {
              /* Grab employee number i from the list. */
              final emp = _employees[i];

/********************************************************************************/
/* ONE ROW — the card for a single employee                                     */
/********************************************************************************/

              return Container(
                /* Small gap below each card so they don't touch. */
                margin: const EdgeInsets.only(bottom: 6),

                /* Padding INSIDE the card so the text isn't glued
                   to the edges. */
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

                /* Night blue card with rounded corners. */
                decoration: BoxDecoration(
                  color: const Color(0xFF2D545E),
                  borderRadius: BorderRadius.circular(10),
                ),

                /* A Row lays things out side by side:
                   icon | name | status chip. */
                child: Row(
                  children: [
                    /* Little person icon, soft white. */
                    const Icon(Icons.person, color: Colors.white70, size: 20),

                    /* 10 pixels of empty space after the icon. */
                    const SizedBox(width: 10),

                    /* The name + ID. Expanded makes it grab all the
                       middle space, pushing the status to the right. */
                    Expanded(
                      child: Text('${emp['name']}  (#${emp['employeeId']})',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),

                    /* The clocked in/out label from up above. */
                    _statusChip(emp['employeeId']),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
