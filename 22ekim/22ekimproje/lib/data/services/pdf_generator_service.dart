import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

import '../local/hive_storage_service.dart';
import '../models/habit_model.dart';
import '../models/note_model.dart';
import '../models/pdf_report_model.dart';

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

    // Renk paleti (PDF formatı için PdfColor)
    const primaryPink = PdfColor.fromInt(0xFFC2185B);
    const darkBerry = PdfColor.fromInt(0xFF880E4F);
    const vibrantPink = PdfColor.fromInt(0xFFFF4081);
    const softPinkBg = PdfColor.fromInt(0xFFFCE4EC);
    const textGray = PdfColor.fromInt(0xFF555555);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
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
                _buildMetricCard('Aktif Zincir', '$streak Gün', vibrantPink, '🔥 Mevcut Seri'),
                pw.SizedBox(width: 8),
                _buildMetricCard('En Uzun Zincir', '$longestStreak Gün', primaryPink, '🏆 Rekor'),
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

            pw.SizedBox(height: 20),

            // ================= 2. BÖLÜM: ALIŞKANLIK LİSTESİ / PERFORMANS =================
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
            pw.SizedBox(height: 8),

            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: softPinkBg,
                borderRadius: pw.BorderRadius.circular(8),
                border: const pw.Border(
                  left: pw.BorderSide(color: primaryPink, width: 4),
                ),
              ),
              child: pw.Text(
                expertOpinion,
                style: const pw.TextStyle(
                  fontSize: 10,
                  lineSpacing: 3.5,
                  color: PdfColor.fromInt(0xFF333333),
                ),
              ),
            ),

            pw.SizedBox(height: 20),

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

            pw.Spacer(),

            // Alt Bilgi
            pw.Divider(color: const PdfColor.fromInt(0xFFE0E0E0)),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('MENTOR Habit Tracker System',
                    style: const pw.TextStyle(fontSize: 8, color: textGray)),
                pw.Text('Bu rapor Hugging Face AI desteği ile üretilmiştir.',
                    style: const pw.TextStyle(fontSize: 8, color: textGray)),
              ],
            ),
          ];
        },
      ),
    );

    // PDF dosyasını diske kaydet
    final reportsDir = await HiveStorageService.instance.getReportsDirectoryPath();
    final fileName = isGeneral
        ? 'mentor_genel_rapor_$fileDateSuffix.pdf'
        : 'mentor_aliskanlik_${habit.id}_$fileDateSuffix.pdf';

    final file = File('$reportsDir/$fileName');
    final bytes = await pdf.save();
    await file.writeAsBytes(bytes);

    debugPrint('[PdfGeneratorService] PDF başarıyla kaydedildi: ${file.path}');

    // Model nesnesi oluştur ve Hive'a kaydet
    final reportModel = PdfReportModel(
      id: const Uuid().v4(),
      userId: userId,
      habitId: habit?.id,
      habitTitle: habit?.title,
      title: title,
      filePath: file.path,
      expertOpinion: expertOpinion,
      completionRate: weeklyRate,
      createdAt: now,
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
}
