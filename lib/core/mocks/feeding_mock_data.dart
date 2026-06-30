import 'dart:math' as math;

/// Nivel de actividad de la mascota. Ajusta la ración diaria recomendada.
enum ActivityLevel {
  low('Baja', 0.85),
  normal('Normal', 1.0),
  high('Alta', 1.2);

  const ActivityLevel(this.label, this.factor);

  final String label;

  /// Multiplicador sobre la ración base.
  final double factor;
}

/// Alimento actual registrado para la mascota (datos mock).
class FeedingPlan {
  const FeedingPlan({
    required this.petName,
    required this.weightKg,
    required this.species,
    required this.breed,
    required this.foodName,
    required this.brand,
    required this.kind,
    required this.bagSizeKg,
    required this.remainingFraction,
    required this.daysRemaining,
    required this.nextPurchaseLabel,
    required this.lastPurchaseLabel,
    required this.activity,
  });

  final String petName;
  final double weightKg;
  final String species;
  final String breed;

  final String foodName;
  final String brand;

  /// "Seco", "Húmedo", "Mixto".
  final String kind;

  /// Tamaño del saco/bolsa comprado, en kg.
  final double bagSizeKg;

  /// Fracción de saco que queda (0..1), para la barra de progreso.
  final double remainingFraction;

  /// Días estimados antes de que se acabe el alimento.
  final int daysRemaining;

  /// Fecha estimada de la próxima compra.
  final String nextPurchaseLabel;

  /// Última vez que se compró.
  final String lastPurchaseLabel;

  final ActivityLevel activity;
}

abstract final class FeedingMockData {
  /// Plan de ejemplo (mascota seleccionada por defecto en el Home).
  static const FeedingPlan currentPlan = FeedingPlan(
    petName: 'Carolina',
    weightKg: 12,
    species: 'Perro',
    breed: 'Mestiza',
    foodName: 'Adulto Razas Medianas',
    brand: 'ProPlan',
    kind: 'Seco',
    bagSizeKg: 7.5,
    remainingFraction: 0.35,
    daysRemaining: 9,
    nextPurchaseLabel: '7 de julio 2026',
    lastPurchaseLabel: '8 de junio 2026',
    activity: ActivityLevel.normal,
  );

  /// Tabla guía de referencia: rango de peso → ración aproximada.
  static const List<({String weightRange, String dailyAmount, String meals})>
      guideline = [
    (weightRange: '1 – 5 kg', dailyAmount: '40 – 110 g', meals: '2 tomas'),
    (weightRange: '5 – 10 kg', dailyAmount: '110 – 180 g', meals: '2 tomas'),
    (weightRange: '10 – 20 kg', dailyAmount: '180 – 300 g', meals: '2 tomas'),
    (weightRange: '20 – 35 kg', dailyAmount: '300 – 440 g', meals: '2 tomas'),
    (weightRange: '+35 kg', dailyAmount: '440 – 600 g', meals: '2 – 3 tomas'),
  ];

  /// Ración diaria recomendada (g) para alimento seco, estimada a partir del
  /// gasto energético en reposo (RER ≈ 70 · peso^0.75 kcal) y un pienso de
  /// ~3,5 kcal/g, ajustada por el nivel de actividad. Es solo referencial.
  static int recommendedDailyGrams(double weightKg, ActivityLevel activity) {
    final rerKcal = 70 * math.pow(weightKg.clamp(0.5, 80), 0.75);
    final maintenanceKcal = rerKcal * 1.6 * activity.factor;
    final grams = maintenanceKcal / 3.5;
    // Redondea a la decena más cercana para una cifra "limpia".
    return (grams / 10).round() * 10;
  }
}
