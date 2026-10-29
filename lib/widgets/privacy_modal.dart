import 'package:flutter/material.dart';
import '../core/configs/theme/app_colors.dart';

class PrivacyModal extends StatefulWidget {
  final VoidCallback onAccept;

  const PrivacyModal({
    super.key,
    required this.onAccept,
  });

  @override
  State<PrivacyModal> createState() => _PrivacyModalState();
}

class _PrivacyModalState extends State<PrivacyModal> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedBottom = false;
  bool _isConsentChecked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // Check if scrolled to bottom or near bottom
    if (position.pixels >= position.maxScrollExtent - 20) {
      if (!_hasReachedBottom) {
        setState(() {
          _hasReachedBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 620),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Data Privacy Act of 2012 (RA 10173)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        color: Colors.grey.shade600,
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please read carefully and scroll to the bottom to continue.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Scrollable Legal Terms Box
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: RawScrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thumbColor: AppColors.primaryButton.withOpacity(0.5),
                  radius: const Radius.circular(8),
                  thickness: 6,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Republic Act No. 10173 – Data Privacy Act of 2012',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The State recognizes the vital role of information and communications technology in nation-building and its inherent obligation to ensure that personal information in information and communications systems in the government and in the private sector are secured and protected.\n\n'
                          'In compliance with the Data Privacy Act of 2012 (Republic Act No. 10173) and its Implementing Rules and Regulations (IRR), EduTrack and Jose Maria College Foundation, Inc. (JMCFI) commit to protecting and respecting your personal privacy rights.\n\n'
                          '1. Information Collected: We collect your full name, student ID number, institutional email address (@jmc.edu.ph), program of study, year level, section, and live facial badge photo.\n\n'
                          '2. Purpose of Processing: The collected information is used exclusively for classroom attendance tracking, digital ID badge verification, real-time campus reporting, and university council event accreditation.\n\n'
                          '3. Storage and Security: Your personal data is stored within an encrypted local SQLite database and protected by application-level access controls. We do not transmit or sell your credentials to external third parties.\n\n'
                          '4. Student Rights: Under RA 10173, you retain the right to access, rectify, or request erasure of your student profile from the classroom roster at any time through authorized faculty administrators.\n\n'
                          '5. Consent Declaration: By consenting below, you freely grant permission to collect, process, and securely log your biometric photo and academic details for EduTrack attendance auditing.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: AppColors.primaryButton),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You have reached the end of the terms.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryButton,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Consent Checkbox Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _isConsentChecked,
                        activeColor: AppColors.primaryButton,
                        onChanged: _hasReachedBottom
                            ? (val) {
                                setState(() {
                                  _isConsentChecked = val ?? false;
                                });
                              }
                            : null, // Disabled until scrolled down
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _hasReachedBottom
                              ? () {
                                  setState(() {
                                    _isConsentChecked = !_isConsentChecked;
                                  });
                                }
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'I have read and fully understand the Data Privacy Act of 2012 (RA 10173) provisions above. I hereby give my consent for the College of Information Technology Education (CITE) and AITES to collect, process, and store my personal information for the sole purpose of classroom attendance and registration.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.35,
                                color: _hasReachedBottom
                                    ? AppColors.textDark
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_hasReachedBottom)
                    const Padding(
                      padding: EdgeInsets.only(left: 12, top: 2, bottom: 4),
                      child: Text(
                        'Please scroll to the bottom of the privacy text to unlock consent.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD97706), // Amber warning
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_hasReachedBottom && _isConsentChecked)
                          ? () {
                              Navigator.pop(context);
                              widget.onAccept();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Accept & Register',
                        style: TextStyle(
                          color: (_hasReachedBottom && _isConsentChecked)
                              ? Colors.white
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
