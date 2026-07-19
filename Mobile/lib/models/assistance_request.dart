class AssistanceRequest {
  final String id;
  final String title;
  final String description;
  final double amountRequested;
  final String status;

  AssistanceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.amountRequested,
    required this.status,
  });

  factory AssistanceRequest.fromJson(Map<String, dynamic> json) {
    return AssistanceRequest(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amountRequested: double.tryParse(json['amountRequested']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'pending',
    );
  }
}
