import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

/// Logo EduP@y coloré
class EduPayLogo extends StatelessWidget {
  final double fontSize;
  const EduPayLogo({super.key, this.fontSize = 18});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.montserrat(
            fontSize: fontSize, fontWeight: FontWeight.w800),
        children: const [
          TextSpan(text: 'Edu', style: TextStyle(color: AppColors.white)),
          TextSpan(text: 'P', style: TextStyle(color: AppColors.green)),
          TextSpan(text: '@', style: TextStyle(color: AppColors.gold)),
          TextSpan(text: 'y', style: TextStyle(color: AppColors.green)),
        ],
      ),
    );
  }
}

/// Badge de statut coloré
class StatusTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusTag({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  factory StatusTag.green(String label) => StatusTag(
        label: label,
        color: AppColors.green,
        bgColor: AppColors.tagGreenBg,
      );

  factory StatusTag.yellow(String label) => StatusTag(
        label: label,
        color: AppColors.gold,
        bgColor: AppColors.tagYellowBg,
      );

  factory StatusTag.red(String label) => StatusTag(
        label: label,
        color: AppColors.red,
        bgColor: AppColors.tagRedBg,
      );

  factory StatusTag.blue(String label) => StatusTag(
        label: label,
        color: AppColors.blue,
        bgColor: AppColors.tagBlueBg,
      );

  factory StatusTag.white(String label) => StatusTag(
        label: label,
        color: AppColors.white50,
        bgColor: AppColors.white10,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Avatar avec initiales
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 36,
    this.backgroundColor = AppColors.green,
    this.textColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.montserrat(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// Carte générique EduPay
class EduCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? bgColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const EduCard({
    super.key,
    required this.child,
    this.borderColor,
    this.bgColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.cardBg,
          border: Border.all(
            color: borderColor ?? AppColors.borderDefault,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: child,
      ),
    );
  }
}

/// Ligne de données (label: valeur)
class EduDataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  const EduDataRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
              fontSize: 11,
              color: AppColors.white70,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton principal EduPay
class EduButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color textColor;
  final bool isOutlined;

  const EduButton({
    super.key,
    required this.label,
    this.onPressed,
    this.bgColor = AppColors.gold,
    this.textColor = AppColors.background,
    this.isOutlined = false,
  });

  factory EduButton.yellow(String label, {VoidCallback? onPressed}) =>
      EduButton(
        label: label,
        onPressed: onPressed,
        bgColor: AppColors.gold,
        textColor: AppColors.background,
      );

  factory EduButton.green(String label, {VoidCallback? onPressed}) =>
      EduButton(
        label: label,
        onPressed: onPressed,
        bgColor: AppColors.green,
        textColor: AppColors.background,
      );

  factory EduButton.outlined(String label, {VoidCallback? onPressed}) =>
      EduButton(
        label: label,
        onPressed: onPressed,
        bgColor: Colors.transparent,
        textColor: AppColors.white,
        isOutlined: true,
      );

  factory EduButton.red(String label, {VoidCallback? onPressed}) => EduButton(
        label: label,
        onPressed: onPressed,
        bgColor: const Color(0x26E53935),
        textColor: AppColors.red,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: isOutlined
                ? const BorderSide(color: AppColors.borderDefault)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

/// KPI Card (grille 2x2)
class KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const KpiCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white05,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.gold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
              fontSize: 9,
              color: AppColors.white50,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification / Alerte
class EduNotif extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;

  const EduNotif({
    super.key,
    required this.title,
    required this.subtitle,
    this.accentColor = AppColors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(7),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, 
              fontSize: 9,
              color: AppColors.white50,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Section label
class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.white50,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Diviseur subtil
class EduDivider extends StatelessWidget {
  const EduDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.divider,
      margin: const EdgeInsets.symmetric(vertical: 9),
    );
  }
}

/// Toast de succès/erreur
void showEduToast(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.close : Icons.check,
            color: AppColors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? const Color(0xFF7A1E1E) : AppColors.greenDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      margin: const EdgeInsets.all(12),
      duration: const Duration(milliseconds: 2500),
    ),
  );
}

/// Bottom Navigation Bar pour l'Agent Terrain
class AgentBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AgentBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_outlined, 'label': 'Accueil'},
      {'icon': Icons.people_outline, 'label': 'Clients'},
      {'icon': Icons.payments_outlined, 'label': 'Collectes'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1020),
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: isActive ? AppColors.gold : AppColors.white,
                      size: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i]['label'] as String,
                      style: GoogleFonts.montserrat(
                        fontSize: 9,
                        color: isActive ? AppColors.gold : AppColors.white,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
