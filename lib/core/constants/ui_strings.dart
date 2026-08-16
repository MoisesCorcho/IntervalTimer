/// Spanish UI strings (pre-F28 i18n).
abstract final class UiStrings {
  /// Product display name — single source for MaterialApp + share branding.
  /// Change here when the temporary package name is replaced.
  static const appTitle = 'Interval Timer';

  /// Tagline under [appTitle] on share cards (via [AppBranding.tagline]).
  static const appTagline = 'Tu asistente de entrenamiento';

  // Creation / edit
  static const routineTitle = 'Mi rutina';
  static const addInterval = 'Agregar intervalo';
  static const editInterval = 'Editar intervalo';
  static const intervalName = 'Nombre del intervalo';
  static const duration = 'Duración';
  static const minutesLabel = 'MINUTOS';
  static const secondsLabel = 'SEGUNDOS';
  static const totalLabel = 'total';
  static const increaseMinutes = 'Aumentar minutos';
  static const decreaseMinutes = 'Disminuir minutos';
  static const increaseSeconds = 'Aumentar segundos';
  static const decreaseSeconds = 'Disminuir segundos';
  static const color = 'Color';
  static const save = 'Guardar';
  static const cancel = 'Cancelar';
  static const startSession = 'Iniciar';
  static const emptyRoutineMessage =
      'Agrega al menos un intervalo para comenzar';
  static const emptyRoutineHint = 'No hay intervalos en la rutina';

  // Validation
  static const nameRequired = 'El nombre es obligatorio';
  static const nameTooLong = 'El nombre no puede superar 50 caracteres';
  static const durationInvalid =
      'Duración inválida. Debe estar entre 00:01 y 99:59';
  static const emptyRoutineStart =
      'Se requiere al menos un intervalo para iniciar';

  // Execution
  static const pause = 'Pausar';
  static const resume = 'Reanudar';
  static const skip = 'Saltar';
  static const previous = 'Anterior';
  static const cancelSession = 'Cancelar sesión';
  static const exitSession = 'Salir';
  static const nextInterval = 'Siguiente';
  static const lastInterval = 'Último intervalo';
  static const intervalProgress = 'Intervalo {current} de {total}';
  static const remainingLabel = 'RESTANTE';
  static const preparation = 'PREPARACIÓN';
  static const exitConfirmTitle = '¿Salir del entrenamiento?';
  static const exitConfirmMessage =
      'Se perderá el progreso de esta sesión.';
  static const exitConfirmContinue = 'Continuar';
  static const exitConfirmLeave = 'Salir';

  // Settings (F35)
  static const settingsTitle = 'Configuración';
  static const prepSecondsLabel = 'Segundos de preparación';
  static const prepSecondsHint =
      'Cuenta regresiva antes del primer intervalo (0 = desactivada).';
  static const themeLabel = 'Tema';
  static const themeLight = 'Claro';
  static const themeDark = 'Oscuro';
  static const themeSystem = 'Seguir sistema';

  // Voice (F02)
  static const voiceSectionTitle = 'Voz';
  static const voiceEnabledLabel = 'Voz activada';
  static const voiceEnabledHint =
      'Anuncios y cuenta regresiva hablada. No detiene el temporizador.';
  static const countdownSecondsLabel = 'Segundos de cuenta regresiva';
  static const countdownSecondsHint =
      'Habla los últimos N segundos de cada intervalo (0 = solo anuncio de inicio).';
  static const announceIntervalNameLabel = 'Anunciar nombre del intervalo';
  static const announceIntervalNameHint =
      'Dice el nombre (o texto de anuncio) al empezar cada intervalo.';
  static const announceTextLabel = 'Texto de anuncio (opcional)';
  static const announceTextHint =
      'Si está vacío se usa el nombre del intervalo.';
  static const announceTextTooLong =
      'El texto de anuncio no puede superar 80 caracteres';
  static const musicDuckingLabel = 'Atenuar música de fondo';
  static const musicDuckingHint =
      'Baja el volumen de la música externa durante las locuciones de voz.';

