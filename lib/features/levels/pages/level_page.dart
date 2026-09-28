import 'package:attendance_management_system/core/dialogs/delete_confirmation_dialog.dart';
import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/levels/models/level.dart';
import 'package:attendance_management_system/features/levels/providers/level_provider.dart';
import 'package:attendance_management_system/features/levels/dialogs/level_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/dashboard_section.dart';

import '../widgets/widgets.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LevelProvider>().loadLevels();
    });
  }

  Future<void> _showCreateLevelDialog() async {
    await showDialog(
      context: context,
      builder: (_) => LevelFormDialog(
        onSave: (name) async {
          return context.read<LevelProvider>().createLevel(
            Level(
              name: name,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditLevelDialog(Level level) async {
    await showDialog(
      context: context,
      builder: (_) => LevelFormDialog(
        initialName: level.name,

        onSave: (name) async {
          return context.read<LevelProvider>().updateLevel(
            level.copyWith(name: name),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteLevelDialog(Level level) async {
    await showDialog(
      context: context,
      builder: (_) => DeleteConfirmationDialog(
        title: 'Delete Level',
        itemName: level.name,
        onDelete: () async {
          final success = await context.read<LevelProvider>().deleteLevel(
            level.id!,
          );

          if (!mounted) return;

          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete level.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LevelProvider>();
    final levels = provider.levels;

    return Scaffold(
      appBar: const AppBarWidget(title: "Levels"),
      endDrawer: const AppDrawer(),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                DashboardSection(
                  title: "Manage Levels",
                  child: Column(
                    children: [
                      LevelSearchBar(
                        onChanged: (_) {},
                        onAddPressed: _showCreateLevelDialog,
                      ),

                      const SizedBox(height: 20),

                      LevelTable(
                        levels: levels,
                        onEdit: _showEditLevelDialog,
                        onDelete: _showDeleteLevelDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
