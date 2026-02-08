import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_router.dart';
import '../providers/reports_provider.dart';
import '../widgets/app_snackbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsProvider>();
    final reports = vm.reports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            tooltip: 'Refresh keywords (API)',
            onPressed: vm.isBusy
                ? null
                : () async {
                    await vm.refreshKeywords();
                    if (context.mounted) {
                      final msg =
                          vm.error == null ? 'Keywords updated' : vm.error!;
                      AppSnackbar.show(context, msg, isError: vm.error != null);
                    }
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.addReport),
        icon: const Icon(Icons.add),
        label: const Text('Add Report'),
      ),
      body: vm.isBusy && reports.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No reports yet. Tap "Add Report" to analyze a suspicious message.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (_, i) {
                    final r = reports[i];
                    final badgeColor = r.riskLabel == 'Dangerous'
                        ? Colors.red
                        : r.riskLabel == 'Suspicious'
                            ? Colors.orange
                            : Colors.green;

                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      leading:
                          r.imagePath != null && File(r.imagePath!).existsSync()
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(File(r.imagePath!),
                                      width: 48, height: 48, fit: BoxFit.cover),
                                )
                              : const CircleAvatar(child: Icon(Icons.shield)),
                      title: Text(r.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${r.riskLabel} • ${r.createdAt.toLocal().toString().substring(0, 16)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: badgeColor.withOpacity(0.5)),
                            ),
                            child: Text('${r.riskScore}%',
                                style: TextStyle(color: badgeColor)),
                          ),
                          const SizedBox(width: 6),
                          PopupMenuButton<String>(
                            onSelected: (v) async {
                              if (v == 'delete' && r.id != null) {
                                await vm.deleteReport(r.id!);
                                if (context.mounted)
                                  AppSnackbar.show(context, 'Deleted');
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        Routes.reportDetails,
                        arguments: r.id ?? -1,
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: reports.length,
                ),
    );
  }
}