  // Vibration (F18)
  static const vibrationSectionTitle = 'Vibración';
  static const vibrationEnabledLabel = 'Vibración activada';
  static const vibrationEnabledHint =
      'Feedback táctil al cambiar de intervalo y en la cuenta regresiva. Independiente de la voz.';
  static const vibrationOnIntervalStartLabel = 'Al cambiar de intervalo';
  static const vibrationOnIntervalStartHint =
      'Pulso al iniciar cada intervalo.';
  static const vibrationOnCountdownLabel = 'En cuenta regresiva';
  static const vibrationOnCountdownHint =
      'Pulsos en los últimos segundos de cada intervalo.';
  static const vibrationCountdownSecondsLabel =
      'Segundos de cuenta regresiva (vibración)';
  static const vibrationCountdownSecondsHint =
      'Vibra en los últimos N segundos (0 = solo al cambiar de intervalo).';

  // Sound effects (F36)
  static const soundSectionTitle = 'Efectos de sonido';
  static const soundEnabledLabel = 'Efectos de sonido activados';
  static const soundEnabledHint =
      'Beeps y chimes del temporizador. Independiente de la voz y la vibración.';
  static const soundOnWorkStartLabel = 'Inicio de trabajo';
  static const soundOnWorkStartHint =
      'Sonido al empezar un intervalo de trabajo (u otro no-descanso).';
  static const soundOnRestStartLabel = 'Inicio de descanso';
  static const soundOnRestStartHint = 'Sonido al empezar un intervalo de descanso.';
  static const soundOnSessionCompleteLabel = 'Fin de sesión';
  static const soundOnSessionCompleteHint =
      'Sonido al completar el entrenamiento.';
  static const soundOnPrepTickLabel = 'Ticks de preparación';
  static const soundOnPrepTickHint =
      'Un tick por cada segundo de la cuenta de preparación.';
  static const soundOnPhaseWarningLabel = 'Cuenta regresiva final';
  static const soundOnPhaseWarningHint =
      'Ticks en los últimos N segundos de cada intervalo.';
  static const soundCountdownSecondsLabel =
      'Segundos de cuenta regresiva (sonido)';
  static const soundCountdownSecondsHint =
      'Reproduce el aviso en los últimos N segundos (0 = desactivado).';
  static const soundClipLabel = 'Sonido';
  static const soundChangeClip = 'Cambiar';
  static const soundPreviewClip = 'Probar';
  static const soundPickClipTitle = 'Elegir sonido';
  static const soundSlotWorkStart = 'Inicio de trabajo';
  static const soundSlotRestStart = 'Inicio de descanso';
  static const soundSlotSessionComplete = 'Fin de sesión';
  static const soundSlotPrepTick = 'Tick de preparación';
  static const soundSlotPhaseWarning = 'Aviso de cuenta regresiva';

  // Always-on screen (F19)
  static const keepScreenOnSectionTitle = 'Pantalla';
  static const keepScreenOnEnabledLabel = 'Pantalla siempre encendida';
  static const keepScreenOnEnabledHint =
      'Evita que la pantalla se apague durante el entrenamiento. Puede consumir más batería.';

  // Session lock screen / notification (F20)
  static const sessionLockScreenSectionTitle = 'Controles de sesión';
  static const sessionLockScreenEnabledLabel =
      'Notificación de sesión / pantalla de bloqueo';
  static const sessionLockScreenEnabledHint =
      'Muestra el intervalo y el tiempo restante con controles de pausa y salto mientras entrenás.';
  static const sessionLockScreenPermissionDenied =
      'Se necesita permiso de notificaciones para mostrar la sesión en segundo plano. El temporizador sigue funcionando en la app.';
  static const sessionLockScreenRetryPermission = 'Reintentar permiso';
  static const sessionLockScreenOpenSystemSettings = 'Abrir ajustes del sistema';
  static const sessionSurfaceFallbackTitle = 'Intervalo';
  static const sessionSurfaceStatusRunning = 'En curso';
  static const sessionSurfaceStatusPaused = 'Pausado';

