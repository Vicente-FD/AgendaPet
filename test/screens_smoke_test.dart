// Smoke test: cada pantalla debe construirse sin desbordes ni excepciones.
// Forzamos ancho de móvil (iPhone 12 Pro) porque un overflow horizontal deja
// la pantalla en blanco en Flutter web. También probamos modo oscuro y PRO.
import 'package:agenda_pet/core/state/app_settings.dart';
import 'package:agenda_pet/core/theme/app_theme.dart';
import 'package:agenda_pet/features/account/presentation/user_profile_screen.dart';
import 'package:agenda_pet/features/auth/presentation/login_screen.dart';
import 'package:agenda_pet/features/auth/presentation/register_screen.dart';
import 'package:agenda_pet/features/dashboard_active/presentation/dashboard_active_screen.dart';
import 'package:agenda_pet/features/dashboard_empty/presentation/dashboard_empty_screen.dart';
import 'package:agenda_pet/features/events/presentation/events_screen.dart';
import 'package:agenda_pet/features/family/presentation/family_screen.dart';
import 'package:agenda_pet/features/growth/presentation/growth_history_screen.dart';
import 'package:agenda_pet/features/notifications/presentation/notifications_screen.dart';
import 'package:agenda_pet/features/onboarding/presentation/onboarding_screen.dart';
import 'package:agenda_pet/features/pet_profile/presentation/pet_profile_screen.dart';
import 'package:agenda_pet/features/pets/presentation/pets_list_screen.dart';
import 'package:agenda_pet/features/settings/presentation/settings_screen.dart';
import 'package:agenda_pet/features/subscription/presentation/checkout_screen.dart';
import 'package:agenda_pet/features/subscription/presentation/subscription_screen.dart';
import 'package:agenda_pet/features/subscription/presentation/subscription_success_screen.dart';
import 'package:agenda_pet/features/tips/presentation/tips_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final Map<String, Widget Function()> _screens = {
  'Onboarding': () => const OnboardingScreen(),
  'Dashboard activo': () => const DashboardActiveScreen(),
  'Dashboard vacío': () => const DashboardEmptyScreen(),
  'Pet profile': () => const PetProfileScreen(),
  'Growth history': () => const GrowthHistoryScreen(),
  'Events': () => const EventsScreen(),
  'Tips': () => const TipsScreen(),
  'Family': () => const FamilyScreen(),
  'Notifications': () => const NotificationsScreen(),
  'Login': () => const LoginScreen(),
  'Register': () => const RegisterScreen(),
  'Settings': () => const SettingsScreen(),
  'User profile': () => const UserProfileScreen(),
  'Subscription': () => const SubscriptionScreen(),
  'Checkout': () => const CheckoutScreen(),
  'Subscription success': () => const SubscriptionSuccessScreen(),
  'Pets list': () => const PetsListScreen(),
};

Widget _wrap(Widget child, {ThemeMode mode = ThemeMode.light}) => MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: child,
    );

Future<void> _useMobileSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  // Cada pantalla en modo claro a ancho de móvil.
  for (final entry in _screens.entries) {
    testWidgets('${entry.key} se construye (móvil, claro)', (tester) async {
      await _useMobileSurface(tester);
      await tester.pumpWidget(_wrap(entry.value()));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });
  }

  // Pantallas densas en modo oscuro: no deben lanzar ni desbordar.
  final darkScreens = ['Dashboard activo', 'Growth history', 'Settings', 'Subscription'];
  for (final name in darkScreens) {
    testWidgets('$name se construye (móvil, oscuro)', (tester) async {
      await _useMobileSurface(tester);
      await tester.pumpWidget(_wrap(_screens[name]!(), mode: ThemeMode.dark));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });
  }

  testWidgets('Suscripción en estado PRO se construye', (tester) async {
    await _useMobileSurface(tester);
    AppSettings.instance.setPro(true);
    addTearDown(() => AppSettings.instance.setPro(false));
    await tester.pumpWidget(_wrap(const SubscriptionScreen()));
    await tester.pump();
    expect(find.text('¡Eres PRO!'), findsOneWidget);
  });

  testWidgets('Onboarding muestra encabezado y botón', (tester) async {
    await _useMobileSurface(tester);
    await tester.pumpWidget(_wrap(const OnboardingScreen()));
    await tester.pump();
    expect(find.text('¡Bienvenido a Agenda Pet!'), findsOneWidget);
    expect(find.text('¡Comenzar!'), findsOneWidget);
  });
}
