import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'contract_document.dart';

/// Génère un PDF reprenant exactement les sections du contrat affiché dans
/// l'app et ouvre le sélecteur natif de partage/impression.
Future<void> exportContractPdf(ContractDocument document) async {
  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(
          level: 0,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'EduP@y — Contrat de service',
                style: const pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('N° ${document.contractNumber}'),
              pw.Text(
                'Date : ${document.date.day}/${document.date.month}/${document.date.year}',
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 12),
        for (final section in document.sections) ...[
          pw.Text(
            section.title,
            style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          for (final paragraph in section.paragraphs) ...[
            pw.Text(paragraph, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 6),
          ],
          pw.SizedBox(height: 8),
        ],
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await doc.save(),
    filename: '${document.contractNumber}.pdf',
  );
}