  // Completed (F01 placeholder / F16 post-session)
  static const sessionCompleted = '¡Sesión completada!';
  static const sessionCompletedMessage =
      'Has terminado todos los intervalos de la rutina.';
  static const backToRoutine = 'Volver';
  static const sessionSummaryGreatJob = '¡Gran trabajo!';
  static const sessionSummaryTraining = 'Entrenamiento';
  static const sessionSummaryRest = 'Descanso total';
  static const sessionSummarySharePrompt = '¡Comparte tus resultados con estilo!';
  static const sessionSummarySharePromptDetail =
      'Elegí plantilla, sumá una foto y compartí o guardá en la galería.';
  static const sessionSummaryShare = 'Compartir';
  static const sessionSummarySharing = 'Compartiendo…';
  static const sessionSummaryShareFailed =
      'No se pudo generar o compartir la imagen. Intenta de nuevo.';
  static const sessionSummaryNotePrompt = '¿Cómo fue tu entrenamiento?';
  static const sessionSummaryNoteUnavailable =
      'La nota estará disponible en un momento. Podés añadirla también en Historial.';
  static const sessionSummaryNoteSaveFailed =
      'No se pudo guardar la nota. Reintentá o salí sin guardar.';
  static const sessionSummaryDoneAnyway = 'Salir sin nota';
  static const sessionSummaryDone = 'Listo';
  static const sessionSummaryFallbackName = 'Entrenamiento';
  static const sessionSummaryShareDuration = 'Duración';
  static const sessionSummaryShareKcal = 'kcal (est.)';
  static const sessionSummaryShareStreak = 'Racha (días)';
  static const sessionSummaryShareTitle = 'Compartir';
  static const sessionSummaryShareAddPhoto = 'Añadir foto';
  static const sessionSummaryShareTakePhoto = 'Hacer foto';
  static const sessionSummarySharePickGallery = 'Seleccionar imagen';
  static const sessionSummarySharePhotoFailed =
      'No se pudo obtener la foto. Revisá los permisos e intentá de nuevo.';
  static const sessionSummaryShareSaveGallery = 'Guardar en la galería';
  static const sessionSummaryShareSavedGallery = 'Imagen guardada en la galería';
  static const sessionSummaryShareSaveGalleryFailed =
      'No se pudo guardar en la galería. Revisá los permisos.';
  static const sessionSummaryShareOfflineHint =
      'Plantillas y foto funcionan sin conexión';
  static const sessionSummaryShareWorkoutBadge = 'Entrenamiento';
  static const sessionSummaryShareSets = 'Sets';
  static const sessionSummaryShareWork = 'Trabajo';
  static const sessionSummaryShareRest = 'Descanso';
  static const sessionSummarySheetHint =
      'Deslizá hacia arriba para ver más detalle';
  static const sessionSummaryNewAchievementsOne = '¡1 logro nuevo!';
  static const sessionSummaryNewAchievementsMany = '¡{count} logros nuevos!';
  static const sessionSummaryViewAchievements = 'Ver logros';

  // Achievements / badges (F13)
  static const achievementsTitle = 'Logros';
  static const achievementsEntryTitle = 'Logros';
  static const achievementsEntrySubtitle = 'Ver desbloqueados y progreso';
  static const achievementsUnlockedBadge = 'Desbloqueado';
  static const achievementsLockedBadge = 'Pendiente';
  static const achievementsError = 'No se pudieron cargar los logros';
  static const achievementsEmptyHint = 'Completa sesiones para desbloquear logros';
  static const achievementsSheetTitle = '¡Logros desbloqueados!';
  static const achievementsSheetClose = 'Genial';
  static const achievementsUnlockedOn = 'Desbloqueado el {date}';
  static const achievementsProgressSessions = '{current}/{target} sesiones';
  static const achievementsProgressDays = '{current}/{target} días';
  static const achievementsProgressMinutes = '{current}/{target} min';

  static String achievementTitle(String id) {
    return switch (id) {
      'first_session' => 'Primera sesión',
      'sessions_10' => '10 sesiones',
      'sessions_25' => '25 sesiones',
      'sessions_50' => '50 sesiones',
      'sessions_100' => '100 sesiones',
      'streak_3' => 'Racha de 3 días',
      'streak_7' => 'Racha de 7 días',
      'streak_14' => 'Racha de 14 días',
      'streak_30' => 'Racha de 30 días',
      'minutes_60' => '60 minutos',
      'minutes_300' => '300 minutos',
      'minutes_1000' => '1000 minutos',
      _ => id,
    };
  }

  static String achievementDescription(String id) {
    return switch (id) {
      'first_session' => 'Completá tu primera sesión de entrenamiento.',
      'sessions_10' => 'Completá 10 sesiones en total.',
      'sessions_25' => 'Completá 25 sesiones en total.',
      'sessions_50' => 'Completá 50 sesiones en total.',
      'sessions_100' => 'Completá 100 sesiones en total.',
      'streak_3' => 'Entrená al menos un día durante 3 días seguidos.',
      'streak_7' => 'Entrená al menos un día durante 7 días seguidos.',
      'streak_14' => 'Entrená al menos un día durante 14 días seguidos.',
      'streak_30' => 'Entrená al menos un día durante 30 días seguidos.',
      'minutes_60' => 'Acumulá 60 minutos de sesiones completadas.',
      'minutes_300' => 'Acumulá 300 minutos de sesiones completadas.',
      'minutes_1000' => 'Acumulá 1000 minutos de sesiones completadas.',
      _ => '',
    };
  }

