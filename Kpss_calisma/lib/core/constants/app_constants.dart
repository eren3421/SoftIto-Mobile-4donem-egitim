class AppConstants {
  static const String appName = 'KPSS';
  static const String appSubtitle = 'Çalışma Koçu';
  static const String appVersion = '1.0.0';

  // Hive Box Names
  static const String settingsBox = 'settings_box';
  static const String topicStatusBox = 'topic_status_box';
  static const String questionLogsBox = 'question_logs_box';
  static const String studySessionsBox = 'study_sessions_box';
  static const String mockExamsBox = 'mock_exams_box';

  // Settings Keys
  static const String keyDailyGoal = 'dailyGoal';
  static const String keyIsDarkTheme = 'isDark';
  static const String keyFirstRun = 'firstRun';

  // Default values
  static const int defaultDailyGoal = 100;
  static const int defaultPomodoroMinutes = 25;
  static const int defaultShortBreakMinutes = 5;

  // Topic Status Values
  static const int statusNotStarted = 0;
  static const int statusNeedsReview = 1;
  static const int statusCompleted = 2;

  static const String assetTopicsJson = 'assets/kpss_topics.json';
  static const String assetLogo = 'assets/images/kpss_logo.jpg';
  static const String assetIcon = 'assets/icons/app_icon.png';
}
