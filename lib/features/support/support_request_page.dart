import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/network/api_environment.dart';
import '../../core/network/api_models.dart';
import 'support_controller.dart';

class SupportRequestPage extends StatefulWidget {
  final String? initialOrderId;

  const SupportRequestPage({super.key, this.initialOrderId});

  @override
  State<SupportRequestPage> createState() => _SupportRequestPageState();
}

class _SupportRequestPageState extends State<SupportRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  late final TextEditingController _orderId;
  String _category = 'Order';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _orderId = TextEditingController(text: widget.initialOrderId ?? '');
    if (widget.initialOrderId != null) {
      _subject.text = 'Question about ${widget.initialOrderId}';
    }
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    _orderId.dispose();
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
          padding: EdgeInsets.fromLTRB(
            16,
            10,
            16,
            MediaQuery.paddingOf(context).bottom + 28,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: .38),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.support_agent_rounded, color: scheme.primary),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      ApiEnvironment.isRemoteConfigured
                          ? 'Your request will be sent directly to DCX Customer Care. Replies and status changes will appear in your support center.'
                          : 'Your request is saved on this device in demo mode and is ready for DCX Core sync.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              key: const Key('support-category'),
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                'Order',
                'Delivery',
                'Payment',
                'Returns',
                'Account',
                'Product',
              ]
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(growable: false),
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('support-order-id'),
              controller: _orderId,
              enabled: !_submitting,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Order number (optional)',
                hintText: 'Example: DCX-260903-2531',
                prefixIcon: Icon(Icons.receipt_long_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('support-subject'),
              controller: _subject,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'Short summary',
              ),
              validator: (value) => (value ?? '').trim().length < 4
                  ? 'Enter a clear subject.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('support-message'),
              controller: _message,
              enabled: !_submitting,
              minLines: 5,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Include the details our support team should know.',
                alignLabelWithHint: true,
              ),
              validator: (value) => (value ?? '').trim().length < 10
                  ? 'Please add a little more detail.'
                  : null,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('submit-support-request'),
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_submitting ? 'Sending request…' : 'Submit request'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final ticket = await SupportController.instance.submitTicket(
        category: _category,
        subject: _subject.text,
        message: _message.text,
        orderId: _orderId.text.trim().isEmpty ? null : _orderId.text.trim(),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ticket.id} created successfully.')),
      );
      Navigator.of(context).pop(ticket);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
