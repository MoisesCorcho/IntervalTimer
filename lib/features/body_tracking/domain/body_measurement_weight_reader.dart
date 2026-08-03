import 'package:interval_timer/features/stats/domain/stats_models.dart';
import 'package:interval_timer/features/stats/domain/weight_reader.dart';

/// F15 adapter for F12 [WeightReader].
///
/// When [latestWeightKg] is null (no rows), delegates to [DefaultWeightReader]
/// (70 kg estimated). Otherwise returns the latest registered weight.
class BodyMeasurementWeightReader implements WeightReader {
  const BodyMeasurementWeightReader({this.latestWeightKg});

  /// Latest body weight in kg by `localDate` desc, or null if none.
  final double? latestWeightKg;

  @override
  WeightReading read() {
    final kg = latestWeightKg;
    if (kg == null) {
      return const DefaultWeightReader().read();
    }
    return WeightReading(weightKg: kg, isEstimated: false);
  }
}
