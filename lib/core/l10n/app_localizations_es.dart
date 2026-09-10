// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Interval Timer';

  @override
  String get appTagline => 'Tu asistente de entrenamiento';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageHint =>
      'Selecciona el idioma de la interfaz y la voz del temporizador.';

  @override
  String get languageAuto => 'Automático (Sistema)';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'English';

  @override
  String get timerPhasePreparation => 'Preparación';

  @override
  String get timerPhaseWork => 'Trabajo';

  @override
  String get timerPhaseRest => 'Descanso';

  @override
  String get timerPhaseCompleted => 'Sesión completada';

  @override
  String get routineTitle => 'Mi rutina';

  @override
  String get addInterval => 'Agregar intervalo';

  @override
  String get editInterval => 'Editar intervalo';

  @override
  String get intervalName => 'Nombre del intervalo';

  @override
  String get duration => 'Duración';

  @override
  String get minutesLabel => 'MINUTOS';

  @override
  String get secondsLabel => 'SEGUNDOS';

  @override
  String get totalLabel => 'total';

  @override
  String get increaseMinutes => 'Aumentar minutos';

  @override
  String get decreaseMinutes => 'Disminuir minutos';

  @override
  String get increaseSeconds => 'Aumentar segundos';

  @override
  String get decreaseSeconds => 'Disminuir segundos';

  @override
  String get color => 'Color';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get startSession => 'Iniciar';

  @override
  String get emptyRoutineMessage =>
      'Agrega al menos un intervalo para comenzar';

  @override
  String get emptyRoutineHint => 'No hay intervalos en la rutina';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get nameTooLong => 'El nombre no puede superar 50 caracteres';

  @override
  String get durationInvalid =>
      'Duración inválida. Debe estar entre 00:01 y 99:59';

  @override
  String get emptyRoutineStart =>
      'Se requiere al menos un intervalo para iniciar';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Reanudar';

  @override
  String get skip => 'Saltar';

  @override
  String get previous => 'Anterior';

  @override
  String get cancelSession => 'Cancelar sesión';

  @override
  String get exitSession => 'Salir';

  @override
  String get nextInterval => 'Siguiente';

  @override
  String get lastInterval => 'Último intervalo';

  @override
  String intervalProgress(int current, int total) {
    return 'Intervalo $current de $total';
  }

  @override
  String get remainingLabel => 'RESTANTE';

  @override
  String get preparation => 'PREPARACIÓN';

  @override
  String get exitConfirmTitle => '¿Salir del entrenamiento?';

  @override
  String get exitConfirmMessage => 'Se perderá el progreso de esta sesión.';

  @override
  String get exitConfirmContinue => 'Continuar';

  @override
  String get exitConfirmLeave => 'Salir';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get prepSecondsLabel => 'Segundos de preparación';

  @override
  String get prepSecondsHint =>
      'Cuenta regresiva antes del primer intervalo (0 = desactivada).';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Seguir sistema';

  @override
  String get voiceSectionTitle => 'Voz';

  @override
  String get voiceEnabledLabel => 'Voz activada';

  @override
  String get voiceEnabledHint =>
      'Anuncios y cuenta regresiva hablada. No detiene el temporizador.';

  @override
  String get countdownSecondsLabel => 'Segundos de cuenta regresiva';

  @override
  String get countdownSecondsHint =>
      'Habla los últimos N segundos de cada intervalo (0 = solo anuncio de inicio).';

  @override
  String get announceIntervalNameLabel => 'Anunciar nombre del intervalo';

  @override
  String get announceIntervalNameHint =>
      'Dice el nombre (o texto de anuncio) al empezar cada intervalo.';

  @override
  String get announceTextLabel => 'Texto de anuncio (opcional)';

  @override
  String get announceTextHint =>
      'Si está vacío se usa el nombre del intervalo.';

  @override
  String get announceTextTooLong =>
      'El texto de anuncio no puede superar 80 caracteres';

  @override
  String get musicDuckingLabel => 'Atenuar música de fondo';

  @override
  String get musicDuckingHint =>
      'Baja el volumen de la música externa durante las locuciones de voz.';

  @override
  String get vibrationSectionTitle => 'Vibración';

  @override
  String get vibrationEnabledLabel => 'Vibración activada';

  @override
  String get vibrationEnabledHint =>
      'Feedback táctil al cambiar de intervalo y en la cuenta regresiva. Independiente de la voz.';

  @override
  String get vibrationOnIntervalStartLabel => 'Al cambiar de intervalo';

  @override
  String get vibrationOnIntervalStartHint => 'Pulso al iniciar cada intervalo.';

  @override
  String get vibrationOnCountdownLabel => 'En cuenta regresiva';

  @override
  String get vibrationOnCountdownHint =>
      'Pulsos en los últimos segundos de cada intervalo.';

  @override
  String get vibrationCountdownSecondsLabel =>
      'Segundos de cuenta regresiva (vibración)';

  @override
  String get vibrationCountdownSecondsHint =>
      'Vibra en los últimos N segundos (0 = solo al cambiar de intervalo).';

  @override
  String get soundSectionTitle => 'Efectos de sonido';

  @override
  String get soundEnabledLabel => 'Efectos de sonido activados';

  @override
  String get soundEnabledHint =>
      'Beeps y chimes del temporizador. Independiente de la voz y la vibración.';

  @override
  String get soundOnWorkStartLabel => 'Inicio de trabajo';

  @override
  String get soundOnWorkStartHint =>
      'Sonido al empezar un intervalo de trabajo (u otro no-descanso).';

  @override
  String get soundOnRestStartLabel => 'Inicio de descanso';

  @override
  String get soundOnRestStartHint =>
      'Sonido al empezar un intervalo de descanso.';

  @override
  String get soundOnSessionCompleteLabel => 'Fin de sesión';

  @override
  String get soundOnSessionCompleteHint =>
      'Sonido al completar el entrenamiento.';

  @override
  String get soundOnPrepTickLabel => 'Ticks de preparación';

  @override
  String get soundOnPrepTickHint =>
      'Un tick por cada segundo de la cuenta de preparación.';

  @override
  String get soundOnPhaseWarningLabel => 'Cuenta regresiva final';

  @override
  String get soundOnPhaseWarningHint =>
      'Ticks en los últimos N segundos de cada intervalo.';

  @override
  String get soundCountdownSecondsLabel =>
      'Segundos de cuenta regresiva (sonido)';

  @override
  String get soundCountdownSecondsHint =>
      'Reproduce el aviso en los últimos N segundos (0 = desactivado).';

  @override
  String get soundClipLabel => 'Sonido';

  @override
  String get soundChangeClip => 'Cambiar';

  @override
  String get soundPreviewClip => 'Probar';

  @override
  String get soundPickClipTitle => 'Elegir sonido';

  @override
  String get soundSlotWorkStart => 'Inicio de trabajo';

  @override
  String get soundSlotRestStart => 'Inicio de descanso';

  @override
  String get soundSlotSessionComplete => 'Fin de sesión';

  @override
  String get soundSlotPrepTick => 'Tick de preparación';

  @override
  String get soundSlotPhaseWarning => 'Aviso de cuenta regresiva';

  @override
  String get keepScreenOnSectionTitle => 'Pantalla';

  @override
  String get keepScreenOnEnabledLabel => 'Pantalla siempre encendida';

  @override
  String get keepScreenOnEnabledHint =>
      'Evita que la pantalla se apague durante el entrenamiento. Puede consumir más batería.';

  @override
  String get sessionLockScreenSectionTitle => 'Controles de sesión';

  @override
  String get sessionLockScreenEnabledLabel =>
      'Notificación de sesión / pantalla de bloqueo';

  @override
  String get sessionLockScreenEnabledHint =>
      'Muestra el intervalo y el tiempo restante con controles de pausa y salto mientras entrenás.';

  @override
  String get sessionLockScreenPermissionDenied =>
      'Se necesita permiso de notificaciones para mostrar la sesión en segundo plano. El temporizador sigue funcionando en la app.';

  @override
  String get sessionLockScreenRetryPermission => 'Reintentar permiso';

  @override
  String get sessionLockScreenOpenSystemSettings => 'Abrir ajustes del sistema';

  @override
  String get sessionSurfaceFallbackTitle => 'Intervalo';

  @override
  String get sessionSurfaceStatusRunning => 'En curso';

  @override
  String get sessionSurfaceStatusPaused => 'Pausado';

  @override
  String get sessionCompleted => '¡Sesión completada!';

  @override
  String get sessionCompletedMessage =>
      'Has terminado todos los intervalos de la rutina.';

  @override
  String get backToRoutine => 'Volver';

  @override
  String get sessionSummaryGreatJob => '¡Gran trabajo!';

  @override
  String get sessionSummaryTraining => 'Entrenamiento';

  @override
  String get sessionSummaryRest => 'Descanso total';

  @override
  String get sessionSummarySharePrompt =>
      '¡Comparte tus resultados con estilo!';

  @override
  String get sessionSummarySharePromptDetail =>
      'Elegí plantilla, sumá una foto y compartí o guardá en la galería.';

  @override
  String get sessionSummaryShare => 'Compartir';

  @override
  String get sessionSummarySharing => 'Compartiendo…';

  @override
  String get sessionSummaryShareFailed =>
      'No se pudo generar o compartir la imagen. Intenta de nuevo.';

  @override
  String get sessionSummaryNotePrompt => '¿Cómo fue tu entrenamiento?';

  @override
  String get sessionSummaryNoteUnavailable =>
      'La nota estará disponible en un momento. Podés añadirla también en Historial.';

  @override
  String get sessionSummaryNoteSaveFailed =>
      'No se pudo guardar la nota. Reintentá o salí sin guardar.';

  @override
  String get sessionSummaryDoneAnyway => 'Salir sin nota';

  @override
  String get sessionSummaryDone => 'Listo';

  @override
  String get sessionSummaryFallbackName => 'Entrenamiento';

  @override
  String get sessionSummaryShareDuration => 'Duración';

  @override
  String get sessionSummaryShareKcal => 'kcal (est.)';

  @override
  String get sessionSummaryShareStreak => 'Racha (días)';

  @override
  String get sessionSummaryShareTitle => 'Compartir';

  @override
  String get sessionSummaryShareAddPhoto => 'Añadir foto';

  @override
  String get sessionSummaryShareTakePhoto => 'Hacer foto';

  @override
  String get sessionSummarySharePickGallery => 'Seleccionar imagen';

  @override
  String get sessionSummarySharePhotoFailed =>
      'No se pudo obtener la foto. Revisá los permisos e intentá de nuevo.';

  @override
  String get sessionSummaryShareSaveGallery => 'Guardar en la galería';

  @override
  String get sessionSummaryShareSavedGallery => 'Imagen guardada en la galería';

  @override
  String get sessionSummaryShareSaveGalleryFailed =>
      'No se pudo guardar en la galería. Revisá los permisos.';

  @override
  String get sessionSummaryShareOfflineHint =>
      'Plantillas y foto funcionan sin conexión';

  @override
  String get sessionSummaryShareWorkoutBadge => 'Entrenamiento';

  @override
  String get sessionSummaryShareSets => 'Sets';

  @override
  String get sessionSummaryShareWork => 'Trabajo';

  @override
  String get sessionSummaryShareRest => 'Descanso';

  @override
  String get sessionSummarySheetHint =>
      'Deslizá hacia arriba para ver más detalle';

  @override
  String get sessionSummaryNewAchievementsOne => '¡1 logro nuevo!';

  @override
  String sessionSummaryNewAchievementsMany(int count) {
    return '¡$count logros nuevos!';
  }

  @override
  String get sessionSummaryViewAchievements => 'Ver logros';

  @override
  String get achievementsTitle => 'Logros';

  @override
  String get achievementsEntryTitle => 'Logros';

  @override
  String get achievementsEntrySubtitle => 'Ver desbloqueados y progreso';

  @override
  String get achievementsUnlockedBadge => 'Desbloqueado';

  @override
  String get achievementsLockedBadge => 'Pendiente';

  @override
  String get achievementsError => 'No se pudieron cargar los logros';

  @override
  String get achievementsEmptyHint =>
      'Completa sesiones para desbloquear logros';

  @override
  String get achievementsSheetTitle => '¡Logros desbloqueados!';

  @override
  String get achievementsSheetClose => 'Genial';

  @override
  String achievementsUnlockedOn(String date) {
    return 'Desbloqueado el $date';
  }

  @override
  String achievementsProgressSessions(int current, int target) {
    return '$current/$target sesiones';
  }

  @override
  String achievementsProgressDays(int current, int target) {
    return '$current/$target días';
  }

  @override
  String achievementsProgressMinutes(int current, int target) {
    return '$current/$target min';
  }

  @override
  String get achievementFirstSessionTitle => 'Primera sesión';

  @override
  String get achievementFirstSessionDesc =>
      'Completá tu primera sesión de entrenamiento.';

  @override
  String get achievementSessions10Title => '10 sesiones';

  @override
  String get achievementSessions10Desc => 'Completá 10 sesiones en total.';

  @override
  String get achievementSessions25Title => '25 sesiones';

  @override
  String get achievementSessions25Desc => 'Completá 25 sesiones en total.';

  @override
  String get achievementSessions50Title => '50 sesiones';

  @override
  String get achievementSessions50Desc => 'Completá 50 sesiones en total.';

  @override
  String get achievementSessions100Title => '100 sesiones';

  @override
  String get achievementSessions100Desc => 'Completá 100 sesiones en total.';

  @override
  String get achievementStreak3Title => 'Racha de 3 días';

  @override
  String get achievementStreak3Desc =>
      'Entrená al menos un día durante 3 días seguidos.';

  @override
  String get achievementStreak7Title => 'Racha de 7 días';

  @override
  String get achievementStreak7Desc =>
      'Entrená al menos un día durante 7 días seguidos.';

  @override
  String get achievementStreak14Title => 'Racha de 14 días';

  @override
  String get achievementStreak14Desc =>
      'Entrená al menos un día durante 14 días seguidos.';

  @override
  String get achievementStreak30Title => 'Racha de 30 días';

  @override
  String get achievementStreak30Desc =>
      'Entrená al menos un día durante 30 días seguidos.';

  @override
  String get achievementMinutes60Title => '60 minutos';

  @override
  String get achievementMinutes60Desc =>
      'Acumulá 60 minutos de sesiones completadas.';

  @override
  String get achievementMinutes300Title => '300 minutos';

  @override
  String get achievementMinutes300Desc =>
      'Acumulá 300 minutos de sesiones completadas.';

  @override
  String get achievementMinutes1000Title => '1000 minutos';

  @override
  String get achievementMinutes1000Desc =>
      'Acumulá 1000 minutos de sesiones completadas.';

  @override
  String get persistenceError => 'No se pudo guardar. Intenta de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get workoutsTitle => 'Mis entrenamientos';

  @override
  String get navRoutine => 'Rutina';

  @override
  String get navWorkouts => 'Entrenamientos';

  @override
  String get navHistory => 'Historial';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyWorkoutsSection => 'Entrenamientos';

  @override
  String get historyEmptyDay => 'No hay entrenamientos este día';

  @override
  String get historyAddNote => 'Añadir una nota...';

  @override
  String get historyEditNoteTitle => 'Nota del entrenamiento';

  @override
  String get historyNoteTooLong => 'La nota no puede superar 500 caracteres';

  @override
  String get historyStart => 'Empezar';

  @override
  String get historyDelete => 'Eliminar del historial';

  @override
  String get historyDeleteTitle => '¿Eliminar del historial?';

  @override
  String get historyDeleteMessage =>
      'Esta acción no se puede deshacer. Se borrará el registro de esta sesión.';

  @override
  String get historySourceMissing =>
      'No se encontró la rutina o entrenamiento original.';

  @override
  String get historyGoToToday => 'Ir al día de hoy';

  @override
  String get historySelectMonth => 'Seleccionar mes';

  @override
  String historyExerciseCount(int count) {
    return 'Ejercicios: $count';
  }

  @override
  String historyFallbackTitle(String time) {
    return 'Entrenamiento a las $time';
  }

  @override
  String get progressSectionTitle => 'Tu progreso';

  @override
  String get progressStreakLabel => 'Racha';

  @override
  String get progressWeekMinutesLabel => 'Minutos esta semana';

  @override
  String get progressMonthSessionsLabel => 'Sesiones este mes';

  @override
  String get progressKcalLabel => 'Calorías estimadas';

  @override
  String get progressChartWeek => 'Semana';

  @override
  String get progressChartMonth => 'Mes';

  @override
  String get progressChartCaption => 'Minutos por día';

  @override
  String get progressStatsError => 'No se pudieron cargar las estadísticas';

  @override
  String progressWeightEstimated(String kg) {
    return 'Peso estimado $kg kg';
  }

  @override
  String progressWeightRegistered(String kg) {
    return 'Peso $kg kg';
  }

  @override
  String progressKcalMethodCaption(String met) {
    return 'kcal estimadas: MET $met × peso × duración de sesión. No es un gasto medido.';
  }

  @override
  String get progressKcalInfoTooltip => 'Cómo se estiman las calorías';

  @override
  String get progressKcalInfoTitle => 'Calorías estimadas';

  @override
  String progressKcalInfoBody(String met) {
    return 'Estimamos la energía con la fórmula estándar MET × peso (kg) × horas de sesión (definición práctica del Compendium of Physical Activities).\n\nUsamos MET $met como referencia de actividad vigorosa de intervalos. Es un valor poblacional genérico, no una medición de tu metabolismo ni de un sensor.\n\nSirve como referencia y para ver tendencias, no como dato clínico ni nutricional exacto.';
  }

  @override
  String get progressKcalInfoClose => 'Entendido';

  @override
  String progressTotalLine(String totals, int sessions) {
    return 'Total: $totals · $sessions sesiones';
  }

  @override
  String get progressDaysSuffix => 'días';

  @override
  String get bodyWeightSectionTitle => 'Tu peso';

  @override
  String get bodyWeightRegisterCta => 'Registrar';

  @override
  String get bodyWeightUpdateCta => 'Actualizar';

  @override
  String get bodyWeightRegisterButton => 'Registrar peso';

  @override
  String get bodyWeightEmptyMessage => 'Registra tu peso para ver la evolución';

  @override
  String bodyWeightCaptionEstimated(String value, String unit) {
    return 'Peso estimado $value $unit · Registrar';
  }

  @override
  String bodyWeightCaptionRegistered(String value, String valueUnit) {
    return '$value $valueUnit · Actualizar';
  }

  @override
  String get bodyWeightFormTitle => 'Registrar peso';

  @override
  String get bodyWeightFormEditTitle => 'Editar peso';

  @override
  String get bodyWeightFieldLabel => 'Peso';

  @override
  String get bodyWeightDateLabel => 'Fecha';

  @override
  String get bodyWeightMeasuresOptional => 'Medidas (opcional)';

  @override
  String get bodyWeightWaistLabel => 'Cintura (cm)';

  @override
  String get bodyWeightArmLabel => 'Brazo (cm)';

  @override
  String get bodyWeightLegLabel => 'Pierna (cm)';

  @override
  String get bodyWeightUnitKg => 'kg';

  @override
  String get bodyWeightUnitLb => 'lb';

  @override
  String get bodyWeightUnitsSectionTitle => 'Unidades';

  @override
  String get bodyWeightUnitPreferenceLabel => 'Peso';

  @override
  String get bodyWeightRecentTitle => 'Últimos registros';

  @override
  String get bodyWeightViewRecords => 'Ver registros';

  @override
  String bodyWeightViewRecordsCount(int count) {
    return 'Ver registros ($count)';
  }

  @override
  String get bodyWeightHistorySheetTitle => 'Registros de peso';

  @override
  String bodyWeightLastLine(String value, String unit, String date) {
    return 'Último: $value $unit · $date';
  }

  @override
  String get bodyWeightDeleteTitle => '¿Eliminar registro?';

  @override
  String get bodyWeightDeleteMessage =>
      'Se eliminará este registro de peso. Esta acción no se puede deshacer.';

  @override
  String get bodyWeightSaved => 'Peso guardado';

  @override
  String get bodyWeightDeleted => 'Registro eliminado';

  @override
  String get bodyWeightErrorRetry => 'No se pudo cargar el peso';

  @override
  String get bodyWeightValidationRequired => 'Ingresa un peso válido';

  @override
  String get bodyWeightValidationRange =>
      'El peso debe estar entre 20 y 300 kg';

  @override
  String get bodyWeightValidationMeasure =>
      'La medida debe ser mayor que 0 y como máximo 300 cm';

  @override
  String get bodyWeightValidationDateFuture => 'No se permiten fechas futuras';

  @override
  String get bodyWeightValidationDateInvalid => 'Fecha inválida';

  @override
  String get bodyWeightChartEmpty => 'Sin datos de peso';

  @override
  String get createWorkout => 'Crear entrenamiento';

  @override
  String get workoutName => 'Nombre del entrenamiento';

  @override
  String get workoutNameTooLong => 'El nombre no puede superar 80 caracteres';

  @override
  String get emptyWorkoutsHint => 'No hay entrenamientos guardados';

  @override
  String get editWorkout => 'Editar entrenamiento';

  @override
  String get addExercise => 'Agregar ejercicio';

  @override
  String get editExercise => 'Editar ejercicio';

  @override
  String get exerciseName => 'Nombre del ejercicio';

  @override
  String get sets => 'Sets';

  @override
  String get workDuration => 'Duración trabajo';

  @override
  String get restDuration => 'Duración descanso';

  @override
  String get restBetweenSetsDuration => 'Descanso entre sets';

  @override
  String get restAfterExerciseDuration => 'Descanso final';

  @override
  String get setsInvalid => 'Los sets deben estar entre 1 y 99';

  @override
  String get restDurationInvalid =>
      'Duración inválida. Debe estar entre 00:00 y 99:59';

  @override
  String get restAfterExerciseInvalid =>
      'Duración inválida. Debe estar entre 00:00 y 99:59';

  @override
  String get train => 'Entrenar';

  @override
  String get edit => 'Editar';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteWorkoutTitle => 'Eliminar entrenamiento';

  @override
  String get deleteWorkoutMessage =>
      'Esta acción no se puede deshacer. ¿Eliminar este entrenamiento?';

  @override
  String get emptyWorkoutStart =>
      'Se requiere al menos un ejercicio para iniciar';

  @override
  String get deleteBlockedDuringSession =>
      'Finaliza o cancela la sesión antes de eliminar un entrenamiento';

  @override
  String exerciseCountLabel(int count) {
    return '$count ejercicios';
  }

  @override
  String get workoutRoundsTitle => 'Rondas del entrenamiento';

  @override
  String get workoutRoundsShort => 'Rondas';

  @override
  String get workoutRoundsHelper =>
      'Todo el bloque de ejercicios se repite N veces';

  @override
  String workoutRoundsBlockChip(int count) {
    return 'Todo el bloque × $count';
  }

  @override
  String workoutRoundsListLabel(int count) {
    return '$count rondas';
  }

  @override
  String workoutRoundProgress(int current, int total) {
    return 'Ronda $current de $total';
  }

  @override
  String get workoutRoundsInvalid => 'Las rondas deben estar entre 1 y 99';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesFilterChip => 'Favoritos';

  @override
  String get markAsFavorite => 'Marcar como favorito';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get emptyFavoritesHint => 'Aún no tienes rutinas favoritas';

  @override
  String get featuredRoutines => 'Rutinas Destacadas';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get myRoutines => 'Mis Rutinas';

  @override
  String get noFavoriteWorkouts => 'No tienes entrenamientos favoritos';

  @override
  String get moreOptions => 'Más opciones';

  @override
  String get presetRoutinesTitle => 'Rutinas Preestablecidas';

  @override
  String get featuredToday => 'Destacadas del Día';

  @override
  String get allRoutines => 'Todas las Rutinas';

  @override
  String get noFavoritePresets =>
      'No tienes rutinas preestablecidas favoritas.';

  @override
  String get noCategoryPresets =>
      'No hay rutinas disponibles para esta categoría.';

  @override
  String get presetDetailTitle => 'Detalle de Rutina';

  @override
  String get duplicateToMyRoutines => 'Duplicar a Mis Rutinas';

  @override
  String get routineNotFound => 'Rutina no encontrada.';

  @override
  String get startWorkout => 'INICIAR ENTRENAMIENTO';

  @override
  String get stepByStepTechnique => 'Técnica Paso a Paso';

  @override
  String get postureTips => 'Consejos de Postura & Tips';

  @override
  String get followTimerRhythm => 'Sigue el ritmo del temporizador.';

  @override
  String exerciseSetsChip(int count) {
    return '$count sets';
  }

  @override
  String exerciseRestBetween(String time) {
    return 'entre $time';
  }

  @override
  String exerciseRestFinal(String time) {
    return 'final $time';
  }

  @override
  String get presetRoutineBadge => 'Preestablecida';

  @override
  String get customRoutineBadge => 'Personalizada';

  @override
  String get noCategoryFavoritePresets =>
      'No tienes rutinas favoritas en esta categoría.';

  @override
  String get errorLoadingPresetCatalog =>
      'Error al cargar el catálogo de rutinas.';

  @override
  String get filterAll => 'Todos';

  @override
  String exerciseCountShort(int count) {
    return '$count ejer.';
  }

  @override
  String routineSavedToMyRoutines(String name) {
    return 'Rutina guardada en Mis Rutinas: \"$name\"';
  }

  @override
  String get goToRoutines => 'IR A RUTINAS';

  @override
  String errorCloningRoutine(String error) {
    return 'Error al clonar rutina: $error';
  }

  @override
  String routineDuplicated(String name) {
    return 'Rutina duplicada: \"$name\"';
  }

  @override
  String get metricDuration => 'Duración';

  @override
  String get metricEstCalories => 'Est. Calorías';

  @override
  String get metricExercises => 'Ejercicios';

  @override
  String get sessionExercisesTitle => 'Ejercicios de la Sesión';

  @override
  String get workShort => 'trabajo';

  @override
  String get restShort => 'descanso';

  @override
  String get quickAudioSettings => 'Sonido y vibración';

  @override
  String get quickAudioSettingsTooltip => 'Ajustes de sonido y vibración';

  @override
  String get voiceAnnouncements => 'Anuncios por voz';

  @override
  String get voiceAnnouncementsDesc =>
      'Nombres de intervalos y cuenta regresiva';

  @override
  String get soundEffects => 'Sonidos del timer';

  @override
  String get soundEffectsDesc => 'Beeps de cuenta regresiva y cambio de fase';

  @override
  String get vibrationFeedback => 'Respuesta táctil';

  @override
  String get vibrationFeedbackDesc => 'Vibración al cambiar de intervalo';

  @override
  String get muteAll => 'Silenciar todo';

  @override
  String get unmuteAll => 'Activar todo';
}
