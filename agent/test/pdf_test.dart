import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  test('Test PDF Generation', () async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.BarcodeWidget(
                data: 'EN-ATTENTE',
                width: 180,
                height: 180,
                barcode: pw.Barcode.qrCode(
                  errorCorrectLevel: pw.BarcodeQRCorrectionLevel.medium,
                ),
                color: PdfColors.blueGrey900,
                backgroundColor: PdfColors.white,
                drawText: false,
              ),
            ],
          );
        },
      ),
    );
    
    final bytes = await pdf.save();
    expect(bytes.isNotEmpty, true);
  });
}
