/********************************************************************
* TITLE: Week Schedule Layout
* FILENAME: WeekScheduleLayout.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   The list of shifts (already fetched by the main page).
* OUTPUTS:  A sideways-scrolling row of 7 day columns (Sun–Sat) for
*           the current week, with today highlighted and each day
*           showing its shifts as little sand-tan cards.
* DESCRIPTION: Figures out what week we're in, splits the shifts up
*           by day, and draws one column per day. Days with nothing
*           scheduled just say "No shifts".
* NOTES:    Needs the google_fonts package. The Shift class comes
*           from shift_model.dart. Lives in lib/components.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* Flutter's standard UI toolkit. */
import 'package:flutter/material.dart';

/* Google fonts (Inter) without bundling font files. */
import 'package:google_fonts/google_fonts.dart';

/* Our own Shift class — the blueprint of what one shift looks like. */
import '../shift_model.dart';

/********************************************************************************/
/* THE WIDGET — the whole week-view strip                                       */
/********************************************************************************/

/* Stateless = no memory of its own. The main page hands it the
   shifts; this just draws them. */
class WeekScheduleLayout extends StatelessWidget {
  /* Constructor — you MUST pass in the list of shifts. */
  const WeekScheduleLayout({super.key, required this.shifts});

  /* The shifts to display. "final" = set once, never changes. */
  final List<Shift> shifts;

  /* The labels for the 7 column headers. "static const" = baked in
     at compile time, shared by every copy of this widget. */
  static const List<String> dayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  /* Tiny helper: turns a date into "HH:MM" text. padLeft makes sure
     9:5 prints as 09:05 instead. */
  String _time(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/********************************************************************************/
/* BUILD — figure out the week, then draw the 7 columns                         */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    /* What time is it right now? */
    final now = DateTime.now();

    /* Strip the clock off — keep just the date (midnight). Makes
       comparing days easy. */
    final today = DateTime(now.year, now.month, now.day);

    /* Walk backwards to the most recent Sunday. Dart numbers days
       Mon=1 ... Sun=7, so "weekday % 7" = how many days have passed
       since Sunday. */
    final sunday = today.subtract(Duration(days: today.weekday % 7));

    /* The whole strip is 300 pixels tall... */
    return SizedBox(
      height: 300,

      /* ...and scrolls SIDEWAYS, building one column per day. */
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),

        /* 7 columns — one per day of the week. */
        itemCount: 7,

        /* The recipe for column number i (0=Sun ... 6=Sat). */
        itemBuilder: (context, i) {
          /* This column's actual date: Sunday + i days. */
          final day = sunday.add(Duration(days: i));

          /* Is this column today? (Works because both have the
             clock stripped off.) */
          final isToday = day == today;

          /* Keep only the shifts that start on this exact date,
             then sort them earliest-first. The ".." means "do the
             sort on that same list, don't make a new one". */
          final dayShifts = shifts
              .where((s) =>
                  s.scheduleStart.year == day.year &&
                  s.scheduleStart.month == day.month &&
                  s.scheduleStart.day == day.day)
              .toList()
            ..sort((a, b) => a.scheduleStart.compareTo(b.scheduleStart));

/********************************************************************************/
/* ONE DAY COLUMN — the card for a single day                                   */
/********************************************************************************/

          return Container(
            /* Each column is 140 wide with a small gap on each side. */
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              /* Today gets the lighter night blue; other days get
                 the darker teal. */
              color:
                  isToday ? const Color(0xFF2D545E) : const Color(0xFF12343B),
              borderRadius: BorderRadius.circular(12),

              /* Today ALSO gets a 2-pixel sand outline. Other days
                 get no border at all. */
              border: isToday
                  ? Border.all(color: const Color(0xFFE1B382), width: 2)
                  : null,
            ),

            /* Stack inside the column: header, thin line, shifts. */
            child: Column(
              children: [
                /* The header: day name on top, date under it. */
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

                /* A thin faint line under the header. */
                const Divider(color: Colors.white24, height: 1),

                /* The rest of the column belongs to the shifts. */
                Expanded(
                  /* No shifts today? Say so in faded text. Otherwise
                     build a scrollable list of shift cards. */
                  child: dayShifts.isEmpty
                      ? Center(
                          child: Text('No shifts',
                              style: GoogleFonts.inter(
                                  color: Colors.white38, fontSize: 12)))
                      : ListView(
                          padding: const EdgeInsets.all(6),

                          /* Turn each shift into a card widget. */
                          children: dayShifts.map((s) {
/********************************************************************************/
/* ONE SHIFT CARD — the small sand-tan box inside a day                         */
/********************************************************************************/

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC89666),
                                borderRadius: BorderRadius.circular(8),
                              ),

                              /* Three stacked lines, left-aligned: */
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /* Line 1: who's working. */
                                  Text('Emp #${s.employeeId}',
                                      style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12)),

                                  /* Line 2: start – end times, using
                                     the _time helper from up top. */
                                  Text(
                                      '${_time(s.scheduleStart)} – ${_time(s.scheduleEnd)}',
                                      style: GoogleFonts.inter(
                                          color: Colors.white, fontSize: 11)),

                                  /* Line 3: where the shift is. */
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
