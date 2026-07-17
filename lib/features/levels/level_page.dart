import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/core/widgets/empty_state.dart';
import 'package:attendance_management_system/data/models/level.dart';
import 'package:attendance_management_system/data/providers/level_provider.dart';
import 'package:attendance_management_system/features/levels/widgets/level_form_dialog.dart';
import 'package:attendance_management_system/features/levels/widgets/delete_level_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../dashboard/widgets/dashboard_section.dart';
import '../dashboard/widgets/stat_card.dart';
import '../dashboard/widgets/statistics_grid.dart';

import 'widgets/level_card.dart';
import 'widgets/level_grid.dart';
import 'widgets/level_search_bar.dart';

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
            level.copyWith(
              name: name,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteLevelDialog(Level level) async {
    await showDialog(
      context: context,
      builder: (_) => DeleteLevelDialog(
        level: level,
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateLevelDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Level"),
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                DashboardSection(
                  title: "Statistics",
                  child: StatisticsGrid(
                    children: [
                      StatCard(
                        title: "Total Levels",
                        value: levels.length.toString(),
                        icon: Icons.school,
                      ),
                    ],
                  ),
                ),

                DashboardSection(
                  title: "Manage Levels",
                  child: Column(
                    children: [
                      LevelSearchBar(
                        onChanged: (_) {},
                        onAddPressed: _showCreateLevelDialog,
                      ),

                      const SizedBox(height: 20),

                      if (levels.isEmpty)
                        const EmptyState(
                          title: "No Levels",
                          message: "Create your first level.",
                          icon: Icons.school_outlined,
                        )
                      else
                        LevelGrid(
                          children: levels
                              .map(
                                (level) => LevelCard(
                                  name: level.name,
                                  onTap: () {},

                                  // We'll implement these next.
                                  onEdit: () => _showEditLevelDialog(level),

                                  onDelete: () =>
                                      _showDeleteLevelDialog(level),
                                ),
                              )
                              .toList(),
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
