import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/configs/theme/app_colors.dart';
import '../models/student.dart';
import '../providers/attendance_provider.dart';
import '../widgets/camera_modal.dart';
import '../widgets/privacy_modal.dart';
import 'badge_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentIdController = TextEditingController();

  String? _selectedCourse = 'BSIT';
  String? _selectedYear = '3rd Year';
  String? _selectedSection = 'Section A';
  String? _photoPath;
  bool _privacyAccepted = false;
  bool _isSubmitting = false;

  final List<String> _courses = [
    'BSIT',
    'BSCS',
    'BSCpE',
    'BSIS',
    'BSBA',
    'BSN',
    'BSED',
    'BEED',
  ];

  final List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  final List<String> _sections = [
    'Section A',
    'Section B',
    'Section C',
    'Red Warriors',
    'Blue Tigers',
    'Golden Eagles',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _openCameraModal() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const CameraModal(),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _photoPath = result;
      });
    }
  }

  void _openPrivacyModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrivacyModal(
        onAccept: () {
          setState(() {
            _privacyAccepted = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Privacy consent accepted.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Data Privacy Consent terms to proceed.'),
          backgroundColor: AppColors.danger,
        ),
      );
      _openPrivacyModal();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final student = Student(
        id: _studentIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        photoPath: _photoPath ?? '',
        course: _selectedCourse ?? 'BSIT',
        yearLevel: _selectedYear ?? '3rd Year',
        section: _selectedSection ?? 'Section A',
        registeredAt: DateTime.now(),
      );

      final provider = Provider.of<AttendanceProvider>(context, listen: false);
      await provider.registerStudent(student);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student ${student.fullName} registered successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate immediately to the generated Digital Student ID Badge Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BadgeScreen(student: student),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to register student: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Back to home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendee Registration',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF28104E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Register to receive your digital student ID badge.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // First & Last Name Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('First name'),
                            TextFormField(
                              controller: _firstNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _inputDecoration(hint: 'Juan'),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Last name'),
                            TextFormField(
                              controller: _lastNameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: _inputDecoration(hint: 'Dela Cruz'),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Email Address
                  _buildFieldLabel('Email address'),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      hint: 'firstname.lastname@jmc.edu.ph',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email is required';
                      }
                      final email = val.trim().toLowerCase();
                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Enter a valid email address';
                      }
                      if (!email.endsWith('.edu') && !email.endsWith('.edu.ph') && !email.contains('jmc')) {
                        return 'Must be an official student email (@jmc.edu.ph or .edu)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Must be your official @jmc.edu.ph student email.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Student Number / ID
                  _buildFieldLabel('Student Number'),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: _inputDecoration(hint: 'e.g., 2026-10492'),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Student number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Profile Photo Capture Section
                  _buildFieldLabel('Profile photo'),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _openCameraModal,
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        label: Text(
                          _photoPath != null ? 'Retake Photo' : 'Open Camera',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF371B54),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      if (_photoPath != null)
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 44,
                                height: 44,
                                color: Colors.grey.shade200,
                                child: (!kIsWeb && File(_photoPath!).existsSync())
                                    ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                                    : const Icon(Icons.face, color: AppColors.primaryButton),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          ],
                        )
                      else
                        Text(
                          'No photo taken yet',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Course Dropdown
                  _buildFieldLabel('Course'),
                  DropdownButtonFormField<String>(
                    value: _selectedCourse,
                    decoration: _inputDecoration(),
                    items: _courses.map((course) {
                      return DropdownMenuItem(
                        value: course,
                        child: Text(course),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCourse = val;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Year & Section/Team Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Year'),
                            DropdownButtonFormField<String>(
                              value: _selectedYear,
                              decoration: _inputDecoration(),
                              items: _yearLevels.map((y) {
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text(y, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedYear = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Team / Section'),
                            DropdownButtonFormField<String>(
                              value: _selectedSection,
                              decoration: _inputDecoration(),
                              items: _sections.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedSection = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Data Privacy Consent Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.purple.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data Privacy Consent',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF371B54),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'By ticking this box, I give my consent to Jose Maria College Foundation, Inc. (JMCFI) and the College of Information Technology Education (CITE) to collect and process my personal data for classroom attendance, including my name, academic details, and profile photo.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _openPrivacyModal,
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _privacyAccepted,
                                activeColor: AppColors.primaryButton,
                                onChanged: (val) {
                                  if (!_privacyAccepted) {
                                    _openPrivacyModal();
                                  } else {
                                    setState(() {
                                      _privacyAccepted = val ?? false;
                                    });
                                  }
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'I have read and agree to the JMCFI Data Privacy Consent terms.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _privacyAccepted
                                        ? const Color(0xFF371B54)
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Submit Button: Get my badge
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Get my badge',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF28104E),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFFBFBFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }
}
