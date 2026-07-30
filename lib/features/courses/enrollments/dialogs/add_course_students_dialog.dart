import 'package:attendance_management_system/features/courses/enrollments/providers/add_course_students_provider.dart';
import 'package:attendance_management_system/features/courses/enrollments/widgets/add_students/add_student_filters.dart';
import 'package:attendance_management_system/features/courses/enrollments/widgets/add_students/add_student_pagination.dart';
import 'package:attendance_management_system/features/courses/enrollments/widgets/add_students/add_student_search_bar.dart';
import 'package:attendance_management_system/features/courses/enrollments/widgets/add_students/add_students_actions.dart';
import 'package:attendance_management_system/features/courses/enrollments/widgets/add_students/add_students_table.dart';
import 'package:attendance_management_system/features/courses/enrollments/widgets/add_students/selected_students_bar.dart';
import 'package:attendance_management_system/features/courses/enrollments/widgets/new_student_form.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:attendance_management_system/features/students/results/student_result.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddCourseStudentsDialog extends StatefulWidget {
  const AddCourseStudentsDialog({super.key, required this.courseId});

  final int courseId;

  @override
  State<AddCourseStudentsDialog> createState() =>
      _AddCourseStudentsDialogState();
}

class _AddCourseStudentsDialogState extends State<AddCourseStudentsDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<StudentResult> _createAndEnrollStudent(Student student) async {
    final provider = context.read<AddCourseStudentsProvider>();

    final result = await provider.createAndEnrollStudent(student);

    if (!mounted) return result;

    if (result.success && result.student != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            '${result.student!.fullName} created and enrolled successfully.',
          ),
        ),
      );
    }

    return result;
  }

  Future<void> _addSelectedStudents() async {
    final provider = context.read<AddCourseStudentsProvider>();

    final added = await provider.addSelectedStudents();

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$added student${added == 1 ? '' : 's'} added successfully.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddCourseStudentsProvider>();

    final size = MediaQuery.sizeOf(context);

    final dialogWidth = size.width < 600
        ? size.width * .98
        : size.width < 900
        ? size.width * .92
        : 1100.0;

    final dialogHeight = size.height * .90;

    final compact = size.width < 430;

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Students',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      splashRadius: 20,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 22),
                    ),
                  ],
                ),
              ),

              TabBar(
                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.people_alt_outlined, size: 20),
                    text: compact ? null : 'Existing Students',
                  ),
                  Tab(
                    icon: const Icon(Icons.person_add_alt_1, size: 20),
                    text: compact ? null : 'New Student',
                  ),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          AddStudentSearchBar(
                            controller: _searchController,
                            onChanged: provider.search,
                          ),

                          const SizedBox(height: 12),

                          AddStudentFilters(
                            showActiveOnly: provider.showActiveOnly,
                            sortAscending: provider.sortAscending,
                            onShowActiveChanged: provider.setShowActiveOnly,
                            onSortChanged: provider.setSortAscending,
                          ),

                          const SizedBox(height: 12),

                          SelectedStudentsBar(
                            selectedCount: provider.selectedCount,
                            onClearSelection: provider.clearSelection,
                          ),

                          const SizedBox(height: 12),

                          Expanded(
                            child: AddStudentsTable(
                              students: provider.paginatedStudents,
                              selectedStudents: provider.selectedStudents,
                              onToggleSelection:
                                  provider.toggleStudentSelection,
                            ),
                          ),

                          const SizedBox(height: 12),

                          AddStudentPagination(
                            currentPage: provider.currentPage,
                            totalPages: provider.totalPages,
                            onPrevious: provider.previousPage,
                            onNext: provider.nextPage,
                          ),

                          const SizedBox(height: 12),

                          AddStudentActions(
                            selectedCount: provider.selectedCount,
                            isLoading: provider.isLoading,
                            onCancel: () => Navigator.pop(context),
                            onAddStudents: _addSelectedStudents,
                          ),
                        ],
                      ),
                    ),

                    Center(
                      child: SizedBox(
                        width: 460,
                        child: NewStudentForm(onSave: _createAndEnrollStudent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
