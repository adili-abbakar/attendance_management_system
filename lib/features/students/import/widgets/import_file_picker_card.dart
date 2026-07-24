import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportFilePickerCard extends StatelessWidget {
  const ImportFilePickerCard({
    super.key,
    required this.selectedFile,
    required this.onPickFile,
    required this.isLoading,
  });

  final PlatformFile? selectedFile;
  final VoidCallback? onPickFile;
  final bool isLoading;

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.upload_file,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 16),

          Text(
            selectedFile?.name ?? 'No file selected',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            selectedFile == null
                ? 'Choose a spreadsheet to begin importing students.'
                : _formatBytes(selectedFile!.size),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: isLoading ? null : onPickFile,
            icon: const Icon(Icons.folder_open),
            label: Text(selectedFile == null ? 'Choose File' : 'Change File'),
          ),
        ],
      ),
    );
  }
}
