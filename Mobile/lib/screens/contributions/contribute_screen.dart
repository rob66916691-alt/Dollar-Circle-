import 'package:flutter/material.dart';
import '../../models/assistance_request.dart';
import '../../services/api_service.dart';

class ContributeScreen extends StatefulWidget {
  final ApiService apiService;
  const ContributeScreen({super.key, required this.apiService});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  Future<void> contribute(AssistanceRequest request) async {
    try {
      await widget.apiService.contribute(requestId: request.id, amount: 1.00);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your \$1 contribution to "${request.title}" was recorded.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contribute')),
      body: FutureBuilder<List<AssistanceRequest>>(
        future: widget.apiService.getApprovedRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(child: Text('No approved requests available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final item = requests[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(item.description),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Goal: \$${item.amountRequested.toStringAsFixed(2)}'),
                          const Spacer(),
                          FilledButton(
                            onPressed: () => contribute(item),
                            child: const Text('Give \$1'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
