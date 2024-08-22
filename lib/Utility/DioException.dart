class DioException implements Exception {
  final String message;
  final int? statusCode;

  DioException({required this.message, this.statusCode});

  @override
  String toString() {
    return "DioException: $message";
  }
}