import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/data/models/student.dart';
import 'package:attendance_management_system/data/providers/student_provider.dart';
import 'package:attendance_management_system/features/students/widgets/delete_student_dialog.dart';
import 'package:attendance_management_system/features/students/widgets/empty_students.dart';
import 'package:attendance_management_system/features/students/widgets/student_form_dialog.dart';
import 'package:attendance_management_system/features/students/widgets/student_pagination.dart';
import 'package:attendance_management_system/features/students/widgets/student_search_bar.dart';
import 'package:attendance_management_system/features/students/widgets/student_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Student> _filteredStudents = [];

  int _currentPage = 1;

  static const int _itemsPerPage = 20;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<StudentProvider>().loadStudents();

      if (!mounted) return;

      _applySearch('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String query) {
    final students = context.read<StudentProvider>().students;

    setState(() {
      _currentPage = 1;

      if (query.trim().isEmpty) {
        _filteredStudents = students;
      } else {
        final q = query.toLowerCase();

        _filteredStudents = students.where((student) {
          return student.fullName.toLowerCase().contains(q) ||
              student.admissionNumber.toLowerCase().contains(q);
        }).toList();
      }
    });
  }

  List<Student> get _currentStudents {
    final start = (_currentPage - 1) * _itemsPerPage;

    var end = start + _itemsPerPage;

    if (end > _filteredStudents.length) {
      end = _filteredStudents.length;
    }

    return _filteredStudents.sublist(start, end);
  }

  int get _totalPages {
    if (_filteredStudents.isEmpty) return 1;

    return (_filteredStudents.length / _itemsPerPage).ceil();
  }

  Future<void> _showAddStudentDialog() async {
    await showDialog(
      context: context,
      builder: (_) {
        return StudentFormDialog(
          onSave: (student) async {
            final success = await context.read<StudentProvider>().createStudent(
              student,
            );

            if (success) {
              _applySearch(_searchController.text);
            }

            return success;
          },
        );
      },
    );
  }

  Future<void> _showEditStudentDialog(Student student) async {
    await showDialog(
      context: context,
      builder: (_) {
        return StudentFormDialog(
          student: student,
          onSave: (updatedStudent) async {
            final success = await context.read<StudentProvider>().updateStudent(
              updatedStudent,
            );

            if (success) {
              _applySearch(_searchController.text);
            }

            return success;
          },
        );
      },
    );
  }

  Future<void> _showDeleteStudentDialog(Student student) async {
    await showDialog(
      context: context,
      builder: (_) {
        return DeleteStudentDialog(
          student: student,
          onDelete: () async {
            await context.read<StudentProvider>().deleteStudent(student.id!);

            if (!mounted) return;

            _applySearch(_searchController.text);
          },
        );
      },
    );
  }

  Future<void> _refresh() async {
    await context.read<StudentProvider>().loadStudents();

    if (!mounted) return;

    _applySearch(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();

    if (_filteredStudents.isEmpty &&
        provider.students.isNotEmpty &&
        _searchController.text.isEmpty) {
      _filteredStudents = provider.students;
    }

    return Scaffold(
      appBar: AppBarWidget(title: 'Students'),
      endDrawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            StudentSearchBar(
              controller: _searchController,
              onChanged: _applySearch,
              onAddStudent: _showAddStudentDialog,
            ),

            const SizedBox(height: 24),

            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredStudents.isEmpty)
              EmptyStudents(onAddStudent: _showAddStudentDialog)
            else ...[
              StudentTable(
                students: _currentStudents,
                onEdit: _showEditStudentDialog,
                onDelete: _showDeleteStudentDialog,
              ),

              const SizedBox(height: 20),

              StudentPagination(
                currentPage: _currentPage,
                totalPages: _totalPages,
                totalItems: _filteredStudents.length,
                itemsPerPage: _itemsPerPage,
                onPrevious: _currentPage == 1
                    ? null
                    : () {
                        setState(() {
                          _currentPage--;
                        });
                      },
                onNext: _currentPage == _totalPages
                    ? null
                    : () {
                        setState(() {
                          _currentPage++;
                        });
                      },
              ),
            ],

            if (provider.error != null) ...[
              const SizedBox(height: 20),

              Card(
                color: Colors.red.withValues(alpha: .08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          provider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
