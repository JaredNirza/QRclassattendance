import 'package:flutter/material.dart';
import '../core/configs/theme/app_colors.dart';

class SchoolBrandingHeader extends StatelessWidget {
  final bool compact;

  // Easy PNG logo configuration:
  // Place your PNG files in assets/images/ with these exact names:
  // 1. School Logo: assets/images/school_logo.png
  // 2. CITE Logo: assets/images/cite_logo.png
  // 3. AITES Logo: assets/images/aites_logo.png
  static const String schoolLogoPath = 'assets/images/school_logo.png';
  static const String citeLogoPath = 'assets/images/cite_logo.png';
  static const String aitesLogoPath = 'assets/images/aites_logo.png';

  const SchoolBrandingHeader({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 42.0 : 54.0;

    return Column(
      children: [
        // 3 Logos Row: CITE, School Logo, AITES
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CITE Department Logo
            _buildLogoItem(
              assetPath: citeLogoPath,
              fallbackLabel: 'CITE',
              fallbackIcon: Icons.computer_rounded,
              fallbackColor: const Color(0xFF1E88E5), // Blue accent for CITE
              size: logoSize,
            ),
            const SizedBox(width: 16),

            // JMCFI School Logo (Center)
            _buildLogoItem(
              assetPath: schoolLogoPath,
              fallbackLabel: 'JMCFI',
              fallbackIcon: Icons.school_rounded,
              fallbackColor: const Color(0xFF2E7D32), // Green accent for School
              size: logoSize + 8,
              isCenter: true,
            ),
            const SizedBox(width: 16),

            // AITES Student Organization Logo
            _buildLogoItem(
              assetPath: aitesLogoPath,
              fallbackLabel: 'AITES',
              fallbackIcon: Icons.groups_rounded,
              fallbackColor: const Color(0xFF8E24AA), // Purple accent for AITES
              size: logoSize,
            ),
          ],
        ),
        SizedBox(height: compact ? 10 : 16),

        // School Title
        Text(
          'JOSE MARIA COLLEGE\nFOUNDATION INC.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 15 : 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.8,
            height: 1.2,
            fontFamily: 'serif',
          ),
        ),
        const SizedBox(height: 6),

        // Department Title (CITE)
        Text(
          'College of Information Technology Education',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.95),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),

        // Student Organization (AITES)
        const Text(
          'Association of Information Technology Education Students (AITES)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryAccent,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),

        // Academic Year & System Subtitle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Classroom QR Attendance System • AY 2026-2027',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoItem({
    required String assetPath,
    required String fallbackLabel,
    required IconData fallbackIcon,
    required Color fallbackColor,
    required double size,
    bool isCenter = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCenter ? const Color(0xFF4CAF50) : AppColors.secondaryAccent,
          width: isCenter ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Clean fallback badge if the user hasn't added the .png file yet
          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  fallbackIcon,
                  size: size * 0.42,
                  color: fallbackColor,
                ),
                const SizedBox(height: 1),
                Text(
                  fallbackLabel,
                  style: TextStyle(
                    fontSize: compact ? 7 : 8,
                    fontWeight: FontWeight.w900,
                    color: fallbackColor,
                    height: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