  // Errors
  static const persistenceError =
      'No se pudo guardar. Intenta de nuevo.';
  static const retry = 'Reintentar';

  // Workouts (F32)
  static const workoutsTitle = 'Mis entrenamientos';
  static const navRoutine = 'Rutina';
  static const navWorkouts = 'Entrenamientos';
  static const navHistory = 'Historial';
  static const navSettings = 'Ajustes';

  // History / calendar (F04)
  static const historyTitle = 'Historial';
  static const historyWorkoutsSection = 'Entrenamientos';
  static const historyEmptyDay = 'No hay entrenamientos este día';
  static const historyAddNote = 'Añadir una nota...';
  static const historyEditNoteTitle = 'Nota del entrenamiento';
  static const historyNoteTooLong =
      'La nota no puede superar 500 caracteres';
  static const historyStart = 'Empezar';
  static const historyDelete = 'Eliminar del historial';
  static const historyDeleteTitle = '¿Eliminar del historial?';
  static const historyDeleteMessage =
      'Esta acción no se puede deshacer. Se borrará el registro de esta sesión.';
  static const historySourceMissing =
      'No se encontró la rutina o entrenamiento original.';
  static const historyGoToToday = 'Ir al día de hoy';
  static const historySelectMonth = 'Seleccionar mes';
  static const historyExerciseCount = 'Ejercicios: {count}';
  static const historyFallbackTitle = 'Entrenamiento a las {time}';

  // Progress / stats (F12) — embedded in History
  static const progressSectionTitle = 'Tu progreso';
  static const progressStreakLabel = 'Racha';
  static const progressWeekMinutesLabel = 'Minutos esta semana';
  static const progressMonthSessionsLabel = 'Sesiones este mes';
  static const progressKcalLabel = 'Calorías estimadas';
  static const progressChartWeek = 'Semana';
  static const progressChartMonth = 'Mes';
  static const progressChartCaption = 'Minutos por día';
  static const progressStatsError = 'No se pudieron cargar las estadísticas';
  static const progressWeightEstimated =
      'Peso estimado {kg} kg';
  static const progressWeightRegistered = 'Peso {kg} kg';
  /// Short always-visible honesty line for kcal method (F12).
  static const progressKcalMethodCaption =
      'kcal estimadas: MET {met} × peso × duración de sesión. No es un gasto medido.';
  static const progressKcalInfoTooltip = 'Cómo se estiman las calorías';
  static const progressKcalInfoTitle = 'Calorías estimadas';
  /// Full explanation shown in the info dialog (not a medical claim).
  static const progressKcalInfoBody =
      'Estimamos la energía con la fórmula estándar MET × peso (kg) × horas de sesión '
      '(definición práctica del Compendium of Physical Activities).\n\n'
      'Usamos MET {met} como referencia de actividad vigorosa de intervalos. '
      'Es un valor poblacional genérico, no una medición de tu metabolismo ni de un sensor.\n\n'
      'Sirve como referencia y para ver tendencias, no como dato clínico ni nutricional exacto.';
  static const progressKcalInfoClose = 'Entendido';
  static const progressTotalLine = 'Total: {totals} · {sessions} sesiones';
  static const progressDaysSuffix = 'días';

