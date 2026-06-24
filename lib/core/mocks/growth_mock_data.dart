import 'dart:typed_data';

/// Una entrada del Historial de Crecimiento: foto + medidas + recuerdo.
class GrowthEntry {
  const GrowthEntry({
    required this.dateLabel,
    required this.ageLabel,
    required this.weight,
    required this.height,
    required this.note,
    this.imageBytes,
  });

  final String dateLabel;
  final String ageLabel;
  final String weight;
  final String height;
  final String note;

  /// Foto de la etapa. En los datos de ejemplo es `null` (placeholder).
  /// Cuando el usuario sube una foto real se guarda aquí.
  final Uint8List? imageBytes;
}

abstract final class GrowthMockData {
  static const String petName = 'Carolina';

  /// Resumen "Mi mascota a través del tiempo".
  static const String monthlySummary =
      'En el último año Carolina pasó de 4 kg a 12 kg. ¡Mira cómo ha crecido!';
  static const String weightStart = '4 kg';
  static const String weightCurrent = '12 kg';
  static const int photosCount = 5;
  static const int monthsTracked = 12;

  /// Serie de peso (kg) en orden cronológico, para el gráfico de evolución.
  static const List<({String label, double kg})> weightSeries = [
    (label: 'jul 24', kg: 4),
    (label: 'ene 25', kg: 9),
    (label: 'jun 25', kg: 11),
    (label: 'dic 25', kg: 11.5),
    (label: 'jun 26', kg: 12),
  ];

  /// Línea de tiempo de la más reciente a la más antigua.
  static const List<GrowthEntry> timeline = [
    GrowthEntry(
      dateLabel: '15 de junio 2026',
      ageLabel: '3 años',
      weight: '12 kg',
      height: '48 cm',
      note: 'Adulta y llena de energía. Control anual sin novedades.',
    ),
    GrowthEntry(
      dateLabel: '10 de diciembre 2025',
      ageLabel: '2 años 6 meses',
      weight: '11.5 kg',
      height: '47 cm',
      note: 'Pelaje brillante después del cambio de alimento.',
    ),
    GrowthEntry(
      dateLabel: '20 de junio 2025',
      ageLabel: '2 años',
      weight: '11 kg',
      height: '46 cm',
      note: 'Aprendió a dar la pata 🐾',
    ),
    GrowthEntry(
      dateLabel: '5 de enero 2025',
      ageLabel: '1 año 6 meses',
      weight: '9 kg',
      height: '42 cm',
      note: 'Primer paseo a la playa.',
    ),
    GrowthEntry(
      dateLabel: '12 de julio 2024',
      ageLabel: '8 meses',
      weight: '4 kg',
      height: '30 cm',
      note: 'Recién llegada a casa. ¡Una bolita de pelos!',
    ),
  ];
}
