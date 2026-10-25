import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(AppConstants.settingsBox),
      Hive.openBox(AppConstants.topicStatusBox),
      Hive.openBox(AppConstants.questionLogsBox),
      Hive.openBox(AppConstants.studySessionsBox),
      Hive.openBox(AppConstants.mockExamsBox),
    ]);
  }

  static Box get settingsBox => Hive.box(AppConstants.settingsBox);
  static Box get topicStatusBox => Hive.box(AppConstants.topicStatusBox);
  static Box get questionLogsBox => Hive.box(AppConstants.questionLogsBox);
  static Box get studySessionsBox => Hive.box(AppConstants.studySessionsBox);
  static Box get mockExamsBox => Hive.box(AppConstants.mockExamsBox);
}
