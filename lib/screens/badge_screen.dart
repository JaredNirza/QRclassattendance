import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../core/configs/theme/app_colors.dart';
import '../models/student.dart';
import '../services/qr_service.dart';
import '../widgets/school_branding_header.dart';
import 'dashboard_screen.dart';

class BadgeScreen extends StatefulWidget {
  final Student student;

  const BadgeScreen({
    super.key,
    required this.student,
  });

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  final WidgetsToImageController _imageController = WidgetsToImageController();
  bool _isSaving = false;

  Future<void> _downloadBadge() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final bytes = await _imageController.capture();
      if (bytes == null) {
        throw Exception('Failed to render badge image.');
      }

      if (kIsWeb) {
        // On web, image capture succeeded
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Badge image generated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        // Save to temporary file, then save via Gal or local storage
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/badge_${widget.student.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.png';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        try {
          final hasAccess = await Gal.hasAccess();
          if (!hasAccess) {
            await Gal.requestAccess();
          }
          await Gal.putImage(filePath);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Digital Badge saved to your photo gallery!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (galError) {
          debugPrint('Gal save fallback: $galError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Badge saved to local storage: $filePath'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error downloading badge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save badge: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrPayload = QrService.generateQrPayload(widget.student);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(widget.student.registeredAt);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (route) => false,
            );
          },
        ),
        title: const Text(
          'Digital Student ID Badge',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            tooltip: 'Home',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Badge Card to capture
              WidgetsToImage(
                controller: _imageController,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A2574),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // School Crest & Header
                      const SchoolBrandingHeader(compact: true),
                      const SizedBox(height: 16),

                      // Profile Photo
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.secondaryAccent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _buildStudentPhoto(),
                      ),
                      const SizedBox(height: 12),

                      // Student Name
                      Text(
                        widget.student.fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Student ID
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.student.id,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryAccent,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Details Grid
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow('Email', widget.student.email),
                            const Divider(color: Colors.white12, height: 12),
                            _buildInfoRow('Course & Year', '${widget.student.course} • ${widget.student.yearLevel}'),
                            const Divider(color: Colors.white12, height: 12),
                            _buildInfoRow('Section', widget.student.section),
                            const Divider(color: Colors.white12, height: 12),
                            _buildInfoRow('Date Registered', formattedDate),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // QR Code Container
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: qrPayload,
                          version: QrVersions.auto,
                          size: 170.0,
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF371B54),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'SCAN FOR ATTENDANCE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Download Badge Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _downloadBadge,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download_rounded, color: Colors.white),
                  label: Text(
                    _isSaving ? 'Saving Badge...' : 'Download My Badge',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Back to Dashboard Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white70),
                label: const Text(
                  'Back to Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentPhoto() {
    if (widget.student.photoPath.isNotEmpty &&
        !kIsWeb &&
        File(widget.student.photoPath).existsSync()) {
      return Image.file(
        File(widget.student.photoPath),
        fit: BoxFit.cover,
      );
    }

    return Container(
      color: const Color(0xFF6C5CE7).withOpacity(0.3),
      child: Center(
        child: Text(
          widget.student.firstName.isNotEmpty ? widget.student.firstName[0].toUpperCase() : 'S',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Color(0xFF371B54),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
