import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:interval_timer/data/models/interval_type.dart';

part 'interval.freezed.dart';

@freezed
abstract class Interval with _$Interval {
  const factory Interval({
    required String id,
    required String name,
    required int durationSeconds,
    required int colorArgb,
    @Default(IntervalType.work) IntervalType type,
    /// Optional TTS phrase (F02). Null/blank → speak [name]. Max 80 chars in UI.
    String? announceText,
    /// Ephemeral F32 workout-round metadata (1-based). Null when rounds == 1.
    int? roundIndex,
    /// Total workout rounds when [roundIndex] is set.
    int? roundCount,
  }) = _Interval;
}