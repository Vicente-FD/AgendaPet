import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Botones de acceso social (simulados). Llaman a [onPressed] al tocar.
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          label: 'Continuar con Google',
          onPressed: onPressed,
        ),
        const SizedBox(height: 12),
        _SocialButton(
          icon: Icons.apple,
          label: 'Continuar con Apple',
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
