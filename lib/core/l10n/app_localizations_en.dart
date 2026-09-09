// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Interval Timer';

  @override
  String get appTagline => 'Your workout assistant';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageHint => 'Select interface and timer voice language.';

  @override
  String get languageAuto => 'Automatic (System)';

  @override
  String get languageEs => 'Spanish';

  @override
  String get languageEn => 'English';

  @override
  String get timerPhasePreparation => 'Get Ready';

  @override
  String get timerPhaseWork => 'Work';

  @override
  String get timerPhaseRest => 'Rest';

  @override
  String get timerPhaseCompleted => 'Session Complete';

  @override
  String get routineTitle => 'My Routine';

  @override
  String get addInterval => 'Add interval';

  @override
  String get editInterval => 'Edit interval';

  @override
  String get intervalName => 'Interval name';

  @override
  String get duration => 'Duration';

  @override
  String get minutesLabel => 'MINUTES';

  @override
  String get secondsLabel => 'SECONDS';

  @override
  String get totalLabel => 'total';

  @override
  String get increaseMinutes => 'Increase minutes';

  @override
  String get decreaseMinutes => 'Decrease minutes';

  @override
  String get increaseSeconds => 'Increase seconds';

  @override
  String get decreaseSeconds => 'Decrease seconds';

  @override
  String get color => 'Color';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get startSession => 'Start';

  @override
  String get emptyRoutineMessage => 'Add at least one interval to start';

  @override
  String get emptyRoutineHint => 'No intervals in routine';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameTooLong => 'Name cannot exceed 50 characters';

  @override
  String get durationInvalid =>
      'Invalid duration. Must be between 00:01 and 99:59';

  @override
  String get emptyRoutineStart => 'At least one interval is required to start';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get skip => 'Skip';

  @override
  String get previous => 'Previous';

  @override
  String get cancelSession => 'Cancel session';

  @override
  String get exitSession => 'Exit';

  @override
  String get nextInterval => 'Next';

  @override
  String get lastInterval => 'Last interval';

  @override
  String intervalProgress(int current, int total) {
    return 'Interval $current of $total';
  }

  @override
  String get remainingLabel => 'REMAINING';

  @override
  String get preparation => 'GET READY';

  @override
  String get exitConfirmTitle => 'Exit workout?';

  @override
  String get exitConfirmMessage => 'Session progress will be lost.';

  @override
  String get exitConfirmContinue => 'Continue';

  @override
  String get exitConfirmLeave => 'Exit';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get prepSecondsLabel => 'Preparation seconds';

  @override
  String get prepSecondsHint =>
      'Countdown before the first interval (0 = disabled).';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get voiceSectionTitle => 'Voice';

  @override
  String get voiceEnabledLabel => 'Voice enabled';

  @override
  String get voiceEnabledHint =>
      'Announcements and spoken countdown. Does not stop timer.';

  @override
  String get countdownSecondsLabel => 'Countdown seconds';

  @override
  String get countdownSecondsHint =>
      'Speaks the last N seconds of each interval (0 = start announcement only).';

  @override
  String get announceIntervalNameLabel => 'Announce interval name';

  @override
  String get announceIntervalNameHint =>
      'Speaks interval name (or custom prompt) at start.';

  @override
  String get announceTextLabel => 'Announcement text (optional)';

  @override
  String get announceTextHint => 'If empty, interval name will be used.';

  @override
  String get announceTextTooLong =>
      'Announcement text cannot exceed 80 characters';

  @override
  String get musicDuckingLabel => 'Ducking background music';

  @override
  String get musicDuckingHint =>
      'Lowers external music volume during voice announcements.';

  @override
  String get vibrationSectionTitle => 'Vibration';

  @override
  String get vibrationEnabledLabel => 'Vibration enabled';

  @override
  String get vibrationEnabledHint =>
      'Haptic feedback on interval change and countdown. Independent of voice.';

  @override
  String get vibrationOnIntervalStartLabel => 'On interval change';

  @override
  String get vibrationOnIntervalStartHint =>
      'Pulse when starting each interval.';

  @override
  String get vibrationOnCountdownLabel => 'On countdown';

  @override
  String get vibrationOnCountdownHint =>
      'Pulses during the last seconds of each interval.';

  @override
  String get vibrationCountdownSecondsLabel => 'Countdown seconds (vibration)';

  @override
  String get vibrationCountdownSecondsHint =>
      'Vibrates during last N seconds (0 = interval change only).';

  @override
  String get soundSectionTitle => 'Sound effects';

  @override
  String get soundEnabledLabel => 'Sound effects enabled';

  @override
  String get soundEnabledHint =>
      'Timer beeps and chimes. Independent of voice and vibration.';

  @override
  String get soundOnWorkStartLabel => 'Work start';

  @override
  String get soundOnWorkStartHint =>
      'Sound when starting work intervals (or non-rest).';

  @override
  String get soundOnRestStartLabel => 'Rest start';

  @override
  String get soundOnRestStartHint => 'Sound when starting rest intervals.';

  @override
  String get soundOnSessionCompleteLabel => 'Session complete';

  @override
  String get soundOnSessionCompleteHint => 'Sound upon workout completion.';

  @override
  String get soundOnPrepTickLabel => 'Preparation ticks';

  @override
  String get soundOnPrepTickHint =>
      'One tick per second during preparation countdown.';

  @override
  String get soundOnPhaseWarningLabel => 'Final countdown';

  @override
  String get soundOnPhaseWarningHint =>
      'Ticks during the last N seconds of each interval.';

  @override
  String get soundCountdownSecondsLabel => 'Countdown seconds (sound)';

  @override
  String get soundCountdownSecondsHint =>
      'Plays alert in the last N seconds (0 = disabled).';

  @override
  String get soundClipLabel => 'Sound';

  @override
  String get soundChangeClip => 'Change';

  @override
  String get soundPreviewClip => 'Test';

  @override
  String get soundPickClipTitle => 'Select sound';

  @override
  String get soundSlotWorkStart => 'Work start';

  @override
  String get soundSlotRestStart => 'Rest start';

  @override
  String get soundSlotSessionComplete => 'Session complete';

  @override
  String get soundSlotPrepTick => 'Preparation tick';

  @override
  String get soundSlotPhaseWarning => 'Countdown alert';

  @override
  String get keepScreenOnSectionTitle => 'Screen';

  @override
  String get keepScreenOnEnabledLabel => 'Keep screen on';

  @override
  String get keepScreenOnEnabledHint =>
      'Prevents screen from sleeping during workout. May consume more battery.';

  @override
  String get sessionLockScreenSectionTitle => 'Session controls';

  @override
  String get sessionLockScreenEnabledLabel =>
      'Session notification / lock screen';

  @override
  String get sessionLockScreenEnabledHint =>
      'Shows interval and remaining time with pause/skip controls while training.';

  @override
  String get sessionLockScreenPermissionDenied =>
      'Notification permission is required for background session. Timer keeps working in app.';

  @override
  String get sessionLockScreenRetryPermission => 'Retry permission';

  @override
  String get sessionLockScreenOpenSystemSettings => 'Open system settings';

  @override
  String get sessionSurfaceFallbackTitle => 'Interval';

  @override
  String get sessionSurfaceStatusRunning => 'Running';

  @override
  String get sessionSurfaceStatusPaused => 'Paused';

  @override
  String get sessionCompleted => 'Session completed!';

  @override
  String get sessionCompletedMessage =>
      'You have completed all intervals in the routine.';

  @override
  String get backToRoutine => 'Back';

  @override
  String get sessionSummaryGreatJob => 'Great job!';

  @override
  String get sessionSummaryTraining => 'Workout';

  @override
  String get sessionSummaryRest => 'Total rest';

  @override
  String get sessionSummarySharePrompt => 'Share your results with style!';

  @override
  String get sessionSummarySharePromptDetail =>
      'Choose a template, add a photo, and share or save to gallery.';

  @override
  String get sessionSummaryShare => 'Share';

  @override
  String get sessionSummarySharing => 'Sharing…';

  @override
  String get sessionSummaryShareFailed =>
      'Could not generate or share image. Try again.';

  @override
  String get sessionSummaryNotePrompt => 'How was your workout?';

  @override
  String get sessionSummaryNoteUnavailable =>
      'Note will be available in a moment. You can also add it in History.';

  @override
  String get sessionSummaryNoteSaveFailed =>
      'Could not save note. Retry or exit without saving.';

  @override
  String get sessionSummaryDoneAnyway => 'Exit without note';

  @override
  String get sessionSummaryDone => 'Done';

  @override
  String get sessionSummaryFallbackName => 'Workout';

  @override
  String get sessionSummaryShareDuration => 'Duration';

  @override
  String get sessionSummaryShareKcal => 'kcal (est.)';

  @override
  String get sessionSummaryShareStreak => 'Streak (days)';

  @override
  String get sessionSummaryShareTitle => 'Share';

  @override
  String get sessionSummaryShareAddPhoto => 'Add photo';

  @override
  String get sessionSummaryShareTakePhoto => 'Take photo';

  @override
  String get sessionSummarySharePickGallery => 'Select image';

  @override
  String get sessionSummarySharePhotoFailed =>
      'Could not retrieve photo. Check permissions and try again.';

  @override
  String get sessionSummaryShareSaveGallery => 'Save to gallery';

  @override
  String get sessionSummaryShareSavedGallery => 'Image saved to gallery';

  @override
  String get sessionSummaryShareSaveGalleryFailed =>
      'Could not save to gallery. Check permissions.';

  @override
  String get sessionSummaryShareOfflineHint =>
      'Templates and photos work offline';

  @override
  String get sessionSummaryShareWorkoutBadge => 'Workout';

  @override
  String get sessionSummaryShareSets => 'Sets';

  @override
  String get sessionSummaryShareWork => 'Work';

  @override
  String get sessionSummaryShareRest => 'Rest';

  @override
  String get sessionSummarySheetHint => 'Swipe up for more details';

  @override
  String get sessionSummaryNewAchievementsOne => '1 new achievement!';

  @override
  String sessionSummaryNewAchievementsMany(int count) {
    return '$count new achievements!';
  }

  @override
  String get sessionSummaryViewAchievements => 'View achievements';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementsEntryTitle => 'Achievements';

  @override
  String get achievementsEntrySubtitle => 'View unlocked badges and progress';

  @override
  String get achievementsUnlockedBadge => 'Unlocked';

  @override
  String get achievementsLockedBadge => 'Pending';

  @override
  String get achievementsError => 'Could not load achievements';

  @override
  String get achievementsEmptyHint =>
      'Complete sessions to unlock achievements';

  @override
  String get achievementsSheetTitle => 'Achievements unlocked!';

  @override
  String get achievementsSheetClose => 'Awesome';

  @override
  String achievementsUnlockedOn(String date) {
    return 'Unlocked on $date';
  }

  @override
  String achievementsProgressSessions(int current, int target) {
    return '$current/$target sessions';
  }

  @override
  String achievementsProgressDays(int current, int target) {
    return '$current/$target days';
  }

  @override
  String achievementsProgressMinutes(int current, int target) {
    return '$current/$target min';
  }

  @override
  String get achievementFirstSessionTitle => 'First session';

  @override
  String get achievementFirstSessionDesc =>
      'Complete your first workout session.';

  @override
  String get achievementSessions10Title => '10 sessions';

  @override
  String get achievementSessions10Desc => 'Complete 10 total sessions.';

  @override
  String get achievementSessions25Title => '25 sessions';

  @override
  String get achievementSessions25Desc => 'Complete 25 total sessions.';

  @override
  String get achievementSessions50Title => '50 sessions';

  @override
  String get achievementSessions50Desc => 'Complete 50 total sessions.';

  @override
  String get achievementSessions100Title => '100 sessions';

  @override
  String get achievementSessions100Desc => 'Complete 100 total sessions.';

  @override
  String get achievementStreak3Title => '3-day streak';

  @override
  String get achievementStreak3Desc =>
      'Work out at least one day for 3 days in a row.';

  @override
  String get achievementStreak7Title => '7-day streak';

  @override
  String get achievementStreak7Desc =>
      'Work out at least one day for 7 days in a row.';

  @override
  String get achievementStreak14Title => '14-day streak';

  @override
  String get achievementStreak14Desc =>
      'Work out at least one day for 14 days in a row.';

  @override
  String get achievementStreak30Title => '30-day streak';

  @override
  String get achievementStreak30Desc =>
      'Work out at least one day for 30 days in a row.';

  @override
  String get achievementMinutes60Title => '60 minutes';

  @override
  String get achievementMinutes60Desc =>
      'Accumulate 60 minutes of completed sessions.';

  @override
  String get achievementMinutes300Title => '300 minutes';

  @override
  String get achievementMinutes300Desc =>
      'Accumulate 300 minutes of completed sessions.';

  @override
  String get achievementMinutes1000Title => '1000 minutes';

  @override
  String get achievementMinutes1000Desc =>
      'Accumulate 1000 minutes of completed sessions.';

  @override
  String get persistenceError => 'Could not save. Try again.';

  @override
  String get retry => 'Retry';

  @override
  String get workoutsTitle => 'My Workouts';

  @override
  String get navRoutine => 'Routine';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get historyTitle => 'History';

  @override
  String get historyWorkoutsSection => 'Workouts';

  @override
  String get historyEmptyDay => 'No workouts this day';

  @override
  String get historyAddNote => 'Add a note…';

  @override
  String get historyEditNoteTitle => 'Workout note';

  @override
  String get historyNoteTooLong => 'Note cannot exceed 500 characters';

  @override
  String get historyStart => 'Start';

  @override
  String get historyDelete => 'Delete from history';

  @override
  String get historyDeleteTitle => 'Delete from history?';

  @override
  String get historyDeleteMessage =>
      'This action cannot be undone. The record of this session will be deleted.';

  @override
  String get historySourceMissing =>
      'Original routine or workout was not found.';

  @override
  String get historyGoToToday => 'Go to today';

  @override
  String get historySelectMonth => 'Select month';

  @override
  String historyExerciseCount(int count) {
    return 'Exercises: $count';
  }

  @override
  String historyFallbackTitle(String time) {
    return 'Workout at $time';
  }

  @override
  String get progressSectionTitle => 'Your progress';

  @override
  String get progressStreakLabel => 'Streak';

  @override
  String get progressWeekMinutesLabel => 'Minutes this week';

  @override
  String get progressMonthSessionsLabel => 'Sessions this month';

  @override
  String get progressKcalLabel => 'Estimated calories';

  @override
  String get progressChartWeek => 'Week';

  @override
  String get progressChartMonth => 'Month';

  @override
  String get progressChartCaption => 'Minutes per day';

  @override
  String get progressStatsError => 'Could not load statistics';

  @override
  String progressWeightEstimated(String kg) {
    return 'Estimated weight $kg kg';
  }

  @override
  String progressWeightRegistered(String kg) {
    return 'Weight $kg kg';
  }

  @override
  String progressKcalMethodCaption(String met) {
    return 'Estimated kcal: MET $met × weight × duration. Not a direct measurement.';
  }

  @override
  String get progressKcalInfoTooltip => 'How calories are estimated';

  @override
  String get progressKcalInfoTitle => 'Estimated calories';

  @override
  String progressKcalInfoBody(String met) {
    return 'We estimate energy using the standard formula MET × weight (kg) × session hours (practical definition from Compendium of Physical Activities).\n\nWe use MET $met as reference for vigorous interval activity. This is a generic population estimate, not a metabolic measurement.\n\nIt serves as a guideline and trend indicator, not clinical data.';
  }

  @override
  String get progressKcalInfoClose => 'Understood';

  @override
  String progressTotalLine(String totals, int sessions) {
    return 'Total: $totals · $sessions sessions';
  }

  @override
  String get progressDaysSuffix => 'days';

  @override
  String get bodyWeightSectionTitle => 'Your weight';

  @override
  String get bodyWeightRegisterCta => 'Log';

  @override
  String get bodyWeightUpdateCta => 'Update';

  @override
  String get bodyWeightRegisterButton => 'Log weight';

  @override
  String get bodyWeightEmptyMessage => 'Log your weight to track progress';

  @override
  String bodyWeightCaptionEstimated(String value, String unit) {
    return 'Estimated weight $value $unit · Log';
  }

  @override
  String bodyWeightCaptionRegistered(String value, String valueUnit) {
    return '$value $valueUnit · Update';
  }

  @override
  String get bodyWeightFormTitle => 'Log weight';

  @override
  String get bodyWeightFormEditTitle => 'Edit weight';

  @override
  String get bodyWeightFieldLabel => 'Weight';

  @override
  String get bodyWeightDateLabel => 'Date';

  @override
  String get bodyWeightMeasuresOptional => 'Body measurements (optional)';

  @override
  String get bodyWeightWaistLabel => 'Waist (cm)';

  @override
  String get bodyWeightArmLabel => 'Arm (cm)';

  @override
  String get bodyWeightLegLabel => 'Leg (cm)';

  @override
  String get bodyWeightUnitKg => 'kg';

  @override
  String get bodyWeightUnitLb => 'lb';

  @override
  String get bodyWeightUnitsSectionTitle => 'Units';

  @override
  String get bodyWeightUnitPreferenceLabel => 'Weight';

  @override
  String get bodyWeightRecentTitle => 'Recent entries';

  @override
  String get bodyWeightViewRecords => 'View records';

  @override
  String bodyWeightViewRecordsCount(int count) {
    return 'View records ($count)';
  }

  @override
  String get bodyWeightHistorySheetTitle => 'Weight history';

  @override
  String bodyWeightLastLine(String value, String unit, String date) {
    return 'Last: $value $unit · $date';
  }

  @override
  String get bodyWeightDeleteTitle => 'Delete entry?';

  @override
  String get bodyWeightDeleteMessage =>
      'This weight entry will be deleted. This action cannot be undone.';

  @override
  String get bodyWeightSaved => 'Weight saved';

  @override
  String get bodyWeightDeleted => 'Entry deleted';

  @override
  String get bodyWeightErrorRetry => 'Could not load weight';

  @override
  String get bodyWeightValidationRequired => 'Enter a valid weight';

  @override
  String get bodyWeightValidationRange =>
      'Weight must be between 20 and 300 kg';

  @override
  String get bodyWeightValidationMeasure =>
      'Measurement must be greater than 0 and at most 300 cm';

  @override
  String get bodyWeightValidationDateFuture => 'Future dates are not allowed';

  @override
  String get bodyWeightValidationDateInvalid => 'Invalid date';

  @override
  String get bodyWeightChartEmpty => 'No weight data';

  @override
  String get createWorkout => 'Create workout';

  @override
  String get workoutName => 'Workout name';

  @override
  String get workoutNameTooLong => 'Name cannot exceed 80 characters';

  @override
  String get emptyWorkoutsHint => 'No saved workouts';

  @override
  String get editWorkout => 'Edit workout';

  @override
  String get addExercise => 'Add exercise';

  @override
  String get editExercise => 'Edit exercise';

  @override
  String get exerciseName => 'Exercise name';

  @override
  String get sets => 'Sets';

  @override
  String get workDuration => 'Work duration';

  @override
  String get restDuration => 'Rest duration';

  @override
  String get restBetweenSetsDuration => 'Rest between sets';

  @override
  String get restAfterExerciseDuration => 'Final rest';

  @override
  String get setsInvalid => 'Sets must be between 1 and 99';

  @override
  String get restDurationInvalid =>
      'Invalid duration. Must be between 00:00 and 99:59';

  @override
  String get restAfterExerciseInvalid =>
      'Invalid duration. Must be between 00:00 and 99:59';

  @override
  String get train => 'Train';

  @override
  String get edit => 'Edit';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get delete => 'Delete';

  @override
  String get deleteWorkoutTitle => 'Delete workout';

  @override
  String get deleteWorkoutMessage =>
      'This action cannot be undone. Delete this workout?';

  @override
  String get emptyWorkoutStart => 'At least one exercise is required to start';

  @override
  String get deleteBlockedDuringSession =>
      'Finish or cancel session before deleting a workout';

  @override
  String exerciseCountLabel(int count) {
    return '$count exercises';
  }

  @override
  String get workoutRoundsTitle => 'Workout rounds';

  @override
  String get workoutRoundsShort => 'Rounds';

  @override
  String get workoutRoundsHelper => 'The entire exercise block repeats N times';

  @override
  String workoutRoundsBlockChip(int count) {
    return 'Entire block × $count';
  }

  @override
  String workoutRoundsListLabel(int count) {
    return '$count rounds';
  }

  @override
  String workoutRoundProgress(int current, int total) {
    return 'Round $current of $total';
  }

  @override
  String get workoutRoundsInvalid => 'Rounds must be between 1 and 99';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesFilterChip => 'Favorites';

  @override
  String get markAsFavorite => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get emptyFavoritesHint => 'No favorite routines yet';

  @override
  String get featuredRoutines => 'Featured Routines';

  @override
  String get seeAll => 'See all';

  @override
  String get myRoutines => 'My Routines';

  @override
  String get noFavoriteWorkouts => 'No favorite workouts';

  @override
  String get moreOptions => 'More options';

  @override
  String get presetRoutinesTitle => 'Preset Routines';

  @override
  String get featuredToday => 'Featured Today';

  @override
  String get allRoutines => 'All Routines';

  @override
  String get noFavoritePresets => 'No favorite preset routines.';

  @override
  String get noCategoryPresets => 'No routines available for this category.';

  @override
  String get presetDetailTitle => 'Routine Details';

  @override
  String get duplicateToMyRoutines => 'Duplicate to My Routines';

  @override
  String get routineNotFound => 'Routine not found.';

  @override
  String get startWorkout => 'START WORKOUT';

  @override
  String get stepByStepTechnique => 'Step-by-Step Technique';

  @override
  String get postureTips => 'Posture Advice & Tips';

  @override
  String get followTimerRhythm => 'Follow the timer rhythm.';

  @override
  String exerciseSetsChip(int count) {
    return '$count sets';
  }

  @override
  String exerciseRestBetween(String time) {
    return 'rest $time';
  }

  @override
  String exerciseRestFinal(String time) {
    return 'final $time';
  }

  @override
  String get presetRoutineBadge => 'Preset';

  @override
  String get customRoutineBadge => 'Custom';

  @override
  String get noCategoryFavoritePresets =>
      'You don\'t have favorite routines in this category.';

  @override
  String get errorLoadingPresetCatalog => 'Error loading routine catalog.';

  @override
  String get filterAll => 'All';

  @override
  String exerciseCountShort(int count) {
    return '$count ex.';
  }

  @override
  String routineSavedToMyRoutines(String name) {
    return 'Routine saved to My Routines: \"$name\"';
  }

  @override
  String get goToRoutines => 'GO TO ROUTINES';

  @override
  String errorCloningRoutine(String error) {
    return 'Error cloning routine: $error';
  }

  @override
  String routineDuplicated(String name) {
    return 'Routine duplicated: \"$name\"';
  }

  @override
  String get metricDuration => 'Duration';

  @override
  String get metricEstCalories => 'Est. Calories';

  @override
  String get metricExercises => 'Exercises';

  @override
  String get sessionExercisesTitle => 'Session Exercises';

  @override
  String get workShort => 'work';

  @override
  String get restShort => 'rest';
}
