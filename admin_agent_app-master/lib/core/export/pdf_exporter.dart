import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Génère un PDF tabulaire et ouvre le sélecteur de partage natif — utilisé
/// par les exports "PDF" de l'app (familles, livraisons).
Future<void> exportPdfAndShare({
  required String fileName,
  required String title,
  required List<String> headers,
  required List<List<String>> rows,
}) async {
  final doc = pw.Document();
  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Header(text: title),
        pw.TableHelper.fromTextArray(headers: headers, data: rows),
      ],
    ),
  );
  await Printing.sharePdf(bytes: await doc.save(), filename: fileName);
}
