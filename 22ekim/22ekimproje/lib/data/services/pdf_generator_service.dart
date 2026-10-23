import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_utils.dart';
import '../local/hive_storage_service.dart';
import '../models/habit_model.dart';
import '../models/note_model.dart';
import '../models/pdf_report_model.dart';
import 'huggingface_service.dart';

class PdfGeneratorService {
  static final PdfGeneratorService instance = PdfGeneratorService._internal();
  PdfGeneratorService._internal();

  /// PDF Raporu Oluşturur, Dosya Sistemine Kaydeder ve Model Olarak Döner
  Future<PdfReportModel> generateReport({
    required String userId,
    required String username,
    HabitModel? habit, // null ise genel rapor
    List<HabitModel> allHabits = const [],
    required String expertOpinion,
    List<NoteModel> notes = const [],
  }) async {
    final pdf = pw.Document();

    final isGeneral = habit == null;
    final now = DateTime.now();
    final dateFormatted = DateFormat('dd.MM.yyyy HH:mm').format(now);
    final fileDateSuffix = DateFormat('yyyyMMdd_HHmmss').format(now);

    final title = isGeneral
        ? 'Genel Alışkanlık & Gelişim Değerlendirme Raporu'
        : '${habit.title} - Alışkanlık Analiz Raporu';

    // İstatistiklerin hesaplanması
    final int streak = isGeneral
        ? (allHabits.isEmpty
            ? 0
            : (allHabits.map((h) => h.currentStreak).reduce((a, b) => a + b) ~/
                allHabits.length))
        : habit.currentStreak;

    final int longestStreak = isGeneral
        ? (allHabits.isEmpty
            ? 0
            : allHabits
                .map((h) => h.longestStreak)
                .reduce((a, b) => a > b ? a : b))
        : habit.longestStreak;

    final double weeklyRate = isGeneral
        ? (allHabits.isEmpty
            ? 0.0
            : allHabits
                    .map((h) => h.weeklyCompletionRate)
                    .reduce((a, b) => a + b) /
                allHabits.length)
        : habit.weeklyCompletionRate;

    final double monthlyRate = isGeneral
        ? (allHabits.isEmpty
            ? 0.0
            : allHabits
                    .map((h) => h.monthlyCompletionRate)
                    .reduce((a, b) => a + b) /
                allHabits.length)
        : habit.monthlyCompletionRate;

    // Hafta içi vs. Hafta sonu ve Gün Dağılımı Analizi
    final relevantDates = isGeneral
        ? allHabits.expand((h) => h.completedDates).toSet().toList()
        : habit.completedDates;
    final dayPatterns = HabitDateUtils.analyzeDayPatterns(relevantDates);
    final String dayPatternsSummary = dayPatterns['summary'] as String;

    // Renk paleti (PDF formatı için PdfColor)
    const primaryPink = PdfColor.fromInt(0xFFC2185B);
    const darkBerry = PdfColor.fromInt(0xFF880E4F);
    const vibrantPink = PdfColor.fromInt(0xFFFF4081);
    const softPinkBg = PdfColor.fromInt(0xFFFCE4EC);
    const textGray = PdfColor.fromInt(0xFF555555);

    // Font yükleme (Türkçe karakter desteği için Roboto)
    pw.ThemeData? theme;
    try {
      final fontRegular = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();
      final fontItalic = await PdfGoogleFonts.robotoItalic();
      theme = pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
      );
    } catch (e) {
      debugPrint('[PdfGeneratorService] Font yükleme hatası: $e');
    }

