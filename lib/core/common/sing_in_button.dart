import 'package:flutter/material.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/theme/pallete.dart';

class SingInButton extends StatelessWidget {
  const SingInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Image.asset(Constants.googleLogoPath, width: 35,),
      label: const Text(
        'Sign In with Google',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.greyColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        )
      ),
    );
  }
}
