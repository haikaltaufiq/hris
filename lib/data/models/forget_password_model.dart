class ForgetPasswordRequest {
  final String email;

  ForgetPasswordRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {
      "email": email,
    };
  }
}

class ForgetPasswordResponse {
  final String status;
  final String message;

  ForgetPasswordResponse({required this.status, required this.message});

  factory ForgetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgetPasswordResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? 'Terjadi kesalahan',
    );
  }
}
