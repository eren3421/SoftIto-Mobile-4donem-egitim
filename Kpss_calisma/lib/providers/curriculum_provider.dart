import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../core/services/hive_service.dart';
import '../models/topic.dart';

class CurriculumProvider with ChangeNotifier {
  List<Course> _courses = [];
  final Map<String, int> _topicStatuses = {};
  bool _isLoading = true;

  CurriculumProvider() {
    loadCurriculum();
  }

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  Map<String, int> get topicStatuses => _topicStatuses;

  Future<void> loadCurriculum() async {
    _isLoading = true;
    notifyListeners();

    try {
      final jsonString = await rootBundle.loadString(AppConstants.assetTopicsJson);
      final Map<String, dynamic> data = json.decode(jsonString);
      final coursesRaw = data['courses'] as List<dynamic>? ?? [];
      _courses = coursesRaw.map((c) => Course.fromMap(Map<String, dynamic>.from(c as Map))).toList();

      final box = HiveService.topicStatusBox;
      for (final key in box.keys) {
        final val = box.get(key);
        if (val is int) {
          _topicStatuses[key.toString()] = val;
        }
      }
    } catch (e) {
      debugPrint('Error loading curriculum: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getTopicStatus(String topicId) {
    return _topicStatuses[topicId] ?? AppConstants.statusNotStarted;
  }

  Future<void> setTopicStatus(String topicId, int status) async {
    _topicStatuses[topicId] = status;
    await HiveService.topicStatusBox.put(topicId, status);
    notifyListeners();
  }

  int getCourseCompletedTopics(String courseId) {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(
        id: '',
        title: '',
        category: '',
        colorHex: 0,
        iconName: '',
        questionCount: 0,
        topics: [],
      ),
    );
    if (course.topics.isEmpty) return 0;
    return course.topics.where((t) => getTopicStatus(t.id) == AppConstants.statusCompleted).length;
  }

  double getCourseProgress(String courseId) {
    final course = _courses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => Course(
        id: '',
        title: '',
        category: '',
        colorHex: 0,
        iconName: '',
        questionCount: 0,
        topics: [],
      ),
    );
    if (course.topics.isEmpty) return 0.0;
    final completed = getCourseCompletedTopics(courseId);
    return completed / course.topics.length;
  }

  double get overallProgress {
    int totalTopics = 0;
    int completedTopics = 0;

    for (final course in _courses) {
      totalTopics += course.topics.length;
      completedTopics += getCourseCompletedTopics(course.id);
    }

    if (totalTopics == 0) return 0.0;
    return completedTopics / totalTopics;
  }

  int get totalCompletedTopics {
    int count = 0;
    for (final course in _courses) {
      count += getCourseCompletedTopics(course.id);
    }
    return count;
  }

  int get totalTopicsCount {
    int count = 0;
    for (final course in _courses) {
      count += course.topics.length;
    }
    return count;
  }
}
