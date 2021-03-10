class CustomException implements Exception {
  final String? message;
  CustomException({this.message = 'Something went wrong'});
  @override
  String toString() {
    return 'CustomException{message: $message}';
  }
}
