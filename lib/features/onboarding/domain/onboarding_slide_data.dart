enum OnboardingSlideType {
  timer,
  audio,
  progress,
}

class OnboardingSlideData {
  const OnboardingSlideData({
    required this.type,
    required this.tag,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
  });

  final OnboardingSlideType type;
  final String tag;
  final String title;
  final String description;
  final String primaryActionLabel;

  static const List<OnboardingSlideData> defaultSlides = [
    OnboardingSlideData(
      type: OnboardingSlideType.timer,
      tag: 'PRECISIÓN & CONTROL',
      title: 'Entrená con precisión absoluta',
      description:
          'Temporizador de intervalos ergonómico y estructurado con descansos exactos para HIIT, Tabata y entrenamientos por ejercicios.',
      primaryActionLabel: 'Siguiente',
    ),
    OnboardingSlideData(
      type: OnboardingSlideType.audio,
      tag: 'INMERSIÓN & FOCO',
      title: 'Olvidate de mirar la pantalla',
      description:
          'Asistente por voz que anuncia cada fase, efectos de sonido deportivos de alta fidelidad y atenuación inteligente de tu música.',
      primaryActionLabel: 'Siguiente',
    ),
    OnboardingSlideData(
      type: OnboardingSlideType.progress,
      tag: 'HÁBITO & LOGROS',
      title: 'Constancia que se transforma en logros',
      description:
          'Calendario de consistencia, estadísticas de calorías y racha activa, registro de peso corporal y medallas para celebrar tu progreso.',
      primaryActionLabel: '¡Empezar a entrenar!',
    ),
  ];
}