  // Body weight / measurements (F15)
  static const bodyWeightSectionTitle = 'Tu peso';
  static const bodyWeightRegisterCta = 'Registrar';
  static const bodyWeightUpdateCta = 'Actualizar';
  static const bodyWeightRegisterButton = 'Registrar peso';
  static const bodyWeightEmptyMessage =
      'Registra tu peso para ver la evolución';
  static const bodyWeightCaptionEstimated =
      'Peso estimado {value} {unit} · Registrar';
  static const bodyWeightCaptionRegistered =
      '{value} {valueUnit} · Actualizar';
  static const bodyWeightFormTitle = 'Registrar peso';
  static const bodyWeightFormEditTitle = 'Editar peso';
  static const bodyWeightFieldLabel = 'Peso';
  static const bodyWeightDateLabel = 'Fecha';
  static const bodyWeightMeasuresOptional = 'Medidas (opcional)';
  static const bodyWeightWaistLabel = 'Cintura (cm)';
  static const bodyWeightArmLabel = 'Brazo (cm)';
  static const bodyWeightLegLabel = 'Pierna (cm)';
  static const bodyWeightUnitKg = 'kg';
  static const bodyWeightUnitLb = 'lb';
  static const bodyWeightUnitsSectionTitle = 'Unidades';
  static const bodyWeightUnitPreferenceLabel = 'Peso';
  static const bodyWeightRecentTitle = 'Últimos registros';
  static const bodyWeightViewRecords = 'Ver registros';
  static const bodyWeightViewRecordsCount = 'Ver registros ({count})';
  static const bodyWeightHistorySheetTitle = 'Registros de peso';
  static const bodyWeightLastLine = 'Último: {value} {unit} · {date}';
  static const bodyWeightDeleteTitle = '¿Eliminar registro?';
  static const bodyWeightDeleteMessage =
      'Se eliminará este registro de peso. Esta acción no se puede deshacer.';
  static const bodyWeightSaved = 'Peso guardado';
  static const bodyWeightDeleted = 'Registro eliminado';
  static const bodyWeightErrorRetry = 'No se pudo cargar el peso';
  static const bodyWeightValidationRequired = 'Ingresa un peso válido';
  static const bodyWeightValidationRange =
      'El peso debe estar entre 20 y 300 kg';
  static const bodyWeightValidationMeasure =
      'La medida debe ser mayor que 0 y como máximo 300 cm';
  static const bodyWeightValidationDateFuture =
      'No se permiten fechas futuras';
  static const bodyWeightValidationDateInvalid = 'Fecha inválida';
  static const bodyWeightChartEmpty = 'Sin datos de peso';

  static const monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];
  static const weekdayShort = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  static const createWorkout = 'Crear entrenamiento';
  static const workoutName = 'Nombre del entrenamiento';
  static const workoutNameTooLong =
      'El nombre no puede superar 80 caracteres';
  static const emptyWorkoutsHint = 'No hay entrenamientos guardados';
  static const editWorkout = 'Editar entrenamiento';
  static const addExercise = 'Agregar ejercicio';
  static const editExercise = 'Editar ejercicio';
  static const exerciseName = 'Nombre del ejercicio';
  static const sets = 'Sets';
  static const workDuration = 'Duración trabajo';
  static const restDuration = 'Duración descanso';
  static const restBetweenSetsDuration = 'Descanso entre sets';
  static const restAfterExerciseDuration = 'Descanso final';
  static const setsInvalid = 'Los sets deben estar entre 1 y 99';
  static const restDurationInvalid =
      'Duración inválida. Debe estar entre 00:00 y 99:59';
  static const restAfterExerciseInvalid =
      'Duración inválida. Debe estar entre 00:00 y 99:59';
  static const train = 'Entrenar';
  static const edit = 'Editar';
  static const duplicate = 'Duplicar';
  static const delete = 'Eliminar';
  static const deleteWorkoutTitle = 'Eliminar entrenamiento';
  static const deleteWorkoutMessage =
      'Esta acción no se puede deshacer. ¿Eliminar este entrenamiento?';
  static const emptyWorkoutStart =
      'Se requiere al menos un ejercicio para iniciar';
  static const deleteBlockedDuringSession =
      'Finaliza o cancela la sesión antes de eliminar un entrenamiento';
  static const exerciseCountLabel = '{count} ejercicios';

  // Workout rounds (F32 extension)
  static const workoutRoundsTitle = 'Rondas del entrenamiento';
  static const workoutRoundsShort = 'Rondas';
  static const workoutRoundsHelper =
      'Todo el bloque de ejercicios se repite N veces';
  static const workoutRoundsBlockChip = 'Todo el bloque × {count}';
  static const workoutRoundsListLabel = '{count} rondas';
  static const workoutRoundProgress = 'Ronda {current} de {total}';
  static const workoutRoundsInvalid =
      'Las rondas deben estar entre 1 y 99';

  // Favorites (F24)
  static const favoritesTitle = 'Favoritos';
  static const favoritesFilterChip = 'Favoritos';
  static const markAsFavorite = 'Marcar como favorito';
  static const removeFromFavorites = 'Quitar de favoritos';
  static const emptyFavoritesHint = 'Aún no tienes rutinas favoritas';
}