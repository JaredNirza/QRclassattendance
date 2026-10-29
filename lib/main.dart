import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/configs/theme/app_colors.dart';
import 'providers/attendance_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EduTrackApp());
}

class EduTrackApp extends StatelessWidget {
  const EduTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceProvider(),
      child: MaterialApp(
        title: 'EduTrack: Classroom QR Attendance System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'CircularStd',
          scaffoldBackgroundColor: AppColors.primaryBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryButton,
            primary: AppColors.primaryButton,
            secondary: AppColors.secondaryAccent,
            surface: AppColors.cardContainer,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
