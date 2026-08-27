import 'dart:math';

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';

/// Avatar circulaire à initiales (motif `.av` du prototype), utilisé pour
/// représenter familles, agents et clients dans les listes.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 36,
    this.backgroundColor = AppColors.green,
    this.foregroundColor = AppColors.navy,
  });

  final String name;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, min(2, parts.first.length)).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Text(
        _initials,
        style: AppTextStyles.avatarInitials.copyWith(
          color: foregroundColor,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
