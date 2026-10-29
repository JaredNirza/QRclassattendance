import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/configs/theme/app_colors.dart';
import '../providers/attendance_provider.dart';
import '../widgets/school_branding_header.dart';
import '../widgets/summary_card.dart';
import 'registration_screen.dart';
import 'scanner_screen.dart';
import 'roster_screen.dart';
import 'catalog_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            return RefreshIndicator(
              color: AppColors.primaryButton,
              backgroundColor: Colors.white,
              onRefresh: () => provider.loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),

                    // Top School & Event Branding Header
                    const SchoolBrandingHeader(),

                    const SizedBox(height: 28),

                    // 3 Dynamic Summary Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Total Enrolled',
                            value: provider.totalEnrolled.toString(),
                            icon: Icons.people_alt_rounded,
                            accentColor: AppColors.secondaryAccent,
                            subtitle: 'In SQLite',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SummaryCard(
                            title: 'Present Today',
                            value: provider.presentToday.toString(),
                            icon: Icons.check_circle_rounded,
                            accentColor: AppColors.success,
                            subtitle: 'Active now',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SummaryCard(
                            title: 'Absent',
                            value: provider.absentCount.toString(),
                            icon: Icons.person_off_rounded,
                            accentColor: AppColors.danger,
                            subtitle: 'Unchecked',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Navigation Action 1: Register Student
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryAccent,
                        foregroundColor: AppColors.primaryBackground,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_add_alt_1_rounded, size: 22, color: Color(0xFF371B54)),
                          SizedBox(width: 10),
                          Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF371B54),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Navigation Action 2: Scan Attendance
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScannerScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(color: Colors.white.withOpacity(0.35), width: 1.2),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 22, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Scanner',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        '*for Admin use only',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Navigation Action 3: Class Roster & Records
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RosterScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.table_chart_rounded, size: 18, color: AppColors.secondaryAccent),
                      label: const Text(
                        'Class Roster & Records',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryAccent,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Navigation Action 4: Lab Activity 1 - Service Catalog & API
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CatalogScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.storefront_rounded, size: 18, color: Color(0xFF371B54)),
                      label: const Text(
                        'CITE Service Catalog (API)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF371B54),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8DEF8),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Footer branding
                    Center(
                      child: Text(
                        'College of Information Technology Education • AITES • QR Attendance',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
