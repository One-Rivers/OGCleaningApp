/********************************************************************
* TITLE: Punch Button
* FILENAME: PunchButton.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   An employee map (the logged-in worker's info).
* OUTPUTS:  A sand-tan "Punch In" button that grows when hovered
*           or pressed.
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

/* "StatefulWidget" = it DOES have memory now: it remembers whether
   the mouse is hovering and whether a finger is pressing it, so it
   can grow and shrink. */
class PunchButton extends StatefulWidget {
  /* The constructor — "required this.employee" means you MUST pass
     in an employee to create this button. */
  const PunchButton({
    super.key,
    required this.employee,
  });

  /* The employee's info, stored like a little dictionary.
     "final" = set once, never changes. */
  final Map<String, dynamic> employee;

  /* Boilerplate: connects this widget to its "brain" class below. */
  @override
  State<PunchButton> createState() => _PunchButtonState();
}

/********************************************************************************/
/* THE BUTTON'S BRAIN — remembers hover/press and draws the button              */
/********************************************************************************/

class _PunchButtonState extends State<PunchButton> {
  /* Is the mouse currently sitting on top of the button? */
  bool _hovering = false;

  /* Is a finger (or click) currently held down on it? */
  bool _pressed = false;

/********************************************************************************/
/* BUILD — where the button actually gets drawn on screen                       */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    /* Measure the phone screen so the button can size itself to
       fit any device. */
    final size = MediaQuery.of(context).size;

    /* Pick the size multiplier: pressed grows the most (8% bigger),
       hovering slightly (4%), normal = regular size. */
    final double scale = _pressed ? 1.08 : (_hovering ? 1.04 : 1.0);

    /* MouseRegion = the "hover sensor" (matters on web/desktop). */
    return MouseRegion(
      /* Mouse moved onto the button → remember it and redraw. */
      onEnter: (_) => setState(() => _hovering = true),

      /* Mouse left → forget it and redraw back to normal. */
      onExit: (_) => setState(() => _hovering = false),

      /* GestureDetector = the "touch sensor" wrapped around the button. */
      child: GestureDetector(
        /* Finger down → mark pressed (button grows). */
        onTapDown: (_) => setState(() => _pressed = true),

        /* Finger lifted → unmark pressed (shrinks back). */
        onTapUp: (_) => setState(() => _pressed = false),

        /* Tap got interrupted (finger slid away) → also shrink back. */
        onTapCancel: () => setState(() => _pressed = false),

        /* On tap: open the Punch page on top of this screen, and hand
           it the employee so it knows WHO is punching in. */
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PunchPage(employee: widget.employee)),
          );
        },

        /* AnimatedScale smoothly animates between sizes instead of
           snapping — 150ms, easing out at the end. */
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,

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

              /* The fill color — sand tan. */
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
        ),
      ),
    );
  }
}
