/********************************************************************
* TITLE: Punch Button
* FILENAME: PunchButton.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   An employee map (the logged-in worker's info).
* OUTPUTS:  A sand-tan "Punch In" button on screen.
* DESCRIPTION: A reusable button that every employee sees. Tapping it
*           opens the Punch page, carrying the employee's info along
*           so that page knows who is punching in.
* NOTES:    Needs the google_fonts package. Lives in lib/components.
*           Unlike ChangeScheduleButton, there is no certification
*           check — everyone gets this button.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* Flutter's standard UI toolkit. */
import 'package:flutter/material.dart';

/* Google fonts (Inter) without bundling font files. */
import 'package:google_fonts/google_fonts.dart';

/* Our own Punch page, so the button knows what screen to open. */
import '../pages/punch.dart';

/********************************************************************************/
/* THE BUTTON ITSELF — a widget we can drop anywhere in the app                 */
/********************************************************************************/

/* "StatelessWidget" = no memory of its own. It just draws itself
   based on the employee you hand it. */
class PunchButton extends StatelessWidget {
  /* The constructor — "required this.employee" means you MUST pass
     in an employee to create this button. */
  const PunchButton({super.key, required this.employee});

  /* The employee's info, stored like a little dictionary.
     "final" = set once, never changes. */
  final Map<String, dynamic> employee;

/********************************************************************************/
/* BUILD — where the button actually gets drawn on screen                       */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    /* Measure the phone screen so the button can size itself to
       fit any device. */
    final size = MediaQuery.of(context).size;

    /* GestureDetector = the "tap sensor" wrapped around the button. */
    return GestureDetector(
      /* On tap: open the Punch page on top of this screen, and hand
         it the employee so it knows WHO is punching in. */
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PunchPage(employee: employee)),
        );
      },

/********************************************************************************/
/* THE LOOKS — everything below is just styling the button                      */
/********************************************************************************/

      /* The visible box of the button. */
      child: Container(
        /* Keep the text dead center. */
        alignment: Alignment.center,

        /* Height = screen height divided by 13, so it scales with
           the phone instead of being a fixed size. */
        height: size.height / 13,

        /* The paint job: */
        decoration: BoxDecoration(
          /* Rounded corners, 10 pixels worth. */
          borderRadius: BorderRadius.circular(10.0),

          /* The fill color — sand tan shadow. */
          color: const Color(0xFFC89666),
        ),

        /* The words on the button: white, semi-bold, Inter font,
           size 16. */
        child: Text('Punch In',
            style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
