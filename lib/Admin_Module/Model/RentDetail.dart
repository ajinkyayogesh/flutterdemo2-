class RentDetail {
  final int rentDetailsId;
  final int userId;
  final String rentReceivedOn;
  final String rentAmount;
  final String lightBillAmount;
  final String comment;
  final String status;

  RentDetail({
    required this.rentDetailsId,
    required this.userId,
    required this.rentReceivedOn,
    required this.rentAmount,
    required this.lightBillAmount,
    required this.comment,
    required this.status,
  });

  factory RentDetail.fromJson(Map<String, dynamic> json) {
    return RentDetail(
      rentDetailsId: json['rent_details_id'] ?? 0,
      userId: json['user_id'],
      rentReceivedOn: json['rent_received_on'] ?? '',
      rentAmount: json['rent_amount']?.toString() ?? '',
      lightBillAmount: json['light_bill_amount']?.toString() ?? '',
      comment: json['comment'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rent_details_id': rentDetailsId,
      'user_id': userId,
      'rent_received_on': rentReceivedOn,
      'rent_amount': rentAmount,
      'light_bill_amount': lightBillAmount,
      'comment': comment,
      'status': status,
    };
  }
}
