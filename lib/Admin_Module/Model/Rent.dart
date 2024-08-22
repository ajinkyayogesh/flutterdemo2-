class Rent {
  final int? id; // Optional, for primary key
  final String phoneNumber;
  final String name;
  final double paidRent;
  final double unpaidRent;

  Rent({
    this.id,
    required this.phoneNumber,
    required this.name,
    required this.paidRent,
    required this.unpaidRent,
  });

  // Convert a Rent instance into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'paid_rent': paidRent,
      'unpaid_rent': unpaidRent,
    };
  }

  // Convert a Map into a Rent instance
  factory Rent.fromMap(Map<String, dynamic> map) {
    return Rent(
      id: map['id'],
      phoneNumber: map['phone_number'],
      name: map['name'],
      paidRent: map['paid_rent'],
      unpaidRent: map['unpaid_rent'],
    );
  }
}
