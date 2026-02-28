import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threadly/core/constants/constants.dart';
import 'package:threadly/features/auth/presentation/pages/providers/auth_controller.dart';
import 'package:threadly/theme/pallete.dart';

class SingInButton extends ConsumerWidget {
  const SingInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return ElevatedButton.icon(
      onPressed: authState.isLoading
          ? null
          : () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
      icon: authState.isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Image.asset(Constants.googleLogoPath, width: 35),
      label: Text(
        authState.isLoading ? 'Signing in...' : 'Sign In with Google',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.greyColor,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
