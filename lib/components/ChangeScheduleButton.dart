/********************************************************************
* TITLE: Change Schedule Button
* FILENAME: ChangeScheduleButton.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   An employee map (their info, including whether they are
*           certified or not).
* OUTPUTS:  A dark blue "Modify Schedule" button on screen, or nothing
*           at all if the employee is not certified.
* DESCRIPTION: A reusable button that only shows up for certified
*           employees. Tapping it opens the Modify Schedule page.
* NOTES:    Needs the google_fonts package. Lives in lib/components.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* Flutter's standard UI toolkit. Buttons, text, containers, all the basics. */
import 'package:flutter/material.dart';

/* Lets us use Google fonts (like Inter) without downloading font files. */
import 'package:google_fonts/google_fonts.dart';

/* Our own Modify Schedule page, so the button knows what screen to open. */
import '../pages/modifyschedule.dart';

/********************************************************************************/
/* THE BUTTON ITSELF — a widget we can drop anywhere in the app                 */
/********************************************************************************/

/* "StatelessWidget" means this button has no memory of its own.
   It just draws itself based on whatever info you hand it. */
class ChangeScheduleButton extends StatelessWidget {
  /* The constructor — how other files create this button.
     "required this.employee" means you MUST pass in an employee to use it. */
  const ChangeScheduleButton({super.key, required this.employee});

  /* The employee's info, stored like a little dictionary:
     name, certification, etc. "final" means it never changes once set. */
  final Map<String, dynamic> employee;

/********************************************************************************/
/* BUILD — where the button actually gets drawn on screen                       */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    /* Peek at the employee's certification. If it's missing for some
       reason, the "?? false" means "just assume not certified". */
    final bool certified = employee['certification'] ?? false;

    /* Not certified? Return an invisible, zero-size box. Basically the
       button vanishes and only Punch In shows on screen. */
    if (!certified) return const SizedBox.shrink();

    /* Measure the phone screen so the button can size itself to fit
       any device, big or small. */
    final size = MediaQuery.of(context).size;

    /* GestureDetector = the "tap sensor". It wraps the button and
       listens for the user's finger. */
    return GestureDetector(
      /* What happens on tap: push the Modify Schedule page on top of
         the current screen, like putting a new card on a stack. */
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ModifySchedulePage()),
        );
      },

/********************************************************************************/
/* THE LOOKS — everything below is just styling the button                      */
/********************************************************************************/

      /* The visible box of the button. */
      child: Container(
        /* Keep whatever is inside (the text) dead center. */
        alignment: Alignment.center,

        /* Height is the screen height divided by 13, so it scales
           with the phone instead of being a fixed size. */
        height: size.height / 13,

        /* A little 12-pixel gap above the button so it doesn't
           touch whatever sits on top of it. */
        margin: const EdgeInsets.only(top: 12),

        /* The paint job: */
        decoration: BoxDecoration(
          /* Rounded corners, 10 pixels worth. */
          borderRadius: BorderRadius.circular(10.0),

          /* The fill color — that dark "night blue". */
          color: const Color(0xFF2D545E),
        ),

        /* The words on the button: white, semi-bold, Inter font,
           size 16. */
        child: Text('Modify Schedule',
            style: GoogleFonts.inter(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}
