class Payment {
  final String id;
  final String userId;
  final String membershipId;
  final double amount;
  final String method;
  final String status; // pending, success, failed
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.userId,
    required this.membershipId,
    required this.amount,
    required this.method,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'membershipId': membershipId,
        'amount': amount,
        'method': method,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}

