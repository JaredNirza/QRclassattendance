import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/configs/theme/app_colors.dart';
import '../models/student.dart';
import '../providers/attendance_provider.dart';
import 'badge_screen.dart';
import 'registration_screen.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'All'; // 'All', 'Present', 'Absent'
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Student Record?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.danger,
          ),
        ),
        content: Text(
          'Remove ${student.fullName} from roster? This will permanently delete their records.',
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = Provider.of<AttendanceProvider>(context, listen: false);
              await provider.deleteStudent(student.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${student.fullName} from roster.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
        title: const Text(
          'Class Roster & Records',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, color: AppColors.secondaryAccent),
            tooltip: 'Add Student',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegistrationScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AttendanceProvider>(
          builder: (context, provider, child) {
            final allStudents = provider.students;

            // Apply search filter and status filter
            final filtered = allStudents.where((student) {
              final query = _searchQuery.toLowerCase();
              final matchesQuery = query.isEmpty ||
                  student.fullName.toLowerCase().contains(query) ||
                  student.id.toLowerCase().contains(query) ||
                  student.course.toLowerCase().contains(query);

              if (!matchesQuery) return false;

              final isPresent = provider.isStudentPresentToday(student.id);
              if (_filterStatus == 'Present') return isPresent;
              if (_filterStatus == 'Absent') return !isPresent;
              return true;
            }).toList();

            return Column(
              children: [
                // Search Bar & Filter Chips Header
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                  child: Column(
                    children: [
                      // Search TextField
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by Student ID or Name...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.white70),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFF4A2574),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.secondaryAccent, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Filter Chips Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', allStudents.length),
                            const SizedBox(width: 8),
                            _buildFilterChip('Present', provider.presentToday, color: AppColors.success),
                            const SizedBox(width: 8),
                            _buildFilterChip('Absent', provider.absentCount, color: AppColors.danger),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Active List of Students
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 54,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No students match "$_searchQuery"'
                                    : 'No students enrolled yet.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              if (_searchQuery.isEmpty) ...[
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.add, color: Color(0xFF371B54)),
                                  label: const Text(
                                    'Register First Student',
                                    style: TextStyle(
                                      color: Color(0xFF371B54),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryAccent,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final student = filtered[index];
                            final isPresent = provider.isStudentPresentToday(student.id);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A2574),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isPresent
                                      ? AppColors.success.withOpacity(0.4)
                                      : Colors.white.withOpacity(0.12),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                leading: _buildAvatar(student),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        student.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isPresent ? AppColors.success : AppColors.danger).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: (isPresent ? AppColors.success : AppColors.danger).withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        isPresent ? 'Present' : 'Absent',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isPresent ? AppColors.success : const Color(0xFFF87171),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID: ${student.id} • ${student.course} - ${student.section}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      student.email,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // View Badge Button
                                    IconButton(
                                      icon: const Icon(Icons.badge_outlined, color: AppColors.secondaryAccent, size: 22),
                                      tooltip: 'View Badge',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BadgeScreen(student: student),
                                          ),
                                        );
                                      },
                                    ),

                                    // Drop / Delete Action Button
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFF87171), size: 22),
                                      tooltip: 'Remove from Roster',
                                      onPressed: () => _confirmDelete(context, student),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(Student student) {
    if (student.photoPath.isNotEmpty && !kIsWeb && File(student.photoPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Image.file(File(student.photoPath), fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryButton.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.4)),
      ),
      child: Center(
        child: Text(
          student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'S',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, {Color? color}) {
    final isSelected = _filterStatus == label;
    final themeColor = color ?? AppColors.secondaryAccent;

    return ChoiceChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filterStatus = label;
          });
        }
      },
      selectedColor: themeColor.withOpacity(0.25),
      backgroundColor: const Color(0xFF4A2574),
      side: BorderSide(
        color: isSelected ? themeColor : Colors.white.withOpacity(0.15),
        width: 1.2,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        fontSize: 12,
      ),
    );
  }
}
