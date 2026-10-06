import 'package:attendance_management_system/core/buttons/buttons.dart';
import 'package:attendance_management_system/core/responsive/app_responsive.dart';
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

  static const List<QrExportOption> _bulkExportOptions = [
    QrExportOption.printPdf,
    QrExportOption.pdf,
    QrExportOption.zipPng,
    QrExportOption.zipPdf,
  ];

  QrExportOption _option = QrExportOption.printPdf;
  String _search = '';

  List<Student> get _filteredStudents {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.students;
    }

    return widget.students.where((student) {
      return student.fullName.toLowerCase().contains(query) ||
          student.admissionNumber.toLowerCase().contains(query);
    }).toList();
  }

  IconData get _exportIcon {
    return switch (_option) {
      QrExportOption.printPdf => Icons.print_rounded,
      QrExportOption.pdf => Icons.picture_as_pdf_rounded,
      QrExportOption.zipPdf => Icons.folder_zip_rounded,
      QrExportOption.zipPng => Icons.folder_zip_rounded,

      // This option is not available in this dialog.
      QrExportOption.png => Icons.image_rounded,
    };
  }

  String get _exportButtonText {
    return switch (_option) {
      QrExportOption.printPdf => 'Print',
      QrExportOption.pdf => 'Export PDF',
      QrExportOption.zipPdf => 'Export ZIP',
      QrExportOption.zipPng => 'Export ZIP',

      // This option is not available in this dialog.
      QrExportOption.png => 'Export PNG',
    };
  }

  Future<void> _export(BuildContext context, QrExportProvider provider) async {
    if (provider.isLoading || !provider.hasSelection) {
      return;
    }

    final students = widget.students.where(provider.isSelected).toList();

    if (students.isEmpty) {
      return;
    }

    final result = _option == QrExportOption.printPdf
        ? await provider.printStudents(students: students)
        : await provider.export(students: students, option: _option);

    if (!context.mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? (result.message ?? 'Operation completed successfully.')
              : (result.message ?? 'Operation failed.'),
        ),
      ),
    );

    provider.clearSelection();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _search = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final screenSize = MediaQuery.sizeOf(context);

    final availableWidth = screenSize.width - (r.dialogInset * 2);

    final dialogWidth = availableWidth < r.dialogWidth
        ? availableWidth
        : r.dialogWidth;

    final dialogHeight = screenSize.height * 0.86;

    return Consumer<QrExportProvider>(
      builder: (context, provider, _) {
        final students = _filteredStudents;

        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: r.dialogInset,
            vertical: r.dialogInset,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(r.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ----------------------------------------------------------------
                  // Header
                  // ----------------------------------------------------------------
                  Text(
                    'Export QR Cards',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: r.titleLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: r.spacingM),

                  // ----------------------------------------------------------------
                  // Search
                  // ----------------------------------------------------------------
                  TextField(
                    controller: _searchController,
                    enabled: !provider.isLoading,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: r.iconMedium,
                      ),
                      hintText: 'Search student...',
                      suffixIcon: _search.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: Icon(
                                Icons.close_rounded,
                                size: r.iconSmall,
                              ),
                              onPressed: provider.isLoading
                                  ? null
                                  : _clearSearch,
                            ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _search = value;
                      });
                    },
                  ),

                  SizedBox(height: r.spacingS),

                  // ----------------------------------------------------------------
                  // Selection controls
                  // ----------------------------------------------------------------
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: r.spacingS,
                    runSpacing: r.spacingXS,
                    children: [
                      Wrap(
                        spacing: r.spacingXS,
                        runSpacing: r.spacingXS,
                        children: [
                          AppTextButton(
                            text: 'Select All',
                            icon: Icons.select_all_rounded,
                            onPressed:
                                provider.isLoading || widget.students.isEmpty
                                ? null
                                : () {
                                    provider.selectAll(widget.students);
                                  },
                          ),
                          AppTextButton(
                            text: 'Clear',
                            icon: Icons.clear_all_rounded,
                            onPressed:
                                provider.isLoading || !provider.hasSelection
                                ? null
                                : provider.clearSelection,
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.spacingS,
                          vertical: r.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(r.radius),
                        ),
                        child: Text(
                          '${provider.selectedCount} selected',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: r.body,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: r.spacingS),

                  // ----------------------------------------------------------------
                  // Student list
                  // ----------------------------------------------------------------
                  Expanded(
                    child: students.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(r.spacingM),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_search_rounded,
                                    size: r.iconLarge,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  SizedBox(height: r.spacingS),
                                  Text(
                                    _search.trim().isEmpty
                                        ? 'No students available.'
                                        : 'No students found.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: r.body,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];

                              return StudentSelectionTile(
                                student: student,
                                selected: provider.isSelected(student),
                                onChanged: (_) {
                                  if (provider.isLoading) return;

                                  provider.toggleStudent(student);
                                },
                              );
                            },
                          ),
                  ),

                  SizedBox(height: r.spacingM),

                  // ----------------------------------------------------------------
                  // Export format
                  // ----------------------------------------------------------------
                  DropdownButtonFormField<QrExportOption>(
                    initialValue: _option,
                    decoration: const InputDecoration(
                      labelText: 'Export Format',
                      border: OutlineInputBorder(),
                    ),
                    items: _bulkExportOptions.map((option) {
                      return DropdownMenuItem<QrExportOption>(
                        value: option,
                        child: Text(option.label),
                      );
                    }).toList(),
                    onChanged: provider.isLoading
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _option = value;
                            });
                          },
                  ),

                  // ----------------------------------------------------------------
                  // Progress
                  // ----------------------------------------------------------------
                  if (provider.isLoading) ...[
                    SizedBox(height: r.spacingM),

                    LinearProgressIndicator(
                      value: provider.progressValue == 0
                          ? null
                          : provider.progressValue,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(r.radius),
                    ),

                    SizedBox(height: r.spacingS),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.progressMessage,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: r.body,
                            ),
                          ),
                        ),
                        SizedBox(width: r.spacingS),
                        Text(
                          '${provider.progress}/${provider.total}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: r.body,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: r.spacingM),

                  // ----------------------------------------------------------------
                  // Actions
                  // ----------------------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: AppTextButton(
                          text: 'Cancel',
                          onPressed: provider.isLoading
                              ? null
                              : () {
                                  provider.clearSelection();
                                  Navigator.pop(context);
                                },
                        ),
                      ),

                      SizedBox(width: r.spacingS),

                      Expanded(
                        child: PrimaryButton(
                          width: double.infinity,
                          text: _exportButtonText,
                          icon: _exportIcon,
                          isLoading: provider.isLoading,
                          onPressed:
                              provider.isLoading || !provider.hasSelection
                              ? null
                              : () => _export(context, provider),
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
