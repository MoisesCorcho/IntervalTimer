/// Catálogo oficial de beneficios temporales desbloqueables mediante
/// anuncios bonificados (Rewarded Ads) en Interval Timer.
enum RewardedBenefit {
  /// +1 slot de rutina creada en WorkoutBuilder (F32).
  extraWorkoutSlot(Duration(hours: 24)),

  /// Catálogo Pro de clips de sonido deportivo en SoundService (F36).
  proAudioPass(Duration(hours: 12)),

  /// Paleta libre de personalización de fases de color (F06).
  phaseColorsPass(Duration(hours: 24)),

  /// Acceso a historial extendido y medidas corporales (F15).
  bodyTrackingPass(Duration(hours: 24)),

  /// Supresión de anuncios intersticiales post-entrenamiento.
  adFreePass(Duration(hours: 24));

  final Duration defaultDuration;
  const RewardedBenefit(this.defaultDuration);
}
