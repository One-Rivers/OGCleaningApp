import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../shift_model.dart';
import '../components/SignInButton.dart';

class SignInFive extends StatefulWidget {
  const SignInFive({Key? key}) : super(key: key);

  @override
  State<SignInFive> createState() => _SignInFiveState();
}

class _SignInFiveState extends State<SignInFive> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool _isLoading = false;
  bool obscurePassword = true;

  // ── Login Logic ─────────────────────────────────────────────
  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final employee = Map<String, dynamic>.from(body['employee']);
        final bool certified = employee['certification'] ?? false;
        final String name = employee['name'] ?? '';

        // certified employees get a greeting; others go straight in
        if (certified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Welcome back, $name!')),
          );
        }

        // hand the employee data to the scheduler page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              /* This is also where if they are a manager they get the ability to modify the schedule*/
              builder: (_) => ShiftSchedulerPage(employee: employee)),
        );
      } else {
        final body = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['error'] ?? 'Invalid credentials')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not connect to server')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── UI ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000), // Black
              Color(0xFF000000), // Still black — holds until 50%
              Color(0xFFE1B382), // Sand tan at the bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: size.height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: -34,
                  top: 181.0,
                  child: SvgPicture.string(
                      '<svg viewBox="-34.0 181.0 99.0 99.0" ><path transform="translate(-34.0, 181.0)" d="M 74.25 0 L 99 49.5 L 74.25 99 L 24.74999618530273 99 L 0 49.49999618530273 L 24.7500057220459 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(-26.57, 206.25)" d="M 0 0 L 42.07500076293945 16.82999992370605 L 84.15000152587891 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(15.5, 223.07)" d="M 0 56.42999649047852 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                      width: 99.0,
                      height: 99.0),
                ),
                Positioned(
                  right: -52,
                  top: 45.0,
                  child: SvgPicture.string(
                      '<svg viewBox="288.0 45.0 139.0 139.0" ><path transform="translate(288.0, 45.0)" d="M 104.25 0 L 139 69.5 L 104.25 139 L 34.74999618530273 139 L 0 69.5 L 34.75000762939453 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(298.42, 80.45)" d="M 0 0 L 59.07500076293945 23.63000106811523 L 118.1500015258789 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(357.5, 104.07)" d="M 0 79.22999572753906 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                      width: 139.0,
                      height: 139.0),
                ),
                Positioned(
                  top: 8.0,
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.06),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          Expanded(
                              flex: 1,
                              child: Text(
                                'Sign in with your employee account',
                                style: GoogleFonts.inter(
                                    fontSize: 14.0, color: Colors.white),
                              )),
                          Expanded(
                              flex: 4,
                              child: Column(children: [
                                EmailField(controller: emailController),
                                const SizedBox(height: 8),
                                PasswordField(
                                  controller: passController,
                                  obscure: obscurePassword,
                                  onToggle: () => setState(
                                      () => obscurePassword = !obscurePassword),
                                ),
                                const SizedBox(height: 16),
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

  Widget richText(double fontSize) {
    return Text.rich(TextSpan(
      style: GoogleFonts.inter(
          fontSize: 23.12, color: Colors.white, letterSpacing: 2.0),
      children: const [
        TextSpan(text: 'LOGIN', style: TextStyle(fontWeight: FontWeight.w800)),
        TextSpan(
            text: 'PAGE',
            style: TextStyle(
                color: Color(0xFFFFE4C2), fontWeight: FontWeight.w800)),
      ],
    ));
  }
}
