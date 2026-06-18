/********************************************************************
* TITLE: Login Fields and Sign In Button
* FILENAME: SignInButton.dart 
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   Text controllers (they hold what the user types), a
*           show/hide flag for the password, and tap functions.
* OUTPUTS:  Three reusable login pieces: an email box, a password box
*           with a show/hide eyeball, and a Sign In button that grows
*           when hovered or pressed and turns into a spinner while
*           logging in.
* DESCRIPTION: The building blocks of the login screen, kept in one
*           file so the login page itself stays short.
* NOTES:    Needs the flutter_svg and google_fonts packages.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* Flutter's standard UI toolkit. */
import 'package:flutter/material.dart';

/* Lets us draw SVG images (used for the thin divider line). */
import 'package:flutter_svg/svg.dart';

/* Google fonts (Inter) without bundling font files. */
import 'package:google_fonts/google_fonts.dart';

/********************************************************************************/
/* DIVIDER — the thin white line between the icon and the typing area           */
/********************************************************************************/

/* This is a tiny image described in text (SVG). It draws one white,
   slightly see-through vertical line, 15.5 pixels tall. Both text
   fields below reuse it. The underscore in front means "private —
   only this file can use it". */
const String _dividerSvg =
    '<svg viewBox="99.0 332.0 1.0 15.5" ><path transform="translate(99.0, 332.0)" d="M 0 0 L 0 15.5" fill="none" fill-opacity="0.6" stroke="#ffffff" stroke-width="1" stroke-opacity="0.6" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';

/********************************************************************************/
/* EMAIL FIELD — the box where the user types their email                       */
/********************************************************************************/

/* Stateless = no memory of its own. The controller that gets passed
   in is what actually remembers the typed text. */
class EmailField extends StatelessWidget {
  /* Constructor — you MUST hand it a controller to create it. */
  const EmailField({super.key, required this.controller});

  /* The controller is like a clipboard attached to the field — the
     login page reads the typed email off of it later. */
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    /* Measure the screen so the box scales to any phone. */
    final size = MediaQuery.of(context).size;

    /* The night blue rounded box that holds everything. */
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color(0xFF2D545E)),

      /* 16 pixels of breathing room on the left and right inside. */
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),

        /* Side by side: mail icon | divider line | typing area. */
        child: Row(children: <Widget>[
          /* The little envelope icon, soft white. */
          const Icon(Icons.mail_rounded, color: Colors.white70),

          /* 16 pixels of empty space. */
          const SizedBox(width: 16),

          /* The thin white divider line from up top. */
          SvgPicture.string(_dividerSvg, width: 1.0, height: 15.5),

          /* Another 16 pixels of space. */
          const SizedBox(width: 16),

          /* Expanded = the typing area takes all the leftover room. */
          Expanded(
              child: TextField(
            /* Hook up the clipboard that remembers the text. */
            controller: controller,

            /* One line only — no pressing enter for a second line. */
            maxLines: 1,

            /* The blinking cursor color. */
            cursorColor: Colors.white70,

            /* Brings up the email-style keyboard (with the @ key). */
            keyboardType: TextInputType.emailAddress,

            /* How the typed text looks: white Inter, size 14. */
            style: GoogleFonts.inter(
                fontSize: 14.0,
                color: Colors.white,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(

                /* The faded gray hint shown before they type. */
                hintText: 'Enter your email address',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500),

                /* Kill the default underline — our Container is
                   already the border. */
                border: InputBorder.none),
          )),
        ]),
      ),
    );
  }
}

/********************************************************************************/
/* PASSWORD FIELD — same box, but hides what you type + eyeball toggle          */
/********************************************************************************/

class PasswordField extends StatelessWidget {
  /* Needs three things: the controller, whether to hide the text
     right now, and what to do when the eyeball gets tapped. */
  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  /* The clipboard that remembers the typed password. */
  final TextEditingController controller;

  /* true = show dots, false = show the real letters. The login page
     owns this value — this field just obeys it. */
  final bool obscure;

  /* The function to run when the eyeball is tapped. VoidCallback
     just means "a function that takes nothing and returns nothing". */
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    /* Measure the screen so the box scales to any phone. */
    final size = MediaQuery.of(context).size;

    /* Same night blue rounded box as the email field. */
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color(0xFF2D545E)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),

        /* Side by side: lock icon | divider | typing area. */
        child: Row(children: <Widget>[
          /* The padlock icon this time. */
          const Icon(Icons.lock, color: Colors.white70),
          const SizedBox(width: 16),

          /* Same thin white divider line. */
          SvgPicture.string(_dividerSvg, width: 1.0, height: 15.5),
          const SizedBox(width: 16),
          Expanded(
              child: TextField(
            controller: controller,
            maxLines: 1,
            cursorColor: Colors.white70,

            /* THE password part: when obscure is true, every letter
               shows up as a dot. */
            obscureText: obscure,
            style: GoogleFonts.inter(
                fontSize: 14.0,
                color: Colors.white,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500),

                /* suffixIcon = a button glued to the right end of
                   the field. */
                suffixIcon: IconButton(
                  /* Slashed eyeball hides the password; tapping it
                     shows the password and removes the slash. */
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFFDFDFD),
                  ),

                  /* Tapping runs whatever the login page passed in
                     (it flips obscure and redraws). */
                  onPressed: onToggle,
                ),
                border: InputBorder.none),
          )),
        ]),
      ),
    );
  }
}

/********************************************************************************/
/* SIGN IN BUTTON — */
/*FINALLY grows on hover/press, spins while logging in                */
/********************************************************************************/

/* Stateful because this one DOES have memory: it tracks whether the
   mouse is hovering over it and whether a finger is pressing it. */
class SignInButton extends StatefulWidget {
  const SignInButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  /* true while the app is talking to the server — swaps the text
     for a spinner and disables tapping. */
  final bool isLoading;

  /* The function to run when tapped (the actual login attempt). */
  final VoidCallback onTap;

  /* Boilerplate: connects this widget to its "brain" class below. */
  @override
  State<SignInButton> createState() => _SignInButtonState();
}

/********************************************************************************/
/* THE BUTTON'S BRAIN — remembers hover/press and draws the button              */
/********************************************************************************/

class _SignInButtonState extends State<SignInButton> {
  /* Is the mouse currently sitting on top of the button? */
  bool _hovering = false;

  /* Is a finger (or click) currently held down on it? */
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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

      /* GestureDetector = the "touch sensor". */
      child: GestureDetector(
        /* Finger down → mark pressed (button grows). */
        onTapDown: (_) => setState(() => _pressed = true),

        /* Finger lifted → unmark pressed (shrinks back). */
        onTapUp: (_) => setState(() => _pressed = false),

        /* Tap got interrupted (finger slid away) → also shrink back. */
        onTapCancel: () => setState(() => _pressed = false),

        /* The real tap: if we're mid-login, do nothing (null =
           button disabled). Otherwise run the login function. */
        onTap: widget.isLoading ? null : widget.onTap,

        /* AnimatedScale smoothly animates between sizes instead of
           snapping — 150ms, easing out at the end. */
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,

/********************************************************************************/
/* THE LOOKS — the visible box, spinner, and text                               */
/********************************************************************************/

          child: Container(
            alignment: Alignment.center,
            height: size.height / 13,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),

              /* Dark teal while loading, sand tan when ready. */
              color: widget.isLoading
                  ? const Color(0xFF12343B)
                  : const Color(0xFFC89666),
            ),

            /* Loading? Show a small white spinner. Otherwise show
               the words "Sign in". */
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text('Sign in',
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
