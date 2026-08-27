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
  QrExportOption _option = QrExportOption.printPdf;
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
                        onPressed: provider.isLoading
                            ? null
                            : () {
                                provider.selectAll(widget.students);
                              },
                        icon: const Icon(Icons.select_all),
                        label: const Text('Select All'),
                      ),

                      const SizedBox(width: 12),

                      OutlinedButton.icon(
                        onPressed: provider.isLoading
                            ? null
                            : provider.clearSelection,
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

                  const SizedBox(height: 16),

                  DropdownButtonFormField<QrExportOption>(
                    initialValue: _option,
                    decoration: const InputDecoration(
                      labelText: 'Export Format',
                      border: OutlineInputBorder(),
                    ),

                    items: const [
                      DropdownMenuItem(
                        value: QrExportOption.printPdf,
                        child: Text('Print PDF'),
                      ),
                      DropdownMenuItem(
                        value: QrExportOption.pdf,
                        child: Text('PDF Document'),
                      ),
                      DropdownMenuItem(
                        value: QrExportOption.zipPdf,
                        child: Text('ZIP (Individual PDFs)'),
                      ),
                      DropdownMenuItem(
                        value: QrExportOption.zipPng,
                        child: Text('ZIP (Individual PNGs)'),
                      ),
                    ],
                    onChanged: provider.isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _option = value);
                            }
                          },
                  ),

                  const SizedBox(height: 16),

                  if (provider.isLoading) ...[
                    LinearProgressIndicator(
                      value: provider.progressValue == 0
                          ? null
                          : provider.progressValue,
                      minHeight: 10.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.progressMessage,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '${provider.progress}/${provider.total}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () {
                                  provider.clearSelection();
                                  Navigator.pop(context);
                                },
                          child: const Text('Cancel'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              provider.isLoading || !provider.hasSelection
                              ? null
                              : () async {
                                  final students = widget.students
                                      .where(provider.isSelected)
                                      .toList();

                                  final result =
                                      _option == QrExportOption.printPdf
                                      ? await provider.printStudents(
                                          students: students,
                                        )
                                      : await provider.export(
                                          students: students,
                                          option: _option,
                                        );

                                  if (!context.mounted) return;

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result.success
                                            ? (result.message ??
                                                  'Operation completed successfully.')
                                            : (result.message ??
                                                  'Operation failed.'),
                                      ),
                                    ),
                                  );

                                  provider.clearSelection();
                                },
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(switch (_option) {
                                  QrExportOption.printPdf => Icons.print,
                                  QrExportOption.pdf => Icons.picture_as_pdf,
                                  QrExportOption.zipPdf => Icons.folder_zip,
                                  QrExportOption.zipPng => Icons.folder_zip,
                                  _ => Icons.save,
                                }),
                          label: Text(switch (_option) {
                            QrExportOption.printPdf => 'Print PDF',
                            QrExportOption.pdf => 'Export PDF',
                            QrExportOption.zipPdf => 'Export ZIP',
                            QrExportOption.zipPng => 'Export ZIP',
                            _ => 'Export',
                          }),
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
