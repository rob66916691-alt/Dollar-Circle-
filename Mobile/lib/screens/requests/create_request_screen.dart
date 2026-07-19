import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateRequestScreen extends StatefulWidget {
  final ApiService apiService;
  const CreateRequestScreen({super.key, required this.apiService});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final title = TextEditingController();
  final description = TextEditingController();
  final amount = TextEditingController();
  bool loading = false;

  Future<void> submit() async {
    final parsedAmount = double.tryParse(amount.text);
    if (parsedAmount == null || parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await widget.apiService.createRequest(
        title: title.text.trim(),
        description: description.text.trim(),
        amountRequested: parsedAmount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted for review')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Help')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Request title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: description,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Explain the emergency',
              helperText: 'Include enough detail for an administrator to review.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount needed',
              prefixText: r'$',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: loading ? null : submit,
            child: Text(loading ? 'Submitting...' : 'Submit Request'),
          ),
        ],
      ),
    );
  }
}
