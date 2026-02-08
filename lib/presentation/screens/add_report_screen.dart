import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../providers/reports_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_snackbar.dart';
import '../../core/routing/app_router.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _message = TextEditingController();
  final _url = TextEditingController();

  String? _imagePath;
  bool _syncToCloud = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _syncToCloud = settings.cloudSyncEnabled;
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(x.path);
    final newPath =
        p.join(dir.path, 'report_${DateTime.now().millisecondsSinceEpoch}$ext');
    await File(x.path).copy(newPath);

    setState(() => _imagePath = newPath);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<ReportsProvider>();
    setState(() => _busy = true);

    try {
      final saved = await vm.addReport(
        title: _title.text,
        messageText: _message.text,
        url: _url.text.trim().isEmpty ? null : _url.text.trim(),
        imagePath: _imagePath,
        syncToCloud: _syncToCloud,
      );

      if (!mounted) return;
      AppSnackbar.show(context, 'Saved successfully ✅');
      Navigator.pushReplacementNamed(
        context,
        Routes.reportDetails,
        arguments: saved.id ?? -1,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, 'Save failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _message,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message text',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.message),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Message is required';
                    if (s.length < 10) return 'Write at least 10 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _url,
                  decoration: const InputDecoration(
                    labelText: 'Link (optional)',
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return null;
                    final ok =
                        s.startsWith('http://') || s.startsWith('https://');
                    if (!ok) return 'URL must start with http:// or https://';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _busy ? null : _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Attach image'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SwitchListTile(
                        value: _syncToCloud,
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _syncToCloud = v),
                        title: const Text('Cloud sync'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_imagePath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(File(_imagePath!),
                        height: 160, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _submit,
                    icon: _busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_busy ? 'Saving...' : 'Analyze & Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
