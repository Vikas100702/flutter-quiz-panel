// lib/services/result_pdf_service.dart

/*
/// Why we used this file (ResultPdfService):
/// This class is a **Service Layer** responsible solely for generating a professional, printable PDF document of a student's quiz result.
/// It separates the complex PDF generation logic (using the `pdf` package) from the UI layer (`QuizResultScreen`).

/// What it is doing:
/// 1. **PDF Generation:** Constructs the content layout (header, score, stats table) for the result report.
/// 2. **Platform Handling:** Implements separate logic for handling the output file based on the platform:
///    - **Web:** Triggers a browser download using JavaScript (`html.AnchorElement`).
///    - **Mobile:** Saves the file to temporary storage and automatically opens it using `open_file`.
/// 3. **Sharing Preparation:** Converts the generated PDF into an `XFile` format for native sharing functions (`share_plus`).

/// How it is working:
/// It uses immutable inputs (`QuizAttemptState`, `UserModel`, scores) to generate a PDF document in memory (`pw.Document`).
/// It relies on **`kIsWeb`** and conditional imports (`dart:io`, `universal_html`) to execute the correct file handling strategy for the current runtime environment.

/// How it's helpful:
/// It ensures students have a permanent, shareable record (certificate) of their performance, which is a valuable feature for academic transparency and engagement.
*/
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
import 'package:share_plus/share_plus.dart'; // Why we imported: Essential for the native file sharing capability.
import 'package:universal_html/html.dart' as html;

/// Why we used this class: It isolates and manages the entire complexity of PDF generation and file system interactions.
class ResultPdfService {

  // --- 1. DOWNLOAD FUNCTION (For "Download Result" Button) ---
  /// What it is doing: Generates the PDF, saves it to the local device/browser, and opens the file automatically.
  static Future<void> generateAndDownloadResult({
    required QuizAttemptState resultState,
    required UserModel? user,
    required double totalScore,
    required double maxScore,
    required double percentage,
  }) async {
    // What it is doing: Calls the internal method to build the PDF structure.
    final pdf = await _generatePdfDocument(resultState, user, totalScore, maxScore, percentage);
    // How it is working: Saves the in-memory PDF document as raw binary data (`Uint8List`).
    final Uint8List bytes = await pdf.save();

    // What it is doing: Creates a clean filename using the quiz title.
    final String fileName =
        'Result_${resultState.quiz.title.replaceAll(' ', '_')}.pdf';

    if (kIsWeb) {
      // --- WEB DOWNLOAD LOGIC ---
      // How it is working: On web, it uses a Blob to create an object URL.
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      // What it is doing: Creates a temporary HTML anchor element (`<a>`) to trick the browser into starting a download.
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body?.children.add(anchor);
      // How it is working: Programmatically clicks the anchor element to trigger the download.
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url); // How it's helpful: Cleans up the temporary URL resource.
    } else {
      // --- MOBILE SAVE & OPEN LOGIC ---
      // How it is working: Gets the application-specific directory (e.g., Downloads/Documents on mobile).
      final directory = await getApplicationDocumentsDirectory();
      // What it is doing: Creates a file reference in that directory.
      final file = File('${directory.path}/$fileName');
      // What it is doing: Writes the PDF binary data to the file system.
      await file.writeAsBytes(bytes);

      // What it is doing: Attempts to launch the system's default PDF viewer application to open the saved file.
      await OpenFile.open(file.path);
    }
  }

  // --- 2. SHARE FUNCTION (For "Challenge Friends" Button) ---
  /// What it is doing: Generates the PDF file and returns it as an `XFile` object, which is compatible with the `share_plus` package.
  /// How it's helpful: This function handles the temporary file creation/data conversion needed for cross-platform native sharing.
  static Future<XFile> generatePdfXFile({
    required QuizAttemptState resultState,
    required UserModel? user,
    required double totalScore,
    required double maxScore,
    required double percentage,
  }) async {
    // What it is doing: Generates the PDF document object.
    final pdf = await _generatePdfDocument(resultState, user, totalScore, maxScore, percentage);
    final Uint8List bytes = await pdf.save();

    final String fileName = 'Result_${resultState.quiz.title.replaceAll(' ', '_')}.pdf';

    if (kIsWeb) {
      // --- WEB FIX: Use XFile.fromData ---
      // How it is working: On the web, we cannot use file paths, so we directly create the XFile from the binary data in memory.
      return XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: fileName,
      );
    } else {
      // --- MOBILE LOGIC: Save to Temp Dir ---
      // How it is working: For mobile sharing, a temporary path is required by `share_plus`.
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes); // What it is doing: Saves the PDF to a temporary location.

      // What it is doing: Returns an XFile object referencing the temporary path.
      return XFile(file.path, mimeType: 'application/pdf');
    }
  }

  // --- INTERNAL: PDF GENERATION LOGIC ---
  /// What it is doing: Constructs the core printable document structure using the `pdf` package's widgets.
  static Future<pw.Document> _generatePdfDocument(
      QuizAttemptState resultState,
      UserModel? user,
      double totalScore,
      double maxScore,
      double percentage,
      ) async {
    final pdf = pw.Document();

    // How it is working: Asynchronously loads a free Google Font (`Nunito`) for high-quality text rendering in the PDF.
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // How it is working: Applies the loaded font globally to the PDF theme.
        theme: pw.ThemeData.withFont(base: font),
        // What it is doing: Defines the list of sections/widgets that make up the PDF's content.
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

  /// What it is doing: Builds the main title and quiz title for the top of the report.
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

  /// What it is doing: Displays the student's name, email, the current date, and total question count.
  static pw.Widget _buildUserInfo(UserModel? user, QuizAttemptState state) {
    // How it is working: Formats the current time using the `intl` package for a professional look.
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

  /// What it is doing: Highlights the final score, maximum possible score, and percentage.
  static pw.Widget _buildScoreSection(double score, double maxScore, double percentage) {
    // What it is doing: Determines if the result is a Pass (>= 40%) or Fail.
    final bool isPass = percentage >= 40;
    // How it's helpful: Uses color to indicate pass/fail status (green/red background and text).
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

  /// What it is doing: Creates a detailed table breakdown of correct, incorrect, and unanswered questions.
  static pw.Widget _buildStatsTable(QuizAttemptState state) {
    // How it is working: Uses a specialized table helper provided by the `pdf` package for easy row and column creation.
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

  /// What it is doing: Adds a signature line to the bottom of the PDF report.
  static pw.Widget _buildFooter() {
    return pw.Footer(
      leading: pw.Text("Pro Olympiad Quiz Panel"),
      trailing: pw.Text("Generated Automatically"),
    );
  }
}