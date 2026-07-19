import 'package:flutter/material.dart';
import '../../models/assistance_request.dart';
import '../../services/api_service.dart';

class RequestListScreen extends StatelessWidget {
  final ApiService apiService;
  final bool mineOnly;

  const RequestListScreen({
    super.key,
    required this.apiService,
    this.mineOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssistanceRequest>>(
      future: mineOnly ? apiService.getMyRequests() : apiService.getApprovedRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text('No requests found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final item = requests[index];
            return Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(
                  '${item.description}
Status: ${item.status}',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '\$${item.amountRequested.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
