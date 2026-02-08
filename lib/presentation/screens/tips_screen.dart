import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reports_provider.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ReportsProvider>();
    final keywords = vm.keywords;

    return Scaffold(
      appBar: AppBar(title: const Text('Tips & Keywords')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Quick tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _tipCard('Never share OTP or passwords.', Icons.lock),
          _tipCard('Be careful with “urgent” messages.', Icons.warning),
          _tipCard('Check links before clicking.', Icons.link),
          _tipCard('If unsure, call the official number.', Icons.phone),
          const SizedBox(height: 18),
          const Text('Suspicious keywords (from API / fallback)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (vm.isBusy) const LinearProgressIndicator(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: keywords.take(40).map((k) => Chip(label: Text(k))).toList(),
          ),
          const SizedBox(height: 10),
          const Text(
            'Note: If API fails, the app uses local fallback keywords so the project always works.',
          ),
        ],
      ),
    );
  }

  Widget _tipCard(String text, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(text),
      ),
    );
  }
}
