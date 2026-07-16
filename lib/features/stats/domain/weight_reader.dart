import 'package:interval_timer/features/stats/domain/stats_models.dart';

/// Result of resolving user body weight for kcal estimates (F12 / F15).
class WeightReading {
  const WeightReading({
    required this.weightKg,
    required this.isEstimated,
  });

  final double weightKg;
  final bool isEstimated;
}

/// Thin reader so F12 does not own weight CRUD (F15).
abstract class WeightReader {
  WeightReading read();
}

/// Always returns the F12 default (70 kg, estimated). F15 can override via provider.
class DefaultWeightReader implements WeightReader {
  const DefaultWeightReader();

  @override
  WeightReading read() {
    return const WeightReading(
      weightKg: kDefaultWeightKg,
      isEstimated: true,
    );
  }
}
