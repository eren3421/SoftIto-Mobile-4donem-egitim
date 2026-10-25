import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/question_provider.dart';
import '../../providers/timer_provider.dart';
import 'widgets/save_session_dialog.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timerProv = context.watch<TimerProvider>();
    final questionProv = context.watch<QuestionProvider>();
    final theme = Theme.of(context);

    // If pomodoro finished, trigger save prompt automatically
    if (timerProv.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SaveSessionDialog.show(
          context,
          durationMinutes: timerProv.elapsedStudyMinutes,
          sessionType: 'pomodoro',
        );
        timerProv.resetTimer();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Sayacı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // Mode Selector
            SegmentedButton<StudyTimerMode>(
              segments: const [
                ButtonSegment(
                  value: StudyTimerMode.pomodoro,
                  label: Text('Pomodoro (25dk)'),
                  icon: Icon(Icons.alarm),
                ),
                ButtonSegment(
                  value: StudyTimerMode.shortBreak,
                  label: Text('Mola (5dk)'),
                  icon: Icon(Icons.coffee),
                ),
                ButtonSegment(
                  value: StudyTimerMode.stopwatch,
                  label: Text('Kronometre'),
                  icon: Icon(Icons.timer),
                ),
              ],
              selected: {timerProv.mode},
              onSelectionChanged: (set) {
                timerProv.switchMode(set.first);
              },
            ),
            const SizedBox(height: 36),

            // Big Circular Timer Display
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: timerProv.mode == StudyTimerMode.stopwatch
                          ? (timerProv.isRunning ? null : 1.0)
                          : timerProv.progress,
                      strokeWidth: 12,
                      backgroundColor: theme.brightness == Brightness.dark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        timerProv.mode == StudyTimerMode.shortBreak
                            ? AppColors.completed
                            : AppColors.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timerProv.formattedTime,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        timerProv.mode == StudyTimerMode.pomodoro
                            ? (timerProv.isRunning ? 'Odaklanma Zamanı' : 'Pomodoro Hazır')
                            : (timerProv.mode == StudyTimerMode.shortBreak
                                ? 'Dinlenme Zamanı'
                                : 'Serbest Sayaç'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset
                IconButton.filledTonal(
                  onPressed: timerProv.resetTimer,
                  icon: const Icon(Icons.refresh),
                  iconSize: 28,
                  tooltip: 'Sıfırla',
                  style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
                const SizedBox(width: 20),

                // Play / Pause
                ElevatedButton(
                  onPressed: timerProv.isRunning ? timerProv.pauseTimer : timerProv.startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: timerProv.isRunning ? AppColors.wrong : AppColors.primary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(24),
                  ),
                  child: Icon(
                    timerProv.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),

                // Save / Finish
                IconButton.filledTonal(
                  onPressed: () {
                    timerProv.pauseTimer();
                    final mins = timerProv.elapsedStudyMinutes;
                    SaveSessionDialog.show(
                      context,
                      durationMinutes: mins,
                      sessionType: timerProv.mode == StudyTimerMode.stopwatch
                          ? 'stopwatch'
                          : 'pomodoro',
                    );
                  },
                  icon: const Icon(Icons.bookmark_add_outlined),
                  iconSize: 28,
                  tooltip: 'Bitir ve Kaydet',
                  style: IconButton.styleFrom(padding: const EdgeInsets.all(16)),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Today's Study Sessions List
            if (questionProv.sessions.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bugünkü Çalışma Oturumları',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questionProv.sessions.take(4).length,
                itemBuilder: (context, index) {
                  final session = questionProv.sessions[index];
                  final color = AppColors.getCourseColor(session.courseId);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            session.courseId.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        Text(
                          AppDateUtils.formatDuration(session.durationInMinutes),
                          style: TextStyle(fontWeight: FontWeight.w700, color: color),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppDateUtils.formatTime(session.date),
                          style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
