class User {
  final int userId;
  final int adminId;
  final String name;
  final String emailId;
  final String username;
  final String phoneNumber;
  final String room_occupied_date;

  final String password;
  final String role;
  final int deposit;
  final int isLogin;
  final int isActive;
  final String createdDate;
  final String updatedDate;

  User({
    required this.userId,
    required this.adminId,
    required this.name,
    required this.emailId,
    required this.username,
    required this.phoneNumber,
    required this.room_occupied_date,

    required this.password,
    required this.role,
    required this.deposit,
    required this.isLogin,
    required this.isActive,
    required this.createdDate,
    required this.updatedDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      adminId: json['admin_id'],
      name: json['name'],
      emailId: json['email_id'],
      username: json['username'],
      phoneNumber: json['phone_number'],
      room_occupied_date: json['room_occupied_date'],
      password: json['password'],
      role: json['role'],
      deposit: json['deposit'],
      isLogin: json['is_login'],
      isActive: json['is_active'],
      createdDate: json['created_date'],
      updatedDate: json['updated_date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'admin_id': adminId,
      'name': name,
      'email_id': emailId,
      'username': username,
      'phone_number': phoneNumber,
      'room_occupied_date': room_occupied_date,
      'password': password,
      'role': role,
      'deposit': deposit,
      'is_login': isLogin,
      'is_active': isActive,
      'created_date': createdDate,
      'updated_date': updatedDate,
    };
  }
}
