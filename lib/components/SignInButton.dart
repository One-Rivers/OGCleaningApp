import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

// thin white divider used inside both text fields
const String _dividerSvg =
    '<svg viewBox="99.0 332.0 1.0 15.5" ><path transform="translate(99.0, 332.0)" d="M 0 0 L 0 15.5" fill="none" fill-opacity="0.6" stroke="#ffffff" stroke-width="1" stroke-opacity="0.6" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';

class EmailField extends StatelessWidget {
  const EmailField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color(0xFF2D545E)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: <Widget>[
          const Icon(Icons.mail_rounded, color: Colors.white70),
          const SizedBox(width: 16),
          SvgPicture.string(_dividerSvg, width: 1.0, height: 15.5),
          const SizedBox(width: 16),
          Expanded(
              child: TextField(
            controller: controller,
            maxLines: 1,
            cursorColor: Colors.white70,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(
                fontSize: 14.0,
                color: Colors.white,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
                hintText: 'Enter your email address',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500),
                border: InputBorder.none),
          )),
        ]),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: const Color(0xFF2D545E)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(children: <Widget>[
          const Icon(Icons.lock, color: Colors.white70),
          const SizedBox(width: 16),
          SvgPicture.string(_dividerSvg, width: 1.0, height: 15.5),
          const SizedBox(width: 16),
          Expanded(
              child: TextField(
            controller: controller,
            maxLines: 1,
            cursorColor: Colors.white70,
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
                suffixIcon: IconButton(
                  /* Slashed eyeball hides the password; tapping it
                     shows the password and removes the slash. */
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFFFDFDFD),
                  ),
                  onPressed: onToggle,
                ),
                border: InputBorder.none),
          )),
        ]),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        alignment: Alignment.center,
        height: size.height / 13,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isLoading ? const Color(0xFF12343B) : const Color(0xFFC89666),
        ),
        child: isLoading
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
    );
  }
}
