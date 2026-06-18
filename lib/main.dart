/********************************************************************
* TITLE: App Entry Point + Main Scheduler Page
* FILENAME: main.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   Nothing at startup. The scheduler page itself receives
*           the logged-in employee from the login page, then fetches
*           all shifts from the server.
* OUTPUTS:  The whole app. Boots into the login screen; after login,
*           shows the week schedule, team status (managers), and the
*           punch / modify-schedule buttons.
* DESCRIPTION: The front door of the app. main() starts everything,
*           MyApp sets the theme, and ShiftSchedulerPage is the home
*           screen gluing together all the components we built.
* NOTES:    Needs http and google_fonts. The pieces it assembles
*           live in lib/components and lib/pages.
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

/* The login screen (first thing the user sees). */
import 'pages/login.dart';

/* Our Shift class and the server address (baseUrl). */
import 'shift_model.dart';

/* The building blocks this page glues together: */
import 'components/WeekScheduleLayout.dart'; /* Sun–Sat columns */
import 'components/PunchButton.dart'; /* everyone's punch button */
import 'components/ChangeScheduleButton.dart'; /* certified-only button */
import 'components/EmployeeStatusList.dart'; /* manager-only team list */

/********************************************************************************/
/* APP STARTUP — the very first thing that runs                                 */
/********************************************************************************/

/* The ignition switch: Flutter calls main(), main() starts MyApp. */
void main() => runApp(const MyApp());

/* The app's outer shell: name, theme, and which page comes first. */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OG Cleaning Scheduler',

      /* Hides the red "DEBUG" ribbon in the corner. */
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        /* Use Google's latest design style. */
        useMaterial3: true,

        /* Build the whole color palette from our night blue. */
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D545E)),
      ),

      /* The first page shown: the login screen. */
      home: const SignInFive(),
    );
  }
}

/********************************************************************************/
/* MAIN SCHEDULER PAGE — week layout + punch + (manager) modify                 */
/* The login page jumps here after a successful sign-in.                        */
/********************************************************************************/

class ShiftSchedulerPage extends StatefulWidget {
  const ShiftSchedulerPage({super.key, required this.employee});

  /* The logged-in employee, passed from the login page. The
     components below use it to decide what this person can see. */
  final Map<String, dynamic> employee;

  /* Boilerplate: connects this widget to its "brain" class below. */
  @override
  State<ShiftSchedulerPage> createState() => _ShiftSchedulerPageState();
}

/********************************************************************************/
/* THE BRAIN — the page's memory and the shift download                         */
/********************************************************************************/

class _ShiftSchedulerPageState extends State<ShiftSchedulerPage> {
  /* Every shift from the server — shared with the week layout and
     the team status list so they don't each have to download it. */
  List<Shift> _shifts = [];

  /* True while waiting on the server — controls the spinner. */
  bool _isLoading = true;

  /* Holds an error message if something went wrong (null = all good). */
  String? _error;

  /* Runs once when the page opens: go get the shifts. */
  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  Future<void> _fetchShifts() async {
    /* Fresh start: spinner on, old error wiped. */
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      /* Ask the server for every shift. */
      final response = await http.get(Uri.parse('$baseUrl/getShifts'));

      if (response.statusCode == 200) {
        /* JSON text → list of real Shift objects, then redraw. */
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _shifts = data.map((j) => Shift.fromJson(j)).toList();
          _isLoading = false;
        });
      } else {
        /* Server answered but unhappy — remember the error code. */
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      /* Couldn't reach the server at all. */
      setState(() {
        _error = 'Cannot reach server.';
        _isLoading = false;
      });
    }
  }

/********************************************************************************/
/* BUILD — the page frame: background, top bar, refresh button                  */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12343B),
      appBar: AppBar(
        title: const Text('OG Cleaning Scheduler'),
        backgroundColor: const Color(0xFF2D545E),
        foregroundColor: Colors.white,
        actions: [
          /* The refresh arrow, top right — re-downloads the shifts. */
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchShifts,
              tooltip: 'Refresh'),
        ],
      ),

      /* The body is built by the helper below. */
      body: _buildBody(),
    );
  }

/********************************************************************************/
/* BODY — spinner, error screen, or the real content                            */
/********************************************************************************/

  Widget _buildBody() {
    /* Still downloading? Just the spinner. */
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    /* Something broke? Red icon, the message, and a Retry button. */
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchShifts, child: const Text('Retry')),
          ],
        ),
      );
    }

/********************************************************************************/
/* THE REAL CONTENT — stacked top to bottom                                     */
/********************************************************************************/

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /* "This Week" title. */
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('This Week',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ),

        /* Sun–Sat columns with each employee's shifts. */
        WeekScheduleLayout(shifts: _shifts),

        /* Manager-only team status list. For regular employees this
           widget renders nothing, so they just get empty space here. */
        Expanded(
          child: EmployeeStatusList(employee: widget.employee, shifts: _shifts),
        ),

        /* The bottom buttons, stretched edge to edge. */
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /* Everyone gets the punch button. */
              PunchButton(employee: widget.employee),

              /* Only renders when certification == true — the
                 managers' modify-schedule button. */
              ChangeScheduleButton(employee: widget.employee),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
