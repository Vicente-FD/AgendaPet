/// Una fila de la comparación de planes. `free`/`pro` pueden ser:
/// 'yes' (incluido), 'no' (no incluido) o un texto (p. ej. "1", "Ilimitadas").
class PlanFeature {
  const PlanFeature({
    required this.label,
    required this.free,
    required this.pro,
  });

  final String label;
  final String free;
  final String pro;
}

abstract final class PlanMockData {
  static const String monthlyPrice = '\$3.990';
  static const String monthlyPeriod = '/mes';
  static const String annualPrice = '\$39.900';
  static const String annualPeriod = '/año';
  static const String annualEquivalent = '\$3.325/mes · 2 meses gratis';

  static const List<PlanFeature> features = [
    PlanFeature(label: 'Recordatorios ilimitados', free: 'yes', pro: 'yes'),
    PlanFeature(label: 'Agenda y calendario', free: 'yes', pro: 'yes'),
    PlanFeature(label: 'Mascotas', free: '1', pro: 'Ilimitadas'),
    PlanFeature(label: 'Fotos de crecimiento', free: '10', pro: 'Ilimitadas'),
    PlanFeature(label: 'Sin anuncios', free: 'no', pro: 'yes'),
    PlanFeature(label: 'Video resumen mensual', free: 'no', pro: 'yes'),
    PlanFeature(label: 'Familia compartida', free: '2', pro: 'Ilimitada'),
    PlanFeature(label: 'Tips premium', free: 'no', pro: 'yes'),
    PlanFeature(label: 'Soporte prioritario', free: 'no', pro: 'yes'),
  ];

  static const List<String> proBenefits = [
    'Sin anuncios en toda la app',
    'Fotos y mascotas ilimitadas',
    'Video resumen mensual automático',
    'Familia compartida sin límite',
    'Tips premium personalizados',
  ];
}
