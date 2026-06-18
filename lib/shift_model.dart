/********************************************************************
* TITLE: Shift Model + Server Address
* FILENAME: shift_model.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   Raw JSON from the server (fromJson) or values typed in
*           the Add Shift form (the constructor).
* OUTPUTS:  Shift objects the whole app can use, and JSON to send
*           back to the server (toJson).
* DESCRIPTION: The blueprint of what one shift looks like, plus the
*           translators between "server language" (JSON) and "app
*           language" (Dart objects). Also home of baseUrl — the
*           one place the server's address is written down.
* NOTES:    FIX in this version: clockOut now defaults to false in
*           BOTH spots (constructor and fromJson). It was true,
*           which created every new shift as already punched out —
*           same bug we fixed in the server's shifts.js.
*********************************************************************/

/********************************************************************************/
/* SERVER ADDRESS — every http call in the app builds on this                   */
/********************************************************************************/

/* Our backend living on Render. Change it here once and the whole
   app follows. */
const String baseUrl = 'https://ogcleaningapp.onrender.com';

/********************************************************************************/
/* THE SHIFT BLUEPRINT — what one shift is made of                               */
/********************************************************************************/

class Shift {
  /* The database's own id for this shift. The "?" means it can be
     null — a brand new shift has no id until the server saves it. */
  final String? id;

  /* Who works it. */
  final int employeeId;

  /* Where — the site's name, e.g. "Premier Office". Must match a
     real location name in the database. */
  final String locationId;

  /* When it's supposed to start and end. */
  final DateTime scheduleStart;
  final DateTime scheduleEnd;

  /* Punch state: has the worker actually started / finished? */
  final bool clockIn;
  final bool clockOut;

  /* Has a manager signed off on this shift? */
  final bool managerApproval;

/********************************************************************************/
/* CONSTRUCTOR — how the app builds a shift (e.g. the Add Shift form)           */
/********************************************************************************/

  Shift({
    this.id,
    required this.employeeId,
    required this.locationId,
    required this.scheduleStart,
    required this.scheduleEnd,

    /* Fresh shifts start un-punched... */
    this.clockIn = false,

    /* FIX: ...and NOT punched out. Was true, which meant every shift
       the manager created was born already clocked out. */
    this.clockOut = false,

    /* New shifts wait for a manager's blessing. */
    this.managerApproval = false,
  });

/********************************************************************************/
/* FROM JSON — translating what the server sends INTO a Shift                   */
/********************************************************************************/

  /* "factory" = a constructor that builds the object from raw
     material — here, the JSON map the server mailed us. */
  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      /* MongoDB calls its id "_id". */
      id: json['_id'],

      /* Careful: the server spells these all-lowercase
         (employeeid, locationid) — that's why they don't match
         our Dart names exactly. */
      employeeId: json['employeeid'],
      locationId: json['locationid'],

      /* The dates arrive as text in UTC (world time). parse() turns
         them into real DateTimes, toLocal() shifts them into the
         phone's own timezone. */
      scheduleStart: DateTime.parse(json['scheduleStart']).toLocal(),
      scheduleEnd: DateTime.parse(json['scheduleEnd']).toLocal(),

      /* The "??" means "if the server left this blank, assume...". */
      clockIn: json['clockIn'] ?? false,

      /* FIX: was "?? true" — a shift with no clockOut saved would
         wrongly count as punched out. Now assumes false. */
      clockOut: json['clockOut'] ?? false,
      managerApproval: json['managerApproval'] ?? false,
    );
  }

/********************************************************************************/
/* TO JSON — translating a Shift INTO what the server expects                   */
/********************************************************************************/

  /* Note: no id in here — the server/database hands out ids, we
     never send one. Dates go out as standard ISO text. */
  Map<String, dynamic> toJson() => {
        'employeeid': employeeId,
        'locationid': locationId,
        'scheduleStart': scheduleStart.toIso8601String(),
        'scheduleEnd': scheduleEnd.toIso8601String(),
        'clockIn': clockIn,
        'clockOut': clockOut,
        'managerApproval': managerApproval,
      };
}
