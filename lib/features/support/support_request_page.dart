import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import 'support_controller.dart';

class SupportRequestPage extends StatefulWidget {
  const SupportRequestPage({super.key});

  @override
  State<SupportRequestPage> createState() => _SupportRequestPageState();
}

class _SupportRequestPageState extends State<SupportRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  String _category = 'Order';

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('New support request')),
      body: Form(
        key: _formKey,
        child: ListView(
          key: const PageStorageKey<String>('support-request-scroll'),
          padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.paddingOf(context).bottom + 28),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: .38),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                'Tell us what happened. This local support flow is ready to connect to your backend ticket API later.',
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              key: const Key('support-category'),
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const ['Order', 'Delivery', 'Payment', 'Returns', 'Account']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(growable: false),
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('support-subject'),
              controller: _subject,
              decoration: const InputDecoration(labelText: 'Subject', hintText: 'Short summary'),
              validator: (value) => (value ?? '').trim().length < 4 ? 'Enter a clear subject.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('support-message'),
              controller: _message,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Include the details our support team should know.',
                alignLabelWithHint: true,
              ),
              validator: (value) => (value ?? '').trim().length < 10 ? 'Please add a little more detail.' : null,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('submit-support-request'),
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Submit request'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ticket = SupportController.instance.createTicket(
      category: _category,
      subject: _subject.text,
      message: _message.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${ticket.id} created successfully.')),
    );
    Navigator.of(context).pop();
  }
}
