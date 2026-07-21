import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/core/widgets/empty_state.dart';
import 'package:attendance_management_system/features/academic_session/models/academic_session.dart';
import 'package:attendance_management_system/features/academic_session/providers/academic_session_provider.dart';
import 'package:attendance_management_system/features/academic_session/dialogs/academic_session_form_dialog.dart';
import 'package:attendance_management_system/features/academic_session/dialogs/delete_academic_sessoin_dialog.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/dashboard_section.dart';
import '../../dashboard/widgets/stat_card.dart';
import '../../dashboard/widgets/statistics_grid.dart';

import '../widgets/academic_session_card.dart';
import '../widgets/academic_session_grid.dart';
import '../widgets/academic_session_search_bar.dart';

class AcademicSessionPage extends StatefulWidget {
  const AcademicSessionPage({super.key});

  @override
  State<AcademicSessionPage> createState() => _AcademicSessionPageState();
}

class _AcademicSessionPageState extends State<AcademicSessionPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicSessionProvider>().loadAcademicSessions();
    });
  }

  Future<void> _showCreateAcademicSessionDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AcademicSessionFormDialog(
        onSave: (name) async {
          return context.read<AcademicSessionProvider>().createAcademicSession(
            AcademicSession(
              name: name,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditAcademicSessionDialog(
    AcademicSession academicSession,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => AcademicSessionFormDialog(
        initialName: academicSession.name,

        onSave: (name) async {
          return context.read<AcademicSessionProvider>().updateAcademicSession(
            academicSession.copyWith(name: name),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteAcademicSessionDialog(
    AcademicSession academicSession,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => DeleteAcademicSessionDialog(
        academicSession: academicSession,
        onDelete: () async {
          final success = await context
              .read<AcademicSessionProvider>()
              .deleteAcademicSession(academicSession.id!);

          if (!mounted) return;

          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete Session.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicSessionProvider>();
    final academicSessions = provider.academicSessions;

    return Scaffold(
      appBar: const AppBarWidget(title: "Academic Sessions"),
      endDrawer: const AppDrawer(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAcademicSessionDialog,
        icon: const Icon(Icons.add),
        label: const Text("Add Session"),
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
                        title: "Total AcademicSessions",
                        value: academicSessions.length.toString(),
                        icon: Icons.calendar_month_outlined,
                      ),
                    ],
                  ),
                ),

                DashboardSection(
                  title: "Manage Academic Sessions",
                  child: Column(
                    children: [
                      AcademicSessionSearchBar(
                        onChanged: (_) {},
                        onAddPressed: _showCreateAcademicSessionDialog,
                      ),

                      const SizedBox(height: 20),

                      if (academicSessions.isEmpty)
                        const EmptyState(
                          title: "No Sessions",
                          message: "Create your first Academic Session.",
                          icon: Icons.calendar_month_rounded,
                        )
                      else
                        AcademicSessionGrid(
                          children: academicSessions
                              .map(
                                (academicSession) => AcademicSessionCard(
                                  name: academicSession.name,
                                  onTap: () {},

                                  // We'll implement these next.
                                  onEdit: () => _showEditAcademicSessionDialog(
                                    academicSession,
                                  ),

                                  onDelete: () =>
                                      _showDeleteAcademicSessionDialog(
                                        academicSession,
                                      ),
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
