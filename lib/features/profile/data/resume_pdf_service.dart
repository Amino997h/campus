import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_model.dart';

class ResumePdfService {
  static String _formatDateString(String dateStr) {
    if (dateStr.trim().isEmpty) return '';
    final parts = dateStr.trim().split('-');
    if (parts.length != 2) return dateStr;
    final year = parts[0];
    final monthInt = int.tryParse(parts[1]) ?? 0;
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (monthInt >= 1 && monthInt <= 12) {
      return '${months[monthInt]} $year';
    }
    return dateStr;
  }

  static Future<Uint8List> generateResumePdf(ResumeModel resume) async {
    final pdf = pw.Document();

    final contactItems = <String>[];
    if (resume.location.isNotEmpty) contactItems.add(resume.location);
    if (resume.phone.isNotEmpty) contactItems.add(resume.phone);
    if (resume.email.isNotEmpty) contactItems.add(resume.email);
    if (resume.linkedin.isNotEmpty) contactItems.add(resume.linkedin);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        build: (pw.Context context) {
          return [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    resume.fullName.isNotEmpty ? resume.fullName : 'FIRSTNAME LASTNAME',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                    ),
                  ),
                  if (resume.jobTitle.isNotEmpty) ...[
                    pw.SizedBox(height: 5),
                    pw.Text(
                      resume.jobTitle,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey900,
                      ),
                    ),
                  ],
                  if (contactItems.isNotEmpty) ...[
                    pw.SizedBox(height: 8),
                    pw.Text(
                      contactItems.join('  |  '),
                      style: const pw.TextStyle(
                        fontSize: 9.5,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 12),
                  pw.Divider(thickness: 2, color: PdfColors.grey900),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // Summary
            if (resume.summary.isNotEmpty) ...[
              _buildPdfHeader('PROFESSIONAL SUMMARY'),
              pw.SizedBox(height: 6),
              pw.Text(
                resume.summary,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 14),
            ],

            // Work Experience
            if (resume.experiences.isNotEmpty) ...[
              _buildPdfHeader('WORK EXPERIENCE'),
              pw.SizedBox(height: 6),
              ...resume.experiences.map((exp) {
                final start = _formatDateString(exp.startDate);
                final end = exp.current ? 'Present' : _formatDateString(exp.endDate);
                final dateText = (start.isNotEmpty && end.isNotEmpty)
                    ? '$start – $end'
                    : (start.isNotEmpty ? start : end);

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            exp.jobTitle,
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            dateText,
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                      if (exp.company.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2),
                          child: pw.Text(
                            exp.company,
                            style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                          ),
                        ),
                      if (exp.responsibilities.isNotEmpty) ...[
                        pw.SizedBox(height: 4),
                        ...exp.responsibilities.map((r) => pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                  pw.Expanded(
                                    child: pw.Text(r, style: const pw.TextStyle(fontSize: 9.5)),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 6),
            ],

            // Education
            if (resume.educations.isNotEmpty) ...[
              _buildPdfHeader('EDUCATION'),
              pw.SizedBox(height: 6),
              ...resume.educations.map((edu) {
                var eduTitle = edu.degree;
                if (edu.specialization.isNotEmpty) {
                  eduTitle += eduTitle.isNotEmpty ? ' in ${edu.specialization}' : edu.specialization;
                }

                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            eduTitle,
                            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                          ),
                          if (edu.university.isNotEmpty)
                            pw.Text(
                              edu.university,
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                            ),
                        ],
                      ),
                      if (edu.graduationYear.isNotEmpty)
                        pw.Text(
                          'Graduated: ${edu.graduationYear}',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 6),
            ],

            // Skills
            if (resume.technicalSkills.isNotEmpty || resume.personalSkills.isNotEmpty) ...[
              _buildPdfHeader('SKILLS'),
              pw.SizedBox(height: 6),
              if (resume.technicalSkills.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      style: const pw.TextStyle(fontSize: 10),
                      children: [
                        pw.TextSpan(
                          text: 'Technical Skills: ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.TextSpan(text: resume.technicalSkills.join(', ')),
                      ],
                    ),
                  ),
                ),
              if (resume.personalSkills.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.RichText(
                    text: pw.TextSpan(
                      style: const pw.TextStyle(fontSize: 10),
                      children: [
                        pw.TextSpan(
                          text: 'Personal Skills: ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.TextSpan(text: resume.personalSkills.join(', ')),
                      ],
                    ),
                  ),
                ),
              pw.SizedBox(height: 10),
            ],

            // Languages
            if (resume.languages.isNotEmpty) ...[
              _buildPdfHeader('LANGUAGES'),
              pw.SizedBox(height: 6),
              ...resume.languages.map((l) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 3),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        style: const pw.TextStyle(fontSize: 10),
                        children: [
                          pw.TextSpan(
                            text: l.language,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          if (l.level.isNotEmpty) pw.TextSpan(text: ': ${l.level}'),
                        ],
                      ),
                    ),
                  )),
              pw.SizedBox(height: 10),
            ],

            // Certifications
            if (resume.certificates.isNotEmpty) ...[
              _buildPdfHeader('CERTIFICATIONS'),
              pw.SizedBox(height: 6),
              ...resume.certificates.map((c) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 10, bottom: 3),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Expanded(
                          child: pw.Text(c, style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  )),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey900,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Divider(thickness: 1.5, color: PdfColors.grey900),
      ],
    );
  }

  static Future<void> printOrSavePdf(ResumeModel resume) async {
    final bytes = await generateResumePdf(resume);
    final fileName = '${resume.fullName.isNotEmpty ? resume.fullName.replaceAll(' ', '_') : 'Resume'}_CV.pdf';

    if (kIsWeb) {
      // على متصفح الويب: تنزيل الملف مباشرة بصيغة PDF في التنزيلات
      await Printing.layoutPdf(
        name: fileName,
        onLayout: (PdfPageFormat format) async => bytes,
      );
    } else {
      // على نظام أندرويد و iOS و Desktop: مشاركة وحفظ الملف مباشرة
      await Printing.sharePdf(bytes: bytes, filename: fileName);
    }
  }
}
