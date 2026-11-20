import 'package:agenda_pet/core/mocks/feeding_mock_data.dart';
import 'package:agenda_pet/core/utils/date_format.dart';
import 'package:agenda_pet/features/pets/data/pet_dto.dart';

/// Plan de alimentación tal como lo guarda la API.
class FeedingDto {
  const FeedingDto({
    required this.id,
    required this.foodName,
    this.brand,
    this.kind = 'DRY',
    this.bagSizeKg,
    this.dailyGrams,
    this.activity = 'NORMAL',
    this.openedAt,
  });

  final String id;
  final String foodName;
  final String? brand;

  /// DRY | WET | MIXED
  final String kind;
  final double? bagSizeKg;
  final int? dailyGrams;

  /// LOW | NORMAL | HIGH
  final String activity;
  final DateTime? openedAt;

  factory FeedingDto.fromJson(Map<String, dynamic> json) => FeedingDto(
    id: json['id'] as String,
    foodName: json['foodName'] as String,
    brand: json['brand'] as String?,
    kind: (json['kind'] as String?) ?? 'DRY',
    bagSizeKg: (json['bagSizeKg'] as num?)?.toDouble(),
    dailyGrams: (json['dailyGrams'] as num?)?.toInt(),
    activity: (json['activity'] as String?) ?? 'NORMAL',
    openedAt: json['openedAt'] == null
        ? null
        : DateTime.parse(json['openedAt'] as String).toLocal(),
  );

  Map<String, dynamic> toJson() => {
    'foodName': foodName,
    if (brand != null && brand!.isNotEmpty) 'brand': brand,
    'kind': kind,
    if (bagSizeKg != null) 'bagSizeKg': bagSizeKg,
    if (dailyGrams != null) 'dailyGrams': dailyGrams,
    'activity': activity,
    if (openedAt != null) 'openedAt': openedAt!.toUtc().toIso8601String(),
  };

  static const _tipos = {'DRY': 'Seco', 'WET': 'Húmedo', 'MIXED': 'Mixto'};
  static const _actividades = {
    'LOW': ActivityLevel.low,
    'NORMAL': ActivityLevel.normal,
    'HIGH': ActivityLevel.high,
  };

  static String tipoApi(String etiqueta) => _tipos.entries
      .firstWhere(
        (e) => e.value == etiqueta,
        orElse: () => const MapEntry('DRY', 'Seco'),
      )
      .key;

  /// Días que dura el saco completo según la ración diaria.
  double? get _diasPorSaco {
    final saco = bagSizeKg;
    final racion = dailyGrams;
    if (saco == null || racion == null || racion <= 0) return null;
    return (saco * 1000) / racion;
  }

  /// Adapta el plan al modelo que ya consumen las tarjetas de la pantalla,
  /// calculando lo que queda de saco a partir de la fecha de apertura.
  FeedingPlan toPlan(PetDto mascota) {
    final total = _diasPorSaco;
    final abierto = openedAt;
    final transcurridos = abierto == null
        ? 0
        : DateTime.now().difference(abierto).inDays;
    final restantes = total == null
        ? 0
        : (total - transcurridos).clamp(0, total).round();
    final fraccion = total == null || total == 0
        ? 1.0
        : ((total - transcurridos) / total).clamp(0.0, 1.0).toDouble();

    return FeedingPlan(
      petName: mascota.name,
      weightKg: mascota.weightKg ?? 10,
      species: mascota.species,
      breed: mascota.breed ?? 'Sin raza registrada',
      foodName: foodName,
      brand: brand ?? 'Sin marca',
      kind: _tipos[kind] ?? 'Seco',
      bagSizeKg: bagSizeKg ?? 0,
      remainingFraction: fraccion,
      daysRemaining: restantes,
      nextPurchaseLabel: abierto == null || total == null
          ? 'Sin fecha estimada'
          : formatShortDate(abierto.add(Duration(days: total.round()))),
      lastPurchaseLabel: abierto == null
          ? 'Sin registro'
          : formatShortDate(abierto),
      activity: _actividades[activity] ?? ActivityLevel.normal,
    );
  }
}
