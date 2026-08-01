import 'package:attendance_management_system/features/qr/enums/qr_export_option.dart';
import 'package:attendance_management_system/features/qr/providers/qr_export_provider.dart';
import 'package:attendance_management_system/features/qr/widgets/student_selection_tile.dart';
import 'package:attendance_management_system/features/students/models/student.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BulkQrExportDialog extends StatefulWidget {
  const BulkQrExportDialog({super.key, required this.students});

  final List<Student> students;

  @override
  State<BulkQrExportDialog> createState() => _BulkQrExportDialogState();
}

class _BulkQrExportDialogState extends State<BulkQrExportDialog> {
  final TextEditingController _searchController = TextEditingController();

  String _search = '';

  List<Student> get _filteredStudents {
    if (_search.trim().isEmpty) {
      return widget.students;
    }

    final query = _search.toLowerCase();

    return widget.students.where((student) {
      return student.fullName.toLowerCase().contains(query) ||
          student.admissionNumber.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QrExportProvider>(
      builder: (context, provider, _) {
        return Dialog(
          child: SizedBox(
            width: 500,
            height: 650,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Export QR Cards',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search student...',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          provider.selectAll(widget.students);
                        },
                        icon: const Icon(Icons.select_all),
                        label: const Text('Select All'),
                      ),

                      const SizedBox(width: 12),

                      OutlinedButton.icon(
                        onPressed: provider.clearSelection,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear'),
                      ),

                      const Spacer(),

                      Text(
                        '${provider.selectedCount} Selected',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredStudents.length,
                      itemBuilder: (_, index) {
                        final student = _filteredStudents[index];

                        return StudentSelectionTile(
                          student: student,
                          selected: provider.isSelected(student),
                          onChanged: (_) {
                            provider.toggleStudent(student);
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            provider.clearSelection();
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: FilledButton.icon(
                          onPressed: provider.hasSelection
                              ? () async {
                                  final students = widget.students
                                      .where(provider.isSelected)
                                      .toList();

                                  final result = await provider.export(
                                    students: students,
                                    option: QrExportOption.pdf,
                                  );

                                  if (!context.mounted) return;

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.success
                                            ? 'Exported ${result.exportedCount} QR card(s).'
                                            : (result.message ??
                                                  'Export failed.'),
                                      ),
                                    ),
                                  );

                                  provider.clearSelection();
                                }
                              : null,
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
