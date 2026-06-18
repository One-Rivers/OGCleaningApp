/********************************************************************
* TITLE: Login Page (Sign In Five)
* FILENAME: login.dart
* AUTHOR: Juan M. Rios
* DATE: 06/11/2026
* INSTRUCTOR:  Dr. Rafiq
* COURSE: CIS 350
* SECTION: 01
* INPUTS:   The email and password the user types in.
* OUTPUTS:  On success: hands the employee's info to the scheduler
*           page and switches to it. On failure: a message saying
*           what went wrong.
* DESCRIPTION: The first screen of the app. Black-to-blue gradient,
*           two faint hexagon decorations, the logo, and the login
*           form. Sends the credentials to our server's /login and
*           waits for the verdict.
* NOTES:    Needs flutter_svg, google_fonts, http. The email field,
*           password field, and animated button live in
*           components/SignInButton.dart.
*********************************************************************/

/********************************************************************************/
/* IMPORTS — grabbing the tools this file needs                                 */
/********************************************************************************/

/* Translates JSON text to/from Dart maps (for talking to the server). */
import 'dart:convert';

/* Flutter's standard UI toolkit. */
import 'package:flutter/material.dart';

/* Draws the SVG hexagon decorations. */
import 'package:flutter_svg/svg.dart';

/* Google fonts (Inter) without bundling font files. */
import 'package:google_fonts/google_fonts.dart';

/* How we talk to the server. */
import 'package:http/http.dart' as http;

/* The scheduler page we jump to after a good login. */
import '../main.dart';

/* Our server address (baseUrl). */
import '../shift_model.dart';

/* The email field, password field, and Sign In button. */
import '../components/SignInButton.dart';

/********************************************************************************/
/* THE PAGE — what main.dart opens first                                        */
/********************************************************************************/

/* Stateful because this page remembers what's typed, whether the
   password is hidden, and whether we're mid-login. */
class SignInFive extends StatefulWidget {
  const SignInFive({Key? key}) : super(key: key);

  @override
  State<SignInFive> createState() => _SignInFiveState();
}

/********************************************************************************/
/* THE BRAIN — the page's memory and the login logic                            */
/********************************************************************************/

class _SignInFiveState extends State<SignInFive> {
  /* The "clipboards" that hold whatever gets typed in each box. */
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  /* True while we're waiting on the server — the button shows a
     spinner and refuses taps. */
  bool _isLoading = false;

  /* True = password shows as dots. The eyeball toggles this. */
  bool obscurePassword = true;

/********************************************************************************/
/* LOGIN LOGIC — what happens when Sign In gets tapped                          */
/********************************************************************************/

  Future<void> _login() async {
    /* Grab what they typed. trim() chops off accidental spaces. */
    final email = emailController.text.trim();
    final password = passController.text.trim();

    /* Left something blank? Tell them and stop right here. */
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    /* Flip the button into spinner mode. */
    setState(() => _isLoading = true);

    try {
      /* Mail the credentials to the server's /login door and wait. */
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      /* User left the page while we waited? Bail quietly. */
      if (!mounted) return;

      if (response.statusCode == 200) {
        /* 200 = good login. Unpack the employee the server sent back. */
        final body = jsonDecode(response.body);
        final employee = Map<String, dynamic>.from(body['employee']);
        final bool certified = employee['certification'] ?? false;
        final String name = employee['name'] ?? '';

        /* Certified employees get a greeting; others go straight in. */
        if (certified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome back, $name!')),
          );
        }

        /* Jump to the scheduler page and hand it the employee.
           "pushReplacement" = replace this page entirely, so the
           back button can't return to the login screen.
           This is also where managers get the ability to modify
           the schedule — the scheduler checks the employee's role. */
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => ShiftSchedulerPage(employee: employee)),
        );
      } else {
        /* Server said no (wrong password, unknown email...). Show
           the server's error message if it sent one. */
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['error'] ?? 'Invalid credentials')),
        );
      }
    } catch (e) {
      /* Couldn't reach the server at all (no internet, server down). */
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not connect to server')),
        );
      }
    } finally {
      /* "finally" runs NO MATTER WHAT happened above — success or
         crash, the spinner always gets turned off. */
      if (mounted) setState(() => _isLoading = false);
    }
  }

