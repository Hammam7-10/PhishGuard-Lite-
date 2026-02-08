import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_snackbar.dart';
import '../../core/routing/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final reports = context.watch<ReportsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark mode'),
                  value: settings.isDarkMode,
                  onChanged: (v) => settings.setDarkMode(v),
                ),
                SwitchListTile(
                  title: const Text('Cloud sync (Firebase)'),
                  subtitle: Text(auth.firebaseReady ? 'Firebase ready ✅' : 'Firebase not ready ❌'),
                  value: settings.cloudSyncEnabled,
                  onChanged: (v) => settings.setCloudSync(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Import reports from cloud'),
              subtitle: const Text('Optional: pull reports from Firestore (adds copies locally).'),
              onTap: !auth.firebaseReady || auth.user == null
                  ? null
                  : () async {
                      await reports.importFromCloud();
                      if (context.mounted) {
                        final msg = reports.error == null ? 'Imported successfully' : reports.error!;
                        AppSnackbar.show(context, msg, isError: reports.error != null);
                      }
                    },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text(
            'PhishGuard Lite is a student project that helps users analyze suspicious messages '
            'and store reports locally (Sqflite) with optional cloud sync (Firebase).',
          ),
        ],
      ),
    );
  }
}
