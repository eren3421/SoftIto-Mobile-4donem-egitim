import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';

class StreakCalendarWidget extends StatefulWidget {
  final List<String> completedDates;
  final Function(String dateStr) onDayToggled;

  const StreakCalendarWidget({
    super.key,
    required this.completedDates,
    required this.onDayToggled,
  });

  @override
  State<StreakCalendarWidget> createState() => _StreakCalendarWidgetState();
}

class _StreakCalendarWidgetState extends State<StreakCalendarWidget> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final Set<String> dateSet = widget.completedDates.toSet();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Takvim (Yapılan Günleri Onayla)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: Text(
                  '${widget.completedDates.length} Gün',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.softPink),
              rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.softPink),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
              weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
              todayDecoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1.5),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final dateStr = HabitDateUtils.formatDate(day);
                final isDone = dateSet.contains(dateStr);
                return _buildCalendarCell(day, isDone);
              },
              todayBuilder: (context, day, focusedDay) {
                final dateStr = HabitDateUtils.formatDate(day);
                final isDone = dateSet.contains(dateStr);
                return _buildCalendarCell(day, isDone, isToday: true);
              },
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              // Gelecek günleri kısıtlayabilir veya işaretletmeyebiliriz
              final now = DateTime.now();
              final todayMidnight = DateTime(now.year, now.month, now.day);
              final selectedMidnight =
                  DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

              if (selectedMidnight.isAfter(todayMidnight)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gelecek bir günü henüz tamamlayamazsınız!'),
                    backgroundColor: AppColors.warning,
                    duration: Duration(seconds: 1),
                  ),
                );
                return;
              }

              final dateStr = HabitDateUtils.formatDate(selectedDay);
              widget.onDayToggled(dateStr);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.primary, 'Tamamlandı'),
              const SizedBox(width: 16),
              _buildLegend(AppColors.surfaceVariant, 'Boş Gün'),
              const SizedBox(width: 16),
              _buildLegend(Colors.transparent, 'Bugün', borderColor: AppColors.accent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day, bool isDone, {bool isToday = false}) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDone ? AppColors.primary : AppColors.surfaceVariant.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: isToday
                ? AppColors.accent
                : (isDone ? AppColors.accent : Colors.transparent),
            width: isToday ? 2 : 1.2,
          ),
          boxShadow: isDone
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: isDone
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isToday ? AppColors.accent : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor ?? color),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