/********************************************************************************/
/* BUILD — the actual screen layout                                             */
/********************************************************************************/

  @override
  Widget build(BuildContext context) {
    /* Measure the screen so everything scales to the device. */
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,

      /* The background: a top-to-bottom gradient that stays black
         for the top half, then fades into night blue by the bottom. */
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              /* black at the very top */
              Color(0xFF000000),
              /* still black — holds until 50% */
              Color(0xFF2D545E), /* night blue at the bottom */
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),

        /* SafeArea = stay clear of the phone's notch and system bars. */
        child: SafeArea(
          child: SizedBox(
            height: size.height,

            /* Stack = layers on top of each other: two decorations
               in the back, the real content in front. */
            child: Stack(
              children: <Widget>[
/********************************************************************************/
/* DECORATIONS — the two faint hexagon outlines in the background               */
/********************************************************************************/

                /* Small hexagon, poking in from the left edge (the
                   negative "left" pushes it partly off screen). */
                Positioned(
                  left: -34,
                  top: 181.0,
                  child: SvgPicture.string(
                      '<svg viewBox="-34.0 181.0 99.0 99.0" ><path transform="translate(-34.0, 181.0)" d="M 74.25 0 L 99 49.5 L 74.25 99 L 24.74999618530273 99 L 0 49.49999618530273 L 24.7500057220459 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(-26.57, 206.25)" d="M 0 0 L 42.07500076293945 16.82999992370605 L 84.15000152587891 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(15.5, 223.07)" d="M 0 56.42999649047852 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                      width: 99.0,
                      height: 99.0),
                ),

                /* Bigger hexagon, poking in from the right edge. */
                Positioned(
                  right: -52,
                  top: 45.0,
                  child: SvgPicture.string(
                      '<svg viewBox="288.0 45.0 139.0 139.0" ><path transform="translate(288.0, 45.0)" d="M 104.25 0 L 139 69.5 L 104.25 139 L 34.74999618530273 139 L 0 69.5 L 34.75000762939453 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(298.42, 80.45)" d="M 0 0 L 59.07500076293945 23.63000106811523 L 118.1500015258789 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(357.5, 104.07)" d="M 0 79.22999572753906 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                      width: 139.0,
                      height: 139.0),
                ),

/********************************************************************************/
/* THE CONTENT — logo, title, and the login form                                */
/********************************************************************************/

                Positioned(
                  top: 8.0,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,

                    /* Side margins = 6% of the screen width. */
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.06),

                      /* The screen is split into three vertical zones
                         using "flex" — think of it as 3:1:4 slices
                         of the available height. */
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /* ZONE 1 (3 slices): logo + LOG IN PAGE title. */
                          Expanded(
                              flex: 3,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 16),
                                    Image.asset(
                                      'assets/logo.png',
                                      height: 120,
                                    ),
                                    const SizedBox(height: 20),
                                    richText(23.12),
                                  ])),

                          /* ZONE 2 (1 slice): the little instruction line. */
                          Expanded(
                              flex: 1,
                              child: Text(
                                'Sign in with your employee account',
                                style: GoogleFonts.inter(
                                    fontSize: 14.0, color: Colors.white),
                              )),

                          /* ZONE 3 (4 slices): the actual form —
                             email, password, button. */
                          Expanded(
                              flex: 4,
                              child: Column(children: [
                                /* Email box, hooked to its clipboard. */
                                EmailField(controller: emailController),
                                const SizedBox(height: 8),

                                /* Password box: obeys obscurePassword,
                                   and the eyeball tap flips it. */
                                PasswordField(
                                  controller: passController,
                                  obscure: obscurePassword,
                                  onToggle: () => setState(
                                      () => obscurePassword = !obscurePassword),
                                ),
                                const SizedBox(height: 16),

                                /* The button: spins while loading,
                                   runs _login when tapped. */
                                SignInButton(
                                    isLoading: _isLoading, onTap: _login),
                              ])),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

/********************************************************************************/
/* TITLE HELPER — builds the two-tone "LOG IN PAGE" text                        */
/********************************************************************************/

  /* Text.rich lets one line of text mix styles: "LOG IN " stays
     white, "PAGE" goes cream colored. (Heads up: the fontSize
     parameter is currently ignored — 23.12 is hardcoded inside.) */
  Widget richText(double fontSize) {
    return Text.rich(TextSpan(
      style: GoogleFonts.inter(
          fontSize: 23.12, color: Colors.white, letterSpacing: 2.0),
      children: const [
        TextSpan(
            text: 'LOG IN ', style: TextStyle(fontWeight: FontWeight.w800)),
        TextSpan(
            text: 'PAGE',
            style: TextStyle(
                color: Color(0xFFFFE4C2), fontWeight: FontWeight.w800)),
      ],
    ));
  }
}
