import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/auth/presentation/widgets/social_login_buttons.dart';
import 'package:agenda_pet/shared/widgets/app_logo.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    context.goDashboardActive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goOnboarding(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const Center(child: AppLogo(iconSize: 36)),
            const SizedBox(height: 28),
            Text(
              'Inicia sesión',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bienvenido de vuelta a Agenda Pet',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 28),
            LabeledTextField(
              label: 'Correo electrónico',
              controller: _emailController,
              hint: 'tucorreo@ejemplo.cl',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || !value.contains('@') ? 'Correo inválido' : null,
            ),
            const SizedBox(height: 16),
            LabeledTextField(
              label: 'Contraseña',
              controller: _passwordController,
              hint: '••••••••',
              obscureText: true,
              validator: (value) => value == null || value.length < 4
                  ? 'Mínimo 4 caracteres'
                  : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showSnack(context, 'Te enviamos un correo de recuperación'),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(label: 'Iniciar sesión', onPressed: _login),
            const SizedBox(height: 20),
            const _OrDivider(),
            const SizedBox(height: 20),
            SocialLoginButtons(onPressed: () => context.goDashboardActive()),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '¿No tienes cuenta?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                TextButton(
                  onPressed: () => context.goRegister(),
                  child: const Text('Regístrate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'o',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
