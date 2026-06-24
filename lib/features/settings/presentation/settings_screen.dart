import 'package:agenda_pet/core/mocks/user_mock_data.dart';
import 'package:agenda_pet/core/routing/app_navigation.dart';
import 'package:agenda_pet/core/state/app_settings.dart';
import 'package:agenda_pet/core/theme/app_colors.dart';
import 'package:agenda_pet/core/theme/app_surfaces.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ajustes'),
      ),
      body: ListenableBuilder(
        listenable: AppSettings.instance,
        builder: (context, _) {
          final settings = AppSettings.instance;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _AccountTile(onTap: () => context.goUserProfile()),
              const SizedBox(height: 16),
              _PlanCard(isPro: settings.isPro, onTap: () => context.goSubscription()),
              const SizedBox(height: 24),
              const _SectionLabel('Preferencias'),
              _SettingsGroup(
                children: [
                  SwitchListTile(
                    value: settings.isDark,
                    onChanged: settings.setDarkMode,
                    activeThumbColor: AppColors.primary,
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Modo oscuro'),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    value: _notificationsOn,
                    onChanged: (v) => setState(() => _notificationsOn = v),
                    activeThumbColor: AppColors.primary,
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Notificaciones'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: const Text('Idioma'),
                    trailing: const Text(
                      'Español',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    onTap: () => _snack(context, 'Próximamente: más idiomas'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Cuenta'),
              _SettingsGroup(
                children: [
                  ListTile(
                    leading: const Icon(Icons.diversity_3_outlined),
                    title: const Text('Familia compartida'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.goFamily(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Historial de notificaciones'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.goNotifications(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Demo'),
              _SettingsGroup(
                children: [
                  SwitchListTile(
                    value: settings.isPro,
                    onChanged: settings.setPro,
                    activeThumbColor: AppColors.tips,
                    secondary: const Icon(Icons.workspace_premium_outlined),
                    title: const Text('Simular plan PRO'),
                    subtitle: const Text('Activa/desactiva las funciones PRO'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.goLogin(),
                  icon: const Icon(Icons.logout, color: AppColors.actionServices),
                  label: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: AppColors.actionServices),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                        color: AppColors.actionServices.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Agenda Pet · v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _snack(BuildContext context, String message) {
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

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UserMockData.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      UserMockData.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.isPro, required this.onTap});

  final bool isPro;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isPro
                  ? const [Color(0xFFFFB300), Color(0xFFF57F17)]
                  : const [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(
                  isPro ? Icons.workspace_premium : Icons.star_outline,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPro ? 'Plan PRO activo' : 'Plan Free',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPro
                            ? 'Gestiona tu suscripción'
                            : 'Hazte PRO y quita los anuncios',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.surface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
