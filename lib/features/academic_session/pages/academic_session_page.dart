import 'package:attendance_management_system/core/dialogs/delete_confirmation_dialog.dart';
import 'package:attendance_management_system/core/widgets/app_bar_widget.dart';
import 'package:attendance_management_system/core/widgets/app_drawer.dart';
import 'package:attendance_management_system/features/academic_session/dialogs/academic_session_form_dialog.dart';
import 'package:attendance_management_system/features/academic_session/models/academic_session.dart';
import 'package:attendance_management_system/features/academic_session/providers/academic_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dashboard/widgets/dashboard_section.dart';
import '../../dashboard/widgets/stat_card.dart';
import '../../dashboard/widgets/statistics_grid.dart';
import '../widgets/widgets.dart';

class AcademicSessionPage extends StatefulWidget {
  const AcademicSessionPage({super.key});

  @override
  State<AcademicSessionPage> createState() => _AcademicSessionPageState();
}

class _AcademicSessionPageState extends State<AcademicSessionPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicSessionProvider>().loadAcademicSessions();
    });
  }

  List<AcademicSession> _filterSessions(List<AcademicSession> sessions) {
    if (_searchQuery.isEmpty) {
      return sessions;
    }

    return sessions.where((session) {
      return session.name.toLowerCase().contains(_searchQuery);
    }).toList();
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
      builder: (_) => DeleteConfirmationDialog(
        title: 'Delete Academic Session',
        itemName: academicSession.name,
        onDelete: () async {
          final success = await context
              .read<AcademicSessionProvider>()
              .deleteAcademicSession(academicSession.id!);

          if (!mounted) return;

          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete session.')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AcademicSessionProvider>();

    final academicSessions = _filterSessions(provider.academicSessions);

    return Scaffold(
      appBar: const AppBarWidget(title: "Academic Sessions"),
      endDrawer: const AppDrawer(),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                DashboardSection(
                  title: "Statistics",
                  child: StatisticsGrid(
                    children: [
                      StatCard(
                        title: "Total Sessions",
                        value: provider.academicSessions.length,
                        icon: Icons.calendar_month_outlined,
                      ),
                    ],
                  ),
                ),

                AcademicSessionTable(
                  sessions: academicSessions,
                  onEdit: _showEditAcademicSessionDialog,
                  onDelete: _showDeleteAcademicSessionDialog,
                ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }
}
