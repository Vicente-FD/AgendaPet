import 'package:agenda_pet/core/config/app_config.dart';
import 'package:agenda_pet/core/data/repositories.dart';
import 'package:agenda_pet/features/auth/data/social_auth.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/auth/data/auth_models.dart';
import 'package:agenda_pet/features/auth/data/auth_repository.dart';
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
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Ejecuta una acción de auth con estado de carga y manejo de error.
  Future<void> _run(Future<AuthUser> Function() action) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) context.goDashboardActive();
    } catch (e) {
      if (mounted) {
        _showSnack(
          context,
          e is AuthException ? e.message : 'No se pudo iniciar sesión',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    _run(
      () => Repositories.auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  Future<void> _conGoogle() async {
    if (!AppConfig.useBackend) {
      _run(() => Repositories.auth.loginWithGoogle('mock-id-token'));
      return;
    }
    try {
      final idToken = await SocialAuth.googleIdToken();
      _run(() => Repositories.auth.loginWithGoogle(idToken));
    } on SocialAuthException catch (e) {
      if (mounted) _showSnack(context, e.message);
    }
  }

  Future<void> _conApple() async {
    if (!AppConfig.useBackend) {
      _run(() => Repositories.auth.loginWithApple('mock-identity-token'));
      return;
    }
    try {
      final credencial = await SocialAuth.appleCredentials();
      _run(
        () => Repositories.auth.loginWithApple(
          credencial.identityToken,
          name: credencial.name,
        ),
      );
    } on SocialAuthException catch (e) {
      if (mounted) _showSnack(context, e.message);
    }
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Bienvenido de vuelta a Agenda Pet',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            LabeledTextField(
              label: 'Correo electrónico',
              controller: _emailController,
              hint: 'tucorreo@ejemplo.cl',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) => value == null || !value.contains('@')
                  ? 'Correo inválido'
                  : null,
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
                onPressed: () => _showSnack(
                  context,
                  'Te enviamos un correo de recuperación',
                ),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: _loading ? 'Ingresando…' : 'Iniciar sesión',
              onPressed: _loading ? null : _login,
            ),
            const SizedBox(height: 20),
            const _OrDivider(),
            const SizedBox(height: 20),
            SocialLoginButtons(
              onGoogle: _loading ? () {} : _conGoogle,
              onApple: _loading ? () {} : _conApple,
              mostrarApple: !AppConfig.useBackend || SocialAuth.appleDisponible,
            ),
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
