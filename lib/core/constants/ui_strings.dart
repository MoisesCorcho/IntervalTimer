/// Spanish UI strings (pre-F28 i18n).
abstract final class UiStrings {
  static const appTitle = 'Interval Timer';

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
  static const cancelSession = 'Cancelar sesión';
  static const nextInterval = 'Siguiente';
  static const lastInterval = 'Último intervalo';
  static const intervalProgress = 'Intervalo {current} de {total}';

  // Completed
  static const sessionCompleted = '¡Sesión completada!';
  static const sessionCompletedMessage =
      'Has terminado todos los intervalos de la rutina.';
  static const backToRoutine = 'Volver';

  // Errors
  static const persistenceError =
      'No se pudo guardar. Intenta de nuevo.';
  static const retry = 'Reintentar';

  // Workouts (F32)
  static const workoutsTitle = 'Mis entrenamientos';
  static const navRoutine = 'Rutina';
  static const navWorkouts = 'Entrenamientos';
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
}