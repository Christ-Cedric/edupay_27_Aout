import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Génère un CSV (ouvrable nativement dans Excel/Sheets) et ouvre le
/// sélecteur de partage natif — utilisé par tous les exports "Excel" de
/// l'app (bilan finances, cotisations, financier).
Future<void> exportCsvAndShare({
  required String fileName,
  required List<String> headers,
  required List<List<String>> rows,
}) async {
  // BOM UTF-8 : Excel n'affiche correctement les accents qu'avec ce préfixe.
  final csv = const CsvEncoder(addBom: true).convert([headers, ...rows]);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(csv);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: fileName),
  );
}
