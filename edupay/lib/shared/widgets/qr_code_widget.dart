import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/theme/app_colors.dart';

/// Rendu QR Code avec logo central EduPay, sur la même librairie
/// (`qr_flutter`) que celle utilisée côté agent (`AgQrCodeClientScreen`) pour
/// scanner ce même code : un encodeur maison ne garantit pas un tracé
/// conforme à la norme ISO/IEC 18004 et n'était pas fiablement décodable par
/// un scanner standard (ML Kit / ZXing).
class EduPayQrWidget extends StatelessWidget {
  const EduPayQrWidget({
    required this.data,
    this.size = 200.0,
    this.showLogo = true,
    this.padding = 12.0,
    super.key,
  });

  final String data;
  final double size;
  final bool showLogo;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size - padding * 2,
            // Niveau H (le logo central masque une partie des modules) sinon M.
            errorCorrectionLevel: showLogo
                ? QrErrorCorrectLevel.H
                : QrErrorCorrectLevel.M,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: palette.accentGreen,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Color(0xFF1E293B),
            ),
          ),
          if (showLogo)
            Container(
              width: size * 0.22,
              height: size * 0.22,
              padding: EdgeInsets.all(size * 0.03),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: palette.accentGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w900,
                      fontSize: size * 0.1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
