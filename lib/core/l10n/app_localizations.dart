import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Interval Timer'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your workout assistant'**
  String get appTagline;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageHint.
  ///
  /// In en, this message translates to:
  /// **'Select interface and timer voice language.'**
  String get languageHint;

  /// No description provided for @languageAuto.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageAuto;

  /// No description provided for @languageEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageEs;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @timerPhasePreparation.
  ///
  /// In en, this message translates to:
  /// **'Get Ready'**
  String get timerPhasePreparation;

  /// No description provided for @timerPhaseWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get timerPhaseWork;

  /// No description provided for @timerPhaseRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get timerPhaseRest;

  /// No description provided for @timerPhaseCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session Complete'**
  String get timerPhaseCompleted;

  /// No description provided for @routineTitle.
  ///
  /// In en, this message translates to:
  /// **'My Routine'**
  String get routineTitle;

  /// No description provided for @addInterval.
  ///
  /// In en, this message translates to:
  /// **'Add interval'**
  String get addInterval;

  /// No description provided for @editInterval.
  ///
  /// In en, this message translates to:
  /// **'Edit interval'**
  String get editInterval;

  /// No description provided for @intervalName.
  ///
  /// In en, this message translates to:
  /// **'Interval name'**
  String get intervalName;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'MINUTES'**
  String get minutesLabel;

  /// No description provided for @secondsLabel.
  ///
  /// In en, this message translates to:
  /// **'SECONDS'**
  String get secondsLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get totalLabel;

  /// No description provided for @increaseMinutes.
  ///
  /// In en, this message translates to:
  /// **'Increase minutes'**
  String get increaseMinutes;

  /// No description provided for @decreaseMinutes.
  ///
  /// In en, this message translates to:
  /// **'Decrease minutes'**
  String get decreaseMinutes;

  /// No description provided for @increaseSeconds.
  ///
  /// In en, this message translates to:
  /// **'Increase seconds'**
  String get increaseSeconds;

  /// No description provided for @decreaseSeconds.
  ///
  /// In en, this message translates to:
  /// **'Decrease seconds'**
  String get decreaseSeconds;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startSession;

  /// No description provided for @emptyRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Add at least one interval to start'**
  String get emptyRoutineMessage;

  /// No description provided for @emptyRoutineHint.
  ///
  /// In en, this message translates to:
  /// **'No intervals in routine'**
  String get emptyRoutineHint;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 50 characters'**
  String get nameTooLong;

  /// No description provided for @durationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid duration. Must be between 00:01 and 99:59'**
  String get durationInvalid;

  /// No description provided for @emptyRoutineStart.
  ///
  /// In en, this message translates to:
  /// **'At least one interval is required to start'**
  String get emptyRoutineStart;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @cancelSession.
  ///
  /// In en, this message translates to:
  /// **'Cancel session'**
  String get cancelSession;

  /// No description provided for @exitSession.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitSession;

  /// No description provided for @nextInterval.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextInterval;

  /// No description provided for @lastInterval.
  ///
  /// In en, this message translates to:
  /// **'Last interval'**
  String get lastInterval;

  /// No description provided for @intervalProgress.
  ///
  /// In en, this message translates to:
  /// **'Interval {current} of {total}'**
  String intervalProgress(int current, int total);

  /// No description provided for @remainingLabel.
  ///
  /// In en, this message translates to:
  /// **'REMAINING'**
  String get remainingLabel;

  /// No description provided for @preparation.
  ///
  /// In en, this message translates to:
  /// **'GET READY'**
  String get preparation;

  /// No description provided for @exitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit workout?'**
  String get exitConfirmTitle;

  /// No description provided for @exitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Session progress will be lost.'**
  String get exitConfirmMessage;

  /// No description provided for @exitConfirmContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get exitConfirmContinue;

  /// No description provided for @exitConfirmLeave.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitConfirmLeave;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @prepSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Preparation seconds'**
  String get prepSecondsLabel;

  /// No description provided for @prepSecondsHint.
  ///
  /// In en, this message translates to:
  /// **'Countdown before the first interval (0 = disabled).'**
  String get prepSecondsHint;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @voiceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceSectionTitle;

  /// No description provided for @voiceEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice enabled'**
  String get voiceEnabledLabel;

  /// No description provided for @voiceEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Announcements and spoken countdown. Does not stop timer.'**
  String get voiceEnabledHint;

  /// No description provided for @countdownSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Countdown seconds'**
  String get countdownSecondsLabel;

  /// No description provided for @countdownSecondsHint.
  ///
  /// In en, this message translates to:
  /// **'Speaks the last N seconds of each interval (0 = start announcement only).'**
  String get countdownSecondsHint;

  /// No description provided for @announceIntervalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Announce interval name'**
  String get announceIntervalNameLabel;

  /// No description provided for @announceIntervalNameHint.
  ///
  /// In en, this message translates to:
  /// **'Speaks interval name (or custom prompt) at start.'**
  String get announceIntervalNameHint;

  /// No description provided for @announceTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Announcement text (optional)'**
  String get announceTextLabel;

  /// No description provided for @announceTextHint.
  ///
  /// In en, this message translates to:
  /// **'If empty, interval name will be used.'**
  String get announceTextHint;

  /// No description provided for @announceTextTooLong.
  ///
  /// In en, this message translates to:
  /// **'Announcement text cannot exceed 80 characters'**
  String get announceTextTooLong;

  /// No description provided for @musicDuckingLabel.
  ///
  /// In en, this message translates to:
  /// **'Ducking background music'**
  String get musicDuckingLabel;

  /// No description provided for @musicDuckingHint.
  ///
  /// In en, this message translates to:
  /// **'Lowers external music volume during voice announcements.'**
  String get musicDuckingHint;

  /// No description provided for @vibrationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibrationSectionTitle;

  /// No description provided for @vibrationEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Vibration enabled'**
  String get vibrationEnabledLabel;

  /// No description provided for @vibrationEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback on interval change and countdown. Independent of voice.'**
  String get vibrationEnabledHint;

  /// No description provided for @vibrationOnIntervalStartLabel.
  ///
  /// In en, this message translates to:
  /// **'On interval change'**
  String get vibrationOnIntervalStartLabel;

  /// No description provided for @vibrationOnIntervalStartHint.
  ///
  /// In en, this message translates to:
  /// **'Pulse when starting each interval.'**
  String get vibrationOnIntervalStartHint;

  /// No description provided for @vibrationOnCountdownLabel.
  ///
  /// In en, this message translates to:
  /// **'On countdown'**
  String get vibrationOnCountdownLabel;

  /// No description provided for @vibrationOnCountdownHint.
  ///
  /// In en, this message translates to:
  /// **'Pulses during the last seconds of each interval.'**
  String get vibrationOnCountdownHint;

  /// No description provided for @vibrationCountdownSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Countdown seconds (vibration)'**
  String get vibrationCountdownSecondsLabel;

  /// No description provided for @vibrationCountdownSecondsHint.
  ///
  /// In en, this message translates to:
  /// **'Vibrates during last N seconds (0 = interval change only).'**
  String get vibrationCountdownSecondsHint;

  /// No description provided for @soundSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundSectionTitle;

  /// No description provided for @soundEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound effects enabled'**
  String get soundEnabledLabel;

  /// No description provided for @soundEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Timer beeps and chimes. Independent of voice and vibration.'**
  String get soundEnabledHint;

  /// No description provided for @soundOnWorkStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Work start'**
  String get soundOnWorkStartLabel;

  /// No description provided for @soundOnWorkStartHint.
  ///
  /// In en, this message translates to:
  /// **'Sound when starting work intervals (or non-rest).'**
  String get soundOnWorkStartHint;

  /// No description provided for @soundOnRestStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest start'**
  String get soundOnRestStartLabel;

  /// No description provided for @soundOnRestStartHint.
  ///
  /// In en, this message translates to:
  /// **'Sound when starting rest intervals.'**
  String get soundOnRestStartHint;

  /// No description provided for @soundOnSessionCompleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get soundOnSessionCompleteLabel;

  /// No description provided for @soundOnSessionCompleteHint.
  ///
  /// In en, this message translates to:
  /// **'Sound upon workout completion.'**
  String get soundOnSessionCompleteHint;

  /// No description provided for @soundOnPrepTickLabel.
  ///
  /// In en, this message translates to:
  /// **'Preparation ticks'**
  String get soundOnPrepTickLabel;

  /// No description provided for @soundOnPrepTickHint.
  ///
  /// In en, this message translates to:
  /// **'One tick per second during preparation countdown.'**
  String get soundOnPrepTickHint;

  /// No description provided for @soundOnPhaseWarningLabel.
  ///
  /// In en, this message translates to:
  /// **'Final countdown'**
  String get soundOnPhaseWarningLabel;

  /// No description provided for @soundOnPhaseWarningHint.
  ///
  /// In en, this message translates to:
  /// **'Ticks during the last N seconds of each interval.'**
  String get soundOnPhaseWarningHint;

  /// No description provided for @soundCountdownSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'Countdown seconds (sound)'**
  String get soundCountdownSecondsLabel;

  /// No description provided for @soundCountdownSecondsHint.
  ///
  /// In en, this message translates to:
  /// **'Plays alert in the last N seconds (0 = disabled).'**
  String get soundCountdownSecondsHint;

  /// No description provided for @soundClipLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundClipLabel;

  /// No description provided for @soundChangeClip.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get soundChangeClip;

  /// No description provided for @soundPreviewClip.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get soundPreviewClip;

  /// No description provided for @soundPickClipTitle.
  ///
  /// In en, this message translates to:
  /// **'Select sound'**
  String get soundPickClipTitle;

  /// No description provided for @soundSlotWorkStart.
  ///
  /// In en, this message translates to:
  /// **'Work start'**
  String get soundSlotWorkStart;

  /// No description provided for @soundSlotRestStart.
  ///
  /// In en, this message translates to:
  /// **'Rest start'**
  String get soundSlotRestStart;

  /// No description provided for @soundSlotSessionComplete.
  ///
  /// In en, this message translates to:
  /// **'Session complete'**
  String get soundSlotSessionComplete;

  /// No description provided for @soundSlotPrepTick.
  ///
  /// In en, this message translates to:
  /// **'Preparation tick'**
  String get soundSlotPrepTick;

  /// No description provided for @soundSlotPhaseWarning.
  ///
  /// In en, this message translates to:
  /// **'Countdown alert'**
  String get soundSlotPhaseWarning;

  /// No description provided for @keepScreenOnSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get keepScreenOnSectionTitle;

  /// No description provided for @keepScreenOnEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepScreenOnEnabledLabel;

  /// No description provided for @keepScreenOnEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Prevents screen from sleeping during workout. May consume more battery.'**
  String get keepScreenOnEnabledHint;

  /// No description provided for @sessionLockScreenSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Session controls'**
  String get sessionLockScreenSectionTitle;

  /// No description provided for @sessionLockScreenEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Session notification / lock screen'**
  String get sessionLockScreenEnabledLabel;

  /// No description provided for @sessionLockScreenEnabledHint.
  ///
  /// In en, this message translates to:
  /// **'Shows interval and remaining time with pause/skip controls while training.'**
  String get sessionLockScreenEnabledHint;

  /// No description provided for @sessionLockScreenPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required for background session. Timer keeps working in app.'**
  String get sessionLockScreenPermissionDenied;

  /// No description provided for @sessionLockScreenRetryPermission.
  ///
  /// In en, this message translates to:
  /// **'Retry permission'**
  String get sessionLockScreenRetryPermission;

  /// No description provided for @sessionLockScreenOpenSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get sessionLockScreenOpenSystemSettings;

  /// No description provided for @sessionSurfaceFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get sessionSurfaceFallbackTitle;

  /// No description provided for @sessionSurfaceStatusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get sessionSurfaceStatusRunning;

  /// No description provided for @sessionSurfaceStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get sessionSurfaceStatusPaused;

  /// No description provided for @sessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session completed!'**
  String get sessionCompleted;

  /// No description provided for @sessionCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have completed all intervals in the routine.'**
  String get sessionCompletedMessage;

  /// No description provided for @backToRoutine.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backToRoutine;

  /// No description provided for @sessionSummaryGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get sessionSummaryGreatJob;

  /// No description provided for @sessionSummaryTraining.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get sessionSummaryTraining;

  /// No description provided for @sessionSummaryRest.
  ///
  /// In en, this message translates to:
  /// **'Total rest'**
  String get sessionSummaryRest;

  /// No description provided for @sessionSummarySharePrompt.
  ///
  /// In en, this message translates to:
  /// **'Share your results with style!'**
  String get sessionSummarySharePrompt;

  /// No description provided for @sessionSummarySharePromptDetail.
  ///
  /// In en, this message translates to:
  /// **'Choose a template, add a photo, and share or save to gallery.'**
  String get sessionSummarySharePromptDetail;

  /// No description provided for @sessionSummaryShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sessionSummaryShare;

  /// No description provided for @sessionSummarySharing.
  ///
  /// In en, this message translates to:
  /// **'Sharing…'**
  String get sessionSummarySharing;

  /// No description provided for @sessionSummaryShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not generate or share image. Try again.'**
  String get sessionSummaryShareFailed;

  /// No description provided for @sessionSummaryNotePrompt.
  ///
  /// In en, this message translates to:
  /// **'How was your workout?'**
  String get sessionSummaryNotePrompt;

  /// No description provided for @sessionSummaryNoteUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Note will be available in a moment. You can also add it in History.'**
  String get sessionSummaryNoteUnavailable;

  /// No description provided for @sessionSummaryNoteSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save note. Retry or exit without saving.'**
  String get sessionSummaryNoteSaveFailed;

  /// No description provided for @sessionSummaryDoneAnyway.
  ///
  /// In en, this message translates to:
  /// **'Exit without note'**
  String get sessionSummaryDoneAnyway;

  /// No description provided for @sessionSummaryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sessionSummaryDone;

  /// No description provided for @sessionSummaryFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get sessionSummaryFallbackName;

  /// No description provided for @sessionSummaryShareDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sessionSummaryShareDuration;

  /// No description provided for @sessionSummaryShareKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal (est.)'**
  String get sessionSummaryShareKcal;

  /// No description provided for @sessionSummaryShareStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak (days)'**
  String get sessionSummaryShareStreak;

  /// No description provided for @sessionSummaryShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get sessionSummaryShareTitle;

  /// No description provided for @sessionSummaryShareAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get sessionSummaryShareAddPhoto;

  /// No description provided for @sessionSummaryShareTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get sessionSummaryShareTakePhoto;

  /// No description provided for @sessionSummarySharePickGallery.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get sessionSummarySharePickGallery;

  /// No description provided for @sessionSummarySharePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve photo. Check permissions and try again.'**
  String get sessionSummarySharePhotoFailed;

  /// No description provided for @sessionSummaryShareSaveGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get sessionSummaryShareSaveGallery;

  /// No description provided for @sessionSummaryShareSavedGallery.
  ///
  /// In en, this message translates to:
  /// **'Image saved to gallery'**
  String get sessionSummaryShareSavedGallery;

  /// No description provided for @sessionSummaryShareSaveGalleryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save to gallery. Check permissions.'**
  String get sessionSummaryShareSaveGalleryFailed;

  /// No description provided for @sessionSummaryShareOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Templates and photos work offline'**
  String get sessionSummaryShareOfflineHint;

  /// No description provided for @sessionSummaryShareWorkoutBadge.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get sessionSummaryShareWorkoutBadge;

  /// No description provided for @sessionSummaryShareSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sessionSummaryShareSets;

  /// No description provided for @sessionSummaryShareWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get sessionSummaryShareWork;

  /// No description provided for @sessionSummaryShareRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get sessionSummaryShareRest;

  /// No description provided for @sessionSummarySheetHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe up for more details'**
  String get sessionSummarySheetHint;

  /// No description provided for @sessionSummaryNewAchievementsOne.
  ///
  /// In en, this message translates to:
  /// **'1 new achievement!'**
  String get sessionSummaryNewAchievementsOne;

  /// No description provided for @sessionSummaryNewAchievementsMany.
  ///
  /// In en, this message translates to:
  /// **'{count} new achievements!'**
  String sessionSummaryNewAchievementsMany(int count);

  /// No description provided for @sessionSummaryViewAchievements.
  ///
  /// In en, this message translates to:
  /// **'View achievements'**
  String get sessionSummaryViewAchievements;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @achievementsEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsEntryTitle;

  /// No description provided for @achievementsEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View unlocked badges and progress'**
  String get achievementsEntrySubtitle;

  /// No description provided for @achievementsUnlockedBadge.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementsUnlockedBadge;

  /// No description provided for @achievementsLockedBadge.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get achievementsLockedBadge;

  /// No description provided for @achievementsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load achievements'**
  String get achievementsError;

  /// No description provided for @achievementsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Complete sessions to unlock achievements'**
  String get achievementsEmptyHint;

  /// No description provided for @achievementsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements unlocked!'**
  String get achievementsSheetTitle;

  /// No description provided for @achievementsSheetClose.
  ///
  /// In en, this message translates to:
  /// **'Awesome'**
  String get achievementsSheetClose;

  /// No description provided for @achievementsUnlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked on {date}'**
  String achievementsUnlockedOn(String date);

  /// No description provided for @achievementsProgressSessions.
  ///
  /// In en, this message translates to:
  /// **'{current}/{target} sessions'**
  String achievementsProgressSessions(int current, int target);

  /// No description provided for @achievementsProgressDays.
  ///
  /// In en, this message translates to:
  /// **'{current}/{target} days'**
  String achievementsProgressDays(int current, int target);

  /// No description provided for @achievementsProgressMinutes.
  ///
  /// In en, this message translates to:
  /// **'{current}/{target} min'**
  String achievementsProgressMinutes(int current, int target);

  /// No description provided for @achievementFirstSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'First session'**
  String get achievementFirstSessionTitle;

  /// No description provided for @achievementFirstSessionDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first workout session.'**
  String get achievementFirstSessionDesc;

  /// No description provided for @achievementSessions10Title.
  ///
  /// In en, this message translates to:
  /// **'10 sessions'**
  String get achievementSessions10Title;

  /// No description provided for @achievementSessions10Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 total sessions.'**
  String get achievementSessions10Desc;

  /// No description provided for @achievementSessions25Title.
  ///
  /// In en, this message translates to:
  /// **'25 sessions'**
  String get achievementSessions25Title;

  /// No description provided for @achievementSessions25Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 25 total sessions.'**
  String get achievementSessions25Desc;

  /// No description provided for @achievementSessions50Title.
  ///
  /// In en, this message translates to:
  /// **'50 sessions'**
  String get achievementSessions50Title;

  /// No description provided for @achievementSessions50Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 50 total sessions.'**
  String get achievementSessions50Desc;

  /// No description provided for @achievementSessions100Title.
  ///
  /// In en, this message translates to:
  /// **'100 sessions'**
  String get achievementSessions100Title;

  /// No description provided for @achievementSessions100Desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 total sessions.'**
  String get achievementSessions100Desc;

  /// No description provided for @achievementStreak3Title.
  ///
  /// In en, this message translates to:
  /// **'3-day streak'**
  String get achievementStreak3Title;

  /// No description provided for @achievementStreak3Desc.
  ///
  /// In en, this message translates to:
  /// **'Work out at least one day for 3 days in a row.'**
  String get achievementStreak3Desc;

  /// No description provided for @achievementStreak7Title.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get achievementStreak7Title;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In en, this message translates to:
  /// **'Work out at least one day for 7 days in a row.'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementStreak14Title.
  ///
  /// In en, this message translates to:
  /// **'14-day streak'**
  String get achievementStreak14Title;

  /// No description provided for @achievementStreak14Desc.
  ///
  /// In en, this message translates to:
  /// **'Work out at least one day for 14 days in a row.'**
  String get achievementStreak14Desc;

  /// No description provided for @achievementStreak30Title.
  ///
  /// In en, this message translates to:
  /// **'30-day streak'**
  String get achievementStreak30Title;

  /// No description provided for @achievementStreak30Desc.
  ///
  /// In en, this message translates to:
  /// **'Work out at least one day for 30 days in a row.'**
  String get achievementStreak30Desc;

  /// No description provided for @achievementMinutes60Title.
  ///
  /// In en, this message translates to:
  /// **'60 minutes'**
  String get achievementMinutes60Title;

  /// No description provided for @achievementMinutes60Desc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 60 minutes of completed sessions.'**
  String get achievementMinutes60Desc;

  /// No description provided for @achievementMinutes300Title.
  ///
  /// In en, this message translates to:
  /// **'300 minutes'**
  String get achievementMinutes300Title;

  /// No description provided for @achievementMinutes300Desc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 300 minutes of completed sessions.'**
  String get achievementMinutes300Desc;

  /// No description provided for @achievementMinutes1000Title.
  ///
  /// In en, this message translates to:
  /// **'1000 minutes'**
  String get achievementMinutes1000Title;

  /// No description provided for @achievementMinutes1000Desc.
  ///
  /// In en, this message translates to:
  /// **'Accumulate 1000 minutes of completed sessions.'**
  String get achievementMinutes1000Desc;

  /// No description provided for @persistenceError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get persistenceError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @workoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Workouts'**
  String get workoutsTitle;

  /// No description provided for @navRoutine.
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get navRoutine;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyWorkoutsSection.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get historyWorkoutsSection;

  /// No description provided for @historyEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'No workouts this day'**
  String get historyEmptyDay;

  /// No description provided for @historyAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get historyAddNote;

  /// No description provided for @historyEditNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout note'**
  String get historyEditNoteTitle;

  /// No description provided for @historyNoteTooLong.
  ///
  /// In en, this message translates to:
  /// **'Note cannot exceed 500 characters'**
  String get historyNoteTooLong;

  /// No description provided for @historyStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get historyStart;

  /// No description provided for @historyDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete from history'**
  String get historyDelete;

  /// No description provided for @historyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete from history?'**
  String get historyDeleteTitle;

  /// No description provided for @historyDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. The record of this session will be deleted.'**
  String get historyDeleteMessage;

  /// No description provided for @historySourceMissing.
  ///
  /// In en, this message translates to:
  /// **'Original routine or workout was not found.'**
  String get historySourceMissing;

  /// No description provided for @historyGoToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get historyGoToToday;

  /// No description provided for @historySelectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get historySelectMonth;

  /// No description provided for @historyExerciseCount.
  ///
  /// In en, this message translates to:
  /// **'Exercises: {count}'**
  String historyExerciseCount(int count);

  /// No description provided for @historyFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout at {time}'**
  String historyFallbackTitle(String time);

  /// No description provided for @progressSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get progressSectionTitle;

  /// No description provided for @progressStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get progressStreakLabel;

  /// No description provided for @progressWeekMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes this week'**
  String get progressWeekMinutesLabel;

  /// No description provided for @progressMonthSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sessions this month'**
  String get progressMonthSessionsLabel;

  /// No description provided for @progressKcalLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated calories'**
  String get progressKcalLabel;

  /// No description provided for @progressChartWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get progressChartWeek;

  /// No description provided for @progressChartMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get progressChartMonth;

  /// No description provided for @progressChartCaption.
  ///
  /// In en, this message translates to:
  /// **'Minutes per day'**
  String get progressChartCaption;

  /// No description provided for @progressStatsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load statistics'**
  String get progressStatsError;

  /// No description provided for @progressWeightEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated weight {kg} kg'**
  String progressWeightEstimated(String kg);

  /// No description provided for @progressWeightRegistered.
  ///
  /// In en, this message translates to:
  /// **'Weight {kg} kg'**
  String progressWeightRegistered(String kg);

  /// No description provided for @progressKcalMethodCaption.
  ///
  /// In en, this message translates to:
  /// **'Estimated kcal: MET {met} × weight × duration. Not a direct measurement.'**
  String progressKcalMethodCaption(String met);

  /// No description provided for @progressKcalInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'How calories are estimated'**
  String get progressKcalInfoTooltip;

  /// No description provided for @progressKcalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated calories'**
  String get progressKcalInfoTitle;

  /// No description provided for @progressKcalInfoBody.
  ///
  /// In en, this message translates to:
  /// **'We estimate energy using the standard formula MET × weight (kg) × session hours (practical definition from Compendium of Physical Activities).\n\nWe use MET {met} as reference for vigorous interval activity. This is a generic population estimate, not a metabolic measurement.\n\nIt serves as a guideline and trend indicator, not clinical data.'**
  String progressKcalInfoBody(String met);

  /// No description provided for @progressKcalInfoClose.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get progressKcalInfoClose;

  /// No description provided for @progressTotalLine.
  ///
  /// In en, this message translates to:
  /// **'Total: {totals} · {sessions} sessions'**
  String progressTotalLine(String totals, int sessions);

  /// No description provided for @progressDaysSuffix.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get progressDaysSuffix;

  /// No description provided for @bodyWeightSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weight'**
  String get bodyWeightSectionTitle;

  /// No description provided for @bodyWeightRegisterCta.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get bodyWeightRegisterCta;

  /// No description provided for @bodyWeightUpdateCta.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get bodyWeightUpdateCta;

  /// No description provided for @bodyWeightRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Log weight'**
  String get bodyWeightRegisterButton;

  /// No description provided for @bodyWeightEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Log your weight to track progress'**
  String get bodyWeightEmptyMessage;

  /// No description provided for @bodyWeightCaptionEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated weight {value} {unit} · Log'**
  String bodyWeightCaptionEstimated(String value, String unit);

  /// No description provided for @bodyWeightCaptionRegistered.
  ///
  /// In en, this message translates to:
  /// **'{value} {valueUnit} · Update'**
  String bodyWeightCaptionRegistered(String value, String valueUnit);

  /// No description provided for @bodyWeightFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Log weight'**
  String get bodyWeightFormTitle;

  /// No description provided for @bodyWeightFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit weight'**
  String get bodyWeightFormEditTitle;

  /// No description provided for @bodyWeightFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get bodyWeightFieldLabel;

  /// No description provided for @bodyWeightDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bodyWeightDateLabel;

  /// No description provided for @bodyWeightMeasuresOptional.
  ///
  /// In en, this message translates to:
  /// **'Body measurements (optional)'**
  String get bodyWeightMeasuresOptional;

  /// No description provided for @bodyWeightWaistLabel.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm)'**
  String get bodyWeightWaistLabel;

  /// No description provided for @bodyWeightArmLabel.
  ///
  /// In en, this message translates to:
  /// **'Arm (cm)'**
  String get bodyWeightArmLabel;

  /// No description provided for @bodyWeightLegLabel.
  ///
  /// In en, this message translates to:
  /// **'Leg (cm)'**
  String get bodyWeightLegLabel;

  /// No description provided for @bodyWeightUnitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get bodyWeightUnitKg;

  /// No description provided for @bodyWeightUnitLb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get bodyWeightUnitLb;

  /// No description provided for @bodyWeightUnitsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get bodyWeightUnitsSectionTitle;

  /// No description provided for @bodyWeightUnitPreferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get bodyWeightUnitPreferenceLabel;

  /// No description provided for @bodyWeightRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get bodyWeightRecentTitle;

  /// No description provided for @bodyWeightViewRecords.
  ///
  /// In en, this message translates to:
  /// **'View records'**
  String get bodyWeightViewRecords;

  /// No description provided for @bodyWeightViewRecordsCount.
  ///
  /// In en, this message translates to:
  /// **'View records ({count})'**
  String bodyWeightViewRecordsCount(int count);

  /// No description provided for @bodyWeightHistorySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight history'**
  String get bodyWeightHistorySheetTitle;

  /// No description provided for @bodyWeightLastLine.
  ///
  /// In en, this message translates to:
  /// **'Last: {value} {unit} · {date}'**
  String bodyWeightLastLine(String value, String unit, String date);

  /// No description provided for @bodyWeightDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete entry?'**
  String get bodyWeightDeleteTitle;

  /// No description provided for @bodyWeightDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This weight entry will be deleted. This action cannot be undone.'**
  String get bodyWeightDeleteMessage;

  /// No description provided for @bodyWeightSaved.
  ///
  /// In en, this message translates to:
  /// **'Weight saved'**
  String get bodyWeightSaved;

  /// No description provided for @bodyWeightDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get bodyWeightDeleted;

  /// No description provided for @bodyWeightErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Could not load weight'**
  String get bodyWeightErrorRetry;

  /// No description provided for @bodyWeightValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight'**
  String get bodyWeightValidationRequired;

  /// No description provided for @bodyWeightValidationRange.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 20 and 300 kg'**
  String get bodyWeightValidationRange;

  /// No description provided for @bodyWeightValidationMeasure.
  ///
  /// In en, this message translates to:
  /// **'Measurement must be greater than 0 and at most 300 cm'**
  String get bodyWeightValidationMeasure;

  /// No description provided for @bodyWeightValidationDateFuture.
  ///
  /// In en, this message translates to:
  /// **'Future dates are not allowed'**
  String get bodyWeightValidationDateFuture;

  /// No description provided for @bodyWeightValidationDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get bodyWeightValidationDateInvalid;

  /// No description provided for @bodyWeightChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'No weight data'**
  String get bodyWeightChartEmpty;

  /// No description provided for @createWorkout.
  ///
  /// In en, this message translates to:
  /// **'Create workout'**
  String get createWorkout;

  /// No description provided for @workoutName.
  ///
  /// In en, this message translates to:
  /// **'Workout name'**
  String get workoutName;

  /// No description provided for @workoutNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name cannot exceed 80 characters'**
  String get workoutNameTooLong;

  /// No description provided for @emptyWorkoutsHint.
  ///
  /// In en, this message translates to:
  /// **'No saved workouts'**
  String get emptyWorkoutsHint;

  /// No description provided for @editWorkout.
  ///
  /// In en, this message translates to:
  /// **'Edit workout'**
  String get editWorkout;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExercise;

  /// No description provided for @editExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get editExercise;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise name'**
  String get exerciseName;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @workDuration.
  ///
  /// In en, this message translates to:
  /// **'Work duration'**
  String get workDuration;

  /// No description provided for @restDuration.
  ///
  /// In en, this message translates to:
  /// **'Rest duration'**
  String get restDuration;

  /// No description provided for @restBetweenSetsDuration.
  ///
  /// In en, this message translates to:
  /// **'Rest between sets'**
  String get restBetweenSetsDuration;

  /// No description provided for @restAfterExerciseDuration.
  ///
  /// In en, this message translates to:
  /// **'Final rest'**
  String get restAfterExerciseDuration;

  /// No description provided for @setsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Sets must be between 1 and 99'**
  String get setsInvalid;

  /// No description provided for @restDurationInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid duration. Must be between 00:00 and 99:59'**
  String get restDurationInvalid;

  /// No description provided for @restAfterExerciseInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid duration. Must be between 00:00 and 99:59'**
  String get restAfterExerciseInvalid;

  /// No description provided for @train.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get train;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get deleteWorkoutTitle;

  /// No description provided for @deleteWorkoutMessage.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Delete this workout?'**
  String get deleteWorkoutMessage;

  /// No description provided for @emptyWorkoutStart.
  ///
  /// In en, this message translates to:
  /// **'At least one exercise is required to start'**
  String get emptyWorkoutStart;

  /// No description provided for @deleteBlockedDuringSession.
  ///
  /// In en, this message translates to:
  /// **'Finish or cancel session before deleting a workout'**
  String get deleteBlockedDuringSession;

  /// No description provided for @exerciseCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exerciseCountLabel(int count);

  /// No description provided for @workoutRoundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout rounds'**
  String get workoutRoundsTitle;

  /// No description provided for @workoutRoundsShort.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get workoutRoundsShort;

  /// No description provided for @workoutRoundsHelper.
  ///
  /// In en, this message translates to:
  /// **'The entire exercise block repeats N times'**
  String get workoutRoundsHelper;

  /// No description provided for @workoutRoundsBlockChip.
  ///
  /// In en, this message translates to:
  /// **'Entire block × {count}'**
  String workoutRoundsBlockChip(int count);

  /// No description provided for @workoutRoundsListLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} rounds'**
  String workoutRoundsListLabel(int count);

  /// No description provided for @workoutRoundProgress.
  ///
  /// In en, this message translates to:
  /// **'Round {current} of {total}'**
  String workoutRoundProgress(int current, int total);

  /// No description provided for @workoutRoundsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Rounds must be between 1 and 99'**
  String get workoutRoundsInvalid;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesFilterChip.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesFilterChip;

  /// No description provided for @markAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get markAsFavorite;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @emptyFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'No favorite routines yet'**
  String get emptyFavoritesHint;

  /// No description provided for @featuredRoutines.
  ///
  /// In en, this message translates to:
  /// **'Featured Routines'**
  String get featuredRoutines;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @myRoutines.
  ///
  /// In en, this message translates to:
  /// **'My Routines'**
  String get myRoutines;

  /// No description provided for @noFavoriteWorkouts.
  ///
  /// In en, this message translates to:
  /// **'No favorite workouts'**
  String get noFavoriteWorkouts;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @presetRoutinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preset Routines'**
  String get presetRoutinesTitle;

  /// No description provided for @featuredToday.
  ///
  /// In en, this message translates to:
  /// **'Featured Today'**
  String get featuredToday;

  /// No description provided for @allRoutines.
  ///
  /// In en, this message translates to:
  /// **'All Routines'**
  String get allRoutines;

  /// No description provided for @noFavoritePresets.
  ///
  /// In en, this message translates to:
  /// **'No favorite preset routines.'**
  String get noFavoritePresets;

  /// No description provided for @noCategoryPresets.
  ///
  /// In en, this message translates to:
  /// **'No routines available for this category.'**
  String get noCategoryPresets;

  /// No description provided for @presetDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine Details'**
  String get presetDetailTitle;

  /// No description provided for @duplicateToMyRoutines.
  ///
  /// In en, this message translates to:
  /// **'Duplicate to My Routines'**
  String get duplicateToMyRoutines;

  /// No description provided for @routineNotFound.
  ///
  /// In en, this message translates to:
  /// **'Routine not found.'**
  String get routineNotFound;

  /// No description provided for @startWorkout.
  ///
  /// In en, this message translates to:
  /// **'START WORKOUT'**
  String get startWorkout;

  /// No description provided for @stepByStepTechnique.
  ///
  /// In en, this message translates to:
  /// **'Step-by-Step Technique'**
  String get stepByStepTechnique;

  /// No description provided for @postureTips.
  ///
  /// In en, this message translates to:
  /// **'Posture Advice & Tips'**
  String get postureTips;

  /// No description provided for @followTimerRhythm.
  ///
  /// In en, this message translates to:
  /// **'Follow the timer rhythm.'**
  String get followTimerRhythm;

  /// No description provided for @exerciseSetsChip.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String exerciseSetsChip(int count);

  /// No description provided for @exerciseRestBetween.
  ///
  /// In en, this message translates to:
  /// **'rest {time}'**
  String exerciseRestBetween(String time);

  /// No description provided for @exerciseRestFinal.
  ///
  /// In en, this message translates to:
  /// **'final {time}'**
  String exerciseRestFinal(String time);

  /// No description provided for @presetRoutineBadge.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get presetRoutineBadge;

  /// No description provided for @customRoutineBadge.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customRoutineBadge;

  /// No description provided for @noCategoryFavoritePresets.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have favorite routines in this category.'**
  String get noCategoryFavoritePresets;

  /// No description provided for @errorLoadingPresetCatalog.
  ///
  /// In en, this message translates to:
  /// **'Error loading routine catalog.'**
  String get errorLoadingPresetCatalog;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @exerciseCountShort.
  ///
  /// In en, this message translates to:
  /// **'{count} ex.'**
  String exerciseCountShort(int count);

  /// No description provided for @routineSavedToMyRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routine saved to My Routines: \"{name}\"'**
  String routineSavedToMyRoutines(String name);

  /// No description provided for @goToRoutines.
  ///
  /// In en, this message translates to:
  /// **'GO TO ROUTINES'**
  String get goToRoutines;

  /// No description provided for @errorCloningRoutine.
  ///
  /// In en, this message translates to:
  /// **'Error cloning routine: {error}'**
  String errorCloningRoutine(String error);

  /// No description provided for @routineDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Routine duplicated: \"{name}\"'**
  String routineDuplicated(String name);

  /// No description provided for @metricDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get metricDuration;

  /// No description provided for @metricEstCalories.
  ///
  /// In en, this message translates to:
  /// **'Est. Calories'**
  String get metricEstCalories;

  /// No description provided for @metricExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get metricExercises;

  /// No description provided for @sessionExercisesTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Exercises'**
  String get sessionExercisesTitle;

  /// No description provided for @workShort.
  ///
  /// In en, this message translates to:
  /// **'work'**
  String get workShort;

  /// No description provided for @restShort.
  ///
  /// In en, this message translates to:
  /// **'rest'**
  String get restShort;

  /// No description provided for @quickAudioSettings.
  ///
  /// In en, this message translates to:
  /// **'Sound & vibration'**
  String get quickAudioSettings;

  /// No description provided for @quickAudioSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sound and vibration settings'**
  String get quickAudioSettingsTooltip;

  /// No description provided for @voiceAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Voice announcements'**
  String get voiceAnnouncements;

  /// No description provided for @voiceAnnouncementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Interval names and countdown'**
  String get voiceAnnouncementsDesc;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Timer sounds'**
  String get soundEffects;

  /// No description provided for @soundEffectsDesc.
  ///
  /// In en, this message translates to:
  /// **'Countdown beeps and phase transitions'**
  String get soundEffectsDesc;

  /// No description provided for @vibrationFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get vibrationFeedback;

  /// No description provided for @vibrationFeedbackDesc.
  ///
  /// In en, this message translates to:
  /// **'Vibration on interval changes'**
  String get vibrationFeedbackDesc;

  /// No description provided for @muteAll.
  ///
  /// In en, this message translates to:
  /// **'Mute all'**
  String get muteAll;

  /// No description provided for @unmuteAll.
  ///
  /// In en, this message translates to:
  /// **'Unmute all'**
  String get unmuteAll;

  /// No description provided for @timerColorsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Timer colors'**
  String get timerColorsSectionTitle;

  /// No description provided for @workColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Work color'**
  String get workColorTitle;

  /// No description provided for @workColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Screen color during active intervals'**
  String get workColorSubtitle;

  /// No description provided for @restColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Rest color'**
  String get restColorTitle;

  /// No description provided for @restColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Screen color during rest intervals'**
  String get restColorSubtitle;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @saveColor.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveColor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
