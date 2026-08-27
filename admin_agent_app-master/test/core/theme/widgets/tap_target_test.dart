import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edupay_admin/core/theme/app_spacing.dart';
import 'package:edupay_admin/core/theme/widgets/tap_target.dart';

void main() {
  testWidgets(
    'impose une zone tactile d\'au moins 48×48 px même pour un petit contenu',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TapTarget(
              onTap: () => tapped = true,
              child: const Text('x', style: TextStyle(fontSize: 8)),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(TapTarget));
      expect(size.height, greaterThanOrEqualTo(AppSpacing.minTapTarget));
      expect(size.width, greaterThanOrEqualTo(AppSpacing.minTapTarget));

      await tester.tap(find.byType(TapTarget));
      expect(tapped, isTrue);
    },
  );
}
