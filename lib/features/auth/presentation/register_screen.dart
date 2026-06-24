import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/features/auth/presentation/widgets/social_login_buttons.dart';
import 'package:agenda_pet/shared/widgets/app_logo.dart';
import 'package:agenda_pet/shared/widgets/labeled_text_field.dart';
import 'package:agenda_pet/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
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
              'Crea tu cuenta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Empieza a cuidar a tus mascotas',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 28),
            LabeledTextField(
              label: 'Nombre',
              controller: _nameController,
              hint: 'Tu nombre',
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Ingresa tu nombre' : null,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            PrimaryButton(label: 'Crear cuenta', onPressed: _register),
            const SizedBox(height: 20),
            SocialLoginButtons(onPressed: () => context.goDashboardActive()),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '¿Ya tienes cuenta?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                TextButton(
                  onPressed: () => context.goLogin(),
                  child: const Text('Inicia sesión'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
