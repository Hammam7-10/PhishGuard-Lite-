import 'dart:io';

import 'package:phishguard_lite/core/nav/report_details_args.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reports_provider.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.args});
  final ReportDetailsArgs args;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsProvider>();
    final report =
        vm.reports.where((r) => r.id == args.reportId).cast().toList();
    final r = report.isNotEmpty ? report.first : null;

    if (r == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report Details')),
        body: const Center(child: Text('Report not found.')),
      );
    }

    final color = r.riskLabel == 'Dangerous'
        ? Colors.red
        : r.riskLabel == 'Suspicious'
            ? Colors.orange
            : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('${r.riskLabel} • Score: ${r.riskScore}%'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (r.imagePath != null && File(r.imagePath!).existsSync()) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(File(r.imagePath!),
                  height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
          ],
          const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(r.messageText),
          const SizedBox(height: 16),
          if (r.url != null) ...[
            const Text('URL', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(r.url!),
            const SizedBox(height: 16),
          ],
          const Text('What to do next',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            '• Do not click unknown links\n'
            '• Check the sender address\n'
            '• Use official apps/websites\n'
            '• Report the message to your bank/company\n'
            '• Enable 2-factor authentication',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: r.syncedToCloud
                      ? null
                      : () async {
                          // User can re-save by editing is not implemented; keep simple.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Tip: enable Cloud Sync when adding the report.')),
                          );
                        },
                  icon: const Icon(Icons.cloud_done),
                  label: Text(r.syncedToCloud ? 'Synced' : 'Not synced'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
