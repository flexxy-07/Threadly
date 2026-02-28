import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:threadly/core/common/sing_in_button.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/theme/pallete.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show a SnackBar whenever sign-in fails
    ref.listen<AsyncValue>(authControllerProvider, (_, next) {
      next.whenOrNull(
        error: (err, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: Colors.red,
          ),
        ),
      );
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.blackColor,
        centerTitle: true,
        leadingWidth: 120,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Align(alignment: Alignment.centerLeft, child: null),
        ),
        title: Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(color: Colors.transparent),
          child: null,
        ),
        actions: [
          Row(
            children: [
              TextButton(
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              'Dive into Anything',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 100),
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  Constants.logoPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey,
                      child: const Center(child: Text('Logo')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const SingInButton(),
            ),
          ],
        ),
      ), 
    );
  }
}