    final String cleanExpertOpinion;
    if (expertOpinion.trim().isNotEmpty) {
      cleanExpertOpinion = expertOpinion.trim();
    } else {
      final weeklyPercentStr = (weeklyRate * 100).toStringAsFixed(1);
      final monthlyPercentStr = (monthlyRate * 100).toStringAsFixed(1);
      final notesSummary = notes.isEmpty
          ? 'Dönem içinde girilmiş özel yansıma notu bulunmuyor.'
          : notes.take(4).map((n) => '"${n.content}"').join('; ');

      cleanExpertOpinion = HuggingFaceService.instance.generateLocalExpertEvaluation(
        username: username,
        habitName: isGeneral ? 'Tüm Alışkanlık Portföyü' : habit.title,
        streak: streak,
        longestStreak: longestStreak,
        weeklyPercent: weeklyPercentStr,
        monthlyPercent: monthlyPercentStr,
        notesSummary: notesSummary,
        isCompletedToday: habit?.isCompletedToday ?? false,
        dayPatternsSummary: dayPatternsSummary,
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: theme,
        footer: (pw.Context context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(color: const PdfColor.fromInt(0xFFE0E0E0), thickness: 0.8),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('MENTOR Habit Tracker System',
                      style: const pw.TextStyle(fontSize: 8, color: textGray)),
                  pw.Text(
                    'Sayfa ${context.pageNumber} / ${context.pagesCount} - MENTOR AI Davranış Analizi',
                    style: const pw.TextStyle(fontSize: 8, color: textGray),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            // ================= ÜST BİLGİ BANDI (HEADER) =================
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: pw.BoxDecoration(
                color: darkBerry,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MENTOR',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Alışkanlık Takip & Kişisel Gelişim Raporu',
                        style: const pw.TextStyle(
                          color: PdfColor.fromInt(0xFFF8BBD0),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Kullanıcı: $username',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Tarih: $dateFormatted',
                        style: const pw.TextStyle(
                          color: PdfColor.fromInt(0xFFF8BBD0),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Rapor Başlığı
            pw.Text(
              title,
              style: pw.TextStyle(
                color: darkBerry,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),

            // ================= 1. BÖLÜM: ÖZET METRİK KUTULARI =================
            pw.Row(
              children: [
                _buildMetricCard('Aktif Zincir', '$streak Gün', vibrantPink, 'Mevcut Seri'),
                pw.SizedBox(width: 8),
                _buildMetricCard('En Uzun Zincir', '$longestStreak Gün', primaryPink, 'En Yüksek Rekor'),
                pw.SizedBox(width: 8),
                _buildMetricCard(
                  'Haftalık Başarı',
                  '%${(weeklyRate * 100).toStringAsFixed(0)}',
                  const PdfColor.fromInt(0xFF00E676),
                  'Son 7 Gün',
                ),
                pw.SizedBox(width: 8),
                _buildMetricCard(
                  'Aylık Başarı',
                  '%${(monthlyRate * 100).toStringAsFixed(0)}',
                  const PdfColor.fromInt(0xFF7C4DFF),
                  'Son 30 Gün',
                ),
              ],
            ),

            pw.SizedBox(height: 8),

            // Hafta İçi vs. Hafta Sonu Dağılım Şeridi
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFFAFAFA),
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0E0E0), width: 0.8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Hafta İçi: %${dayPatterns['weekdayPercent']}',
                      style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: darkBerry)),
                  pw.Text('Hafta Sonu: %${dayPatterns['weekendPercent']}',
                      style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: vibrantPink)),
                  pw.Text('En İstikrarlı Gün: ${dayPatterns['bestDayName']}',
                      style: const pw.TextStyle(fontSize: 8, color: textGray)),
                  pw.Text('En Çok Aksayan: ${dayPatterns['worstDayName']}',
                      style: const pw.TextStyle(fontSize: 8, color: textGray)),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // ================= 2. BÖLÜM: SÜTUN GRAFİĞİ (BAŞARI ORANLARI) =================
            pw.Text(
              'Başarı Oranları Dağılımı (Sütun Grafiği)',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: darkBerry,
              ),
            ),
            pw.SizedBox(height: 8),

            _buildBarChart(
              overallWeekly: weeklyRate,
              overallMonthly: monthlyRate,
              habits: allHabits,
              isGeneral: isGeneral,
              specificHabit: habit,
              weeklyColor: vibrantPink,
              monthlyColor: darkBerry,
            ),

            pw.SizedBox(height: 16),

            // ================= 3. BÖLÜM: ALIŞKANLIK LİSTESİ / PERFORMANS =================
            pw.Text(
              isGeneral ? 'Alışkanlık Tamamlama Özeti' : 'Tamamlama Analizi',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: darkBerry,
              ),
            ),
            pw.SizedBox(height: 8),

            if (isGeneral && allHabits.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(
                  color: const PdfColor.fromInt(0xFFE0E0E0),
                  width: 0.8,
                ),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: softPinkBg),
                    children: [
                      _buildTableCell('Alışkanlık Adı', isHeader: true),
                      _buildTableCell('Aktif Zincir', isHeader: true),
                      _buildTableCell('En Uzun Zincir', isHeader: true),
                      _buildTableCell('Haftalık Başarı', isHeader: true),
                      _buildTableCell('Aylık Başarı', isHeader: true),
                    ],
                  ),
                  ...allHabits.map(
                    (h) => pw.TableRow(
                      children: [
                        _buildTableCell(h.title),
                        _buildTableCell('${h.currentStreak} gün'),
                        _buildTableCell('${h.longestStreak} gün'),
                        _buildTableCell('%${(h.weeklyCompletionRate * 100).toStringAsFixed(0)}'),
                        _buildTableCell('%${(h.monthlyCompletionRate * 100).toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF9F9F9),
                  border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0E0E0)),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('Hedeflenen Rutin: ${habit?.title ?? "-"}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                    pw.Text('Toplam Yapılan Gün: ${habit?.completedDates.length ?? 0}',
                        style: const pw.TextStyle(fontSize: 11)),
                    pw.Text(
                        'Hatırlatıcı: ${habit?.reminderTime ?? "Ayarlanmadı"}',
                        style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],

            pw.SizedBox(height: 20),

            // ================= 3. BÖLÜM: AI UZMAN GÖRÜŞÜ =================
            pw.Text(
              'Yapay Zeka Uzman Görüşü ve Davranışsal Analiz',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: darkBerry,
              ),
            ),
            pw.SizedBox(height: 6),

            ..._buildExpertOpinionWidgets(
              expertOpinion: cleanExpertOpinion,
              primaryPink: primaryPink,
              softPinkBg: softPinkBg,
              darkBerry: darkBerry,
            ),

            pw.SizedBox(height: 16),

            // ================= 4. BÖLÜM: KULLANICI NOTLARI =================
            if (notes.isNotEmpty) ...[
              pw.Text(
                'İlgili Dönem Notları (${notes.length})',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: darkBerry,
                ),
              ),
              pw.SizedBox(height: 8),
              ...notes.take(5).map(
                    (note) => pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 6),
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFFF9F9F9),
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: const PdfColor.fromInt(0xFFEEEEEE)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('• ',
                              style: pw.TextStyle(
                                  color: primaryPink, fontWeight: pw.FontWeight.bold)),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                if (note.habitName != null && note.habitName!.isNotEmpty)
                                   pw.Text('[${note.habitName}]',
                                       style: pw.TextStyle(
                                           color: darkBerry,
                                           fontSize: 9,
                                           fontWeight: pw.FontWeight.bold)),
                                 pw.Text(note.content,
                                     style: const pw.TextStyle(fontSize: 9.5)),
                                 pw.Text(
                                   DateFormat('dd.MM.yyyy').format(note.createdAt),
                                   style: const pw.TextStyle(fontSize: 8, color: textGray),
                                 ),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
             ],
          ];
        },
      ),
    );

    final fileName = isGeneral
        ? 'mentor_genel_rapor_$fileDateSuffix.pdf'
        : 'mentor_aliskanlik_${habit.id}_$fileDateSuffix.pdf';

    final bytes = await pdf.save();
    final base64String = base64Encode(bytes);
    String savedFilePath = fileName;

    // Web ortamında yerel dosya sistemi (dart:io File) bulunmadığından doğrudan web URI atanır.
    if (!kIsWeb) {
      try {
        final reportsDir = await HiveStorageService.instance.getReportsDirectoryPath();
        final file = File('$reportsDir/$fileName');
        await file.writeAsBytes(bytes);
        savedFilePath = file.path;
        debugPrint('[PdfGeneratorService] PDF başarıyla diske kaydedildi: ${file.path}');
      } catch (e) {
        debugPrint('[PdfGeneratorService] Dosya kaydetme uyarısı: $e');
      }
    } else {
      savedFilePath = 'web://$fileName';
      debugPrint('[PdfGeneratorService] Web ortamında PDF belleğe ve Hive veritabanına kaydedildi ($fileName)');
    }

    // Model nesnesi oluştur ve Hive'a kaydet
    final reportModel = PdfReportModel(
      id: const Uuid().v4(),
      userId: userId,
      habitId: habit?.id,
      habitTitle: habit?.title,
      title: title,
      filePath: savedFilePath,
      expertOpinion: cleanExpertOpinion,
      completionRate: weeklyRate,
      createdAt: now,
      pdfBase64: base64String,
    );

    await HiveStorageService.instance.saveReport(reportModel);
    return reportModel;
  }

  static pw.Widget _buildMetricCard(
    String label,
    String value,
    PdfColor color,
    String sublabel,
  ) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFFAFAFA),
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0E0E0)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label,
                style: const pw.TextStyle(fontSize: 8.5, color: PdfColor.fromInt(0xFF666666))),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 15,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(sublabel,
                style: const pw.TextStyle(fontSize: 7.5, color: PdfColor.fromInt(0xFF999999))),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 8.5 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? const PdfColor.fromInt(0xFF880E4F) : const PdfColor.fromInt(0xFF333333),
        ),
        textAlign: pw.TextAlign.left,
      ),
    );
  }

  /// Sütun Grafiği (Haftalık & Aylık Başarı Oranları Karşılaştırması)
  static pw.Widget _buildBarChart({
    required double overallWeekly,
    required double overallMonthly,
    required List<HabitModel> habits,
    required bool isGeneral,
    required HabitModel? specificHabit,
    required PdfColor weeklyColor,
    required PdfColor monthlyColor,
  }) {
    final List<Map<String, dynamic>> chartItems = [];

    if (isGeneral) {
      chartItems.add({
        'title': 'Genel',
        'weekly': overallWeekly.clamp(0.0, 1.0),
        'monthly': overallMonthly.clamp(0.0, 1.0),
      });
      for (final h in habits.take(4)) {
        chartItems.add({
          'title': h.title.length > 9 ? '${h.title.substring(0, 8)}..' : h.title,
          'weekly': h.weeklyCompletionRate.clamp(0.0, 1.0),
          'monthly': h.monthlyCompletionRate.clamp(0.0, 1.0),
        });
      }
    } else if (specificHabit != null) {
      chartItems.add({
        'title': specificHabit.title.length > 12
            ? '${specificHabit.title.substring(0, 11)}..'
            : specificHabit.title,
        'weekly': specificHabit.weeklyCompletionRate.clamp(0.0, 1.0),
        'monthly': specificHabit.monthlyCompletionRate.clamp(0.0, 1.0),
      });
      chartItems.add({
        'title': 'Hedef',
        'weekly': 1.0,
        'monthly': 1.0,
      });
    }

    const double chartMaxHeight = 70.0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFAFAFA),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0E0E0), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Haftalık ve Aylık Tamamlama Oranları',
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF880E4F),
                ),
              ),
              pw.Row(
                children: [
                  pw.Container(
                    width: 7,
                    height: 7,
                    decoration: pw.BoxDecoration(
                      color: weeklyColor,
                      borderRadius: pw.BorderRadius.circular(1.5),
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text('Haftalık (%7 Gün)', style: const pw.TextStyle(fontSize: 7.5)),
                  pw.SizedBox(width: 10),
                  pw.Container(
                    width: 7,
                    height: 7,
                    decoration: pw.BoxDecoration(
                      color: monthlyColor,
                      borderRadius: pw.BorderRadius.circular(1.5),
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Text('Aylık (%30 Gün)', style: const pw.TextStyle(fontSize: 7.5)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            height: 95,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  height: 95,
                  width: 26,
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('%100', style: const pw.TextStyle(fontSize: 6.5, color: PdfColor.fromInt(0xFF888888))),
                      pw.Text('%50', style: const pw.TextStyle(fontSize: 6.5, color: PdfColor.fromInt(0xFF888888))),
                      pw.Text('%0', style: const pw.TextStyle(fontSize: 6.5, color: PdfColor.fromInt(0xFF888888))),
                    ],
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  child: pw.Stack(
                    children: [
                      pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Container(height: 0.5, color: const PdfColor.fromInt(0xFFE0E0E0)),
                          pw.Container(height: 0.5, color: const PdfColor.fromInt(0xFFEEEEEE)),
                          pw.Container(height: 0.8, color: const PdfColor.fromInt(0xFFBDBDBD)),
                        ],
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: chartItems.map((item) {
                          final double weeklyVal = item['weekly'] as double;
                          final double monthlyVal = item['monthly'] as double;
                          final double weeklyH = (weeklyVal * chartMaxHeight).clamp(4.0, chartMaxHeight);
                          final double monthlyH = (monthlyVal * chartMaxHeight).clamp(4.0, chartMaxHeight);

                          return pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Column(
                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                    children: [
                                      pw.Text(
                                        '%${(weeklyVal * 100).round()}',
                                        style: pw.TextStyle(
                                          fontSize: 6.5,
                                          fontWeight: pw.FontWeight.bold,
                                          color: weeklyColor,
                                        ),
                                      ),
                                      pw.SizedBox(height: 2),
                                      pw.Container(
                                        width: 14,
                                        height: weeklyH,
                                        decoration: pw.BoxDecoration(
                                          color: weeklyColor,
                                          borderRadius: const pw.BorderRadius.vertical(
                                            top: pw.Radius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(width: 3),
                                  pw.Column(
                                    mainAxisAlignment: pw.MainAxisAlignment.end,
                                    children: [
                                      pw.Text(
                                        '%${(monthlyVal * 100).round()}',
                                        style: pw.TextStyle(
                                          fontSize: 6.5,
                                          fontWeight: pw.FontWeight.bold,
                                          color: monthlyColor,
                                        ),
                                      ),
                                      pw.SizedBox(height: 2),
                                      pw.Container(
                                        width: 14,
                                        height: monthlyH,
                                        decoration: pw.BoxDecoration(
                                          color: monthlyColor,
                                          borderRadius: const pw.BorderRadius.vertical(
                                            top: pw.Radius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                item['title'] as String,
                                style: pw.TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: const PdfColor.fromInt(0xFF444444),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// PDF Raporunu Tarayıcıda veya İşletim Sisteminde Görüntüler / Önizler
  static Future<void> openPdf(PdfReportModel report) async {
    final fileName = '${report.title.replaceAll(RegExp(r'[^\w\s\.-]'), '_')}.pdf';

    // 1. Web ortamında Printing paketi ile doğrudan tarayıcı önizleme ekranını aç
    if (kIsWeb) {
      if (report.pdfBase64 != null && report.pdfBase64!.isNotEmpty) {
        final bytes = base64Decode(report.pdfBase64!);
        await Printing.layoutPdf(
          name: fileName,
          onLayout: (format) async => bytes,
        );
      }
      return;
    }

    // 2. Mobil / Masaüstü ortamında dosya diskte varsa OpenFilex ile aç
    if (report.filePath.isNotEmpty && !report.filePath.startsWith('web://')) {
      final file = File(report.filePath);
      if (await file.exists()) {
        try {
          final result = await OpenFilex.open(report.filePath);
          if (result.type == ResultType.done) return;
        } catch (_) {}
      }
    }

    // 3. Dosya doğrudan açılamadıysa veya base64 mevcutsa Printing ile önizle
    if (report.pdfBase64 != null && report.pdfBase64!.isNotEmpty) {
      final bytes = base64Decode(report.pdfBase64!);
      await Printing.layoutPdf(
        name: fileName,
        onLayout: (format) async => bytes,
      );
    }
  }

  /// PDF Raporunu doğrudan Cihaza / Tarayıcıya İndirir
  static Future<void> downloadPdf(PdfReportModel report) async {
    final fileName = '${report.title.replaceAll(RegExp(r'[^\w\s\.-]'), '_')}.pdf';
    Uint8List? bytes;

    if (report.pdfBase64 != null && report.pdfBase64!.isNotEmpty) {
      bytes = base64Decode(report.pdfBase64!);
    } else if (!kIsWeb && report.filePath.isNotEmpty) {
      final file = File(report.filePath);
      if (await file.exists()) {
        bytes = await file.readAsBytes();
      }
    }

    if (bytes != null) {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    }
  }

  /// AI Uzman Görüşünü Sayfa Bölünmelerine (MultiPage) Uyumlu Paragraf ve Başlıklara Dönüştürür
  static List<pw.Widget> _buildExpertOpinionWidgets({
    required String expertOpinion,
    required PdfColor primaryPink,
    required PdfColor softPinkBg,
    required PdfColor darkBerry,
  }) {
    final List<pw.Widget> widgets = [];
    final sections = expertOpinion.split(RegExp(r'\n{2,}'));

    for (final section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty) continue;

      final lines = trimmed.split('\n');
      final firstLine = lines.first.trim();

      // Başlık tespiti (Örn: "1. Nörolojik...", "2. Güçlü Yönler...", "### Başlık")
      final isNumberedHeading = RegExp(r'^\d+\.').hasMatch(firstLine) ||
          firstLine.startsWith('#') ||
          (firstLine.endsWith(':') && lines.length > 1);

      if (isNumberedHeading) {
        final cleanTitle = firstLine.replaceAll(RegExp(r'^#+\s*'), '').trim();
        widgets.add(
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 8, bottom: 4),
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: softPinkBg,
              border: pw.Border(left: pw.BorderSide(color: primaryPink, width: 3.5)),
            ),
            child: pw.Text(
              cleanTitle,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: darkBerry,
              ),
            ),
          ),
        );

        final remainingLines = lines.sublist(1);
        for (final line in remainingLines) {
          final l = line.trim();
          if (l.isEmpty) continue;
          if (l.startsWith('•') || l.startsWith('-') || l.startsWith('*')) {
            widgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('• ',
                        style: pw.TextStyle(
                            color: primaryPink,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9.5)),
                    pw.Expanded(
                      child: pw.Text(
                        l.replaceFirst(RegExp(r'^[•\-\*]\s*'), ''),
                        style: const pw.TextStyle(
                          fontSize: 9,
                          lineSpacing: 2.2,
                          color: PdfColor.fromInt(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            widgets.add(
              pw.Paragraph(
                text: l,
                style: const pw.TextStyle(
                  fontSize: 9,
                  lineSpacing: 2.4,
                  color: PdfColor.fromInt(0xFF333333),
                ),
                margin: const pw.EdgeInsets.only(bottom: 4),
              ),
            );
          }
        }
      } else {
        widgets.add(
          pw.Paragraph(
            text: trimmed,
            style: const pw.TextStyle(
              fontSize: 9,
              lineSpacing: 2.4,
              color: PdfColor.fromInt(0xFF333333),
            ),
            margin: const pw.EdgeInsets.only(bottom: 4),
          ),
        );
      }
    }

    return widgets;
  }
}
