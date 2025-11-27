// lib/services/result_pdf_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:quiz_panel/models/quiz_attempt_state.dart';
import 'package:quiz_panel/models/user_model.dart';
import 'package:share_plus/share_plus.dart'; // Import zaroori hai
import 'package:universal_html/html.dart' as html;

class ResultPdfService {

  // --- 1. DOWNLOAD FUNCTION (For "Download Result" Button) ---
  static Future<void> generateAndDownloadResult({
    required QuizAttemptState resultState,
    required UserModel? user,
    required double totalScore,
    required double maxScore,
    required double percentage,
  }) async {
    final pdf = await _generatePdfDocument(resultState, user, totalScore, maxScore, percentage);
    final Uint8List bytes = await pdf.save();

    final String fileName =
        'Result_${resultState.quiz.title.replaceAll(' ', '_')}.pdf';

    if (kIsWeb) {
      // --- WEB DOWNLOAD LOGIC ---
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      // --- MOBILE SAVE & OPEN LOGIC ---
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      // Auto open the file after saving
      await OpenFile.open(file.path);
    }
  }

  // --- 2. SHARE FUNCTION (For "Challenge Friends" Button) ---
  // Yeh function Web aur Mobile dono par XFile return karega bina crash hue.
  static Future<XFile> generatePdfXFile({
    required QuizAttemptState resultState,
    required UserModel? user,
    required double totalScore,
    required double maxScore,
    required double percentage,
  }) async {
    // PDF create karein
    final pdf = await _generatePdfDocument(resultState, user, totalScore, maxScore, percentage);
    final Uint8List bytes = await pdf.save();

    final String fileName = 'Result_${resultState.quiz.title.replaceAll(' ', '_')}.pdf';

    if (kIsWeb) {
      // --- WEB FIX: Use XFile.fromData ---
      // Web par file system nahi hota, isliye bytes se direct XFile banayenge.
      return XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: fileName,
      );
    } else {
      // --- MOBILE LOGIC: Save to Temp Dir ---
      // Mobile par share karne ke liye file path zaroori hai.
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      return XFile(file.path, mimeType: 'application/pdf');
    }
  }

  // --- INTERNAL: PDF GENERATION LOGIC ---
  static Future<pw.Document> _generatePdfDocument(
      QuizAttemptState resultState,
      UserModel? user,
      double totalScore,
      double maxScore,
      double percentage,
      ) async {
    final pdf = pw.Document();

    // Google Fonts se font load karein taaki text sundar dikhe
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        build: (pw.Context context) {
          return [
            _buildHeader(resultState.quiz.title),
            pw.SizedBox(height: 20),
            _buildUserInfo(user, resultState),
            pw.SizedBox(height: 20),
            _buildScoreSection(totalScore, maxScore, percentage),
            pw.SizedBox(height: 20),
            _buildStatsTable(resultState),
            pw.SizedBox(height: 30),
            _buildFooter(),
          ];
        },
      ),
    );
    return pdf;
  }

  // --- PDF WIDGETS ---

  static pw.Widget _buildHeader(String quizTitle) {
    return pw.Header(
        level: 0,
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text("QUIZ RESULT REPORT", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text(quizTitle, style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
            ]
        )
    );
  }

  static pw.Widget _buildUserInfo(UserModel? user, QuizAttemptState state) {
    final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    return pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400), borderRadius: pw.BorderRadius.circular(8)),
        padding: const pw.EdgeInsets.all(10),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text("Student Name: ${user?.displayName ?? 'Guest'}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("Email: ${user?.email ?? 'N/A'}"),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                pw.Text("Date: $date"),
                pw.Text("Total Questions: ${state.questions.length}"),
              ]),
            ]
        )
    );
  }

  static pw.Widget _buildScoreSection(double score, double maxScore, double percentage) {
    final bool isPass = percentage >= 40;
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      color: isPass ? PdfColors.green50 : PdfColors.red50,
      child: pw.Column(
        children: [
          pw.Text(isPass ? "CONGRATULATIONS!" : "BETTER LUCK NEXT TIME", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: isPass ? PdfColors.green800 : PdfColors.red800)),
          pw.SizedBox(height: 10),
          pw.Text("${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)}", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
          pw.Text("Percentage: ${percentage.toStringAsFixed(2)}%"),
        ],
      ),
    );
  }

  static pw.Widget _buildStatsTable(QuizAttemptState state) {
    return pw.TableHelper.fromTextArray(
      headers: ['Metric', 'Count', 'Status'],
      data: [
        ['Correct Answers', '${state.totalCorrect}', 'Excellent'],
        ['Incorrect Answers', '${state.totalIncorrect}', 'Needs Improvement'],
        ['Unanswered', '${state.totalUnanswered}', '-'],
      ],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue600),
      cellAlignment: pw.Alignment.centerLeft,
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Footer(
      leading: pw.Text("Pro Olympiad Quiz Panel"),
      trailing: pw.Text("Generated Automatically"),
    );
  }
}