import 'package:hr/data/models/user_model.dart';

class AbsenModel {
  final int? id;
  final int? userId;
  final int? tugasId;
  final double? checkinLat;
  final double? checkinLng;
  final String? checkinTime;
  final String? checkinDate;
  final double? checkoutLat;
  final double? checkoutLng;
  final String? checkoutTime;
  final String? checkoutDate;
  final String? videoUser;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final UserModel? user;

  AbsenModel({
    this.id,
    this.userId,
    this.tugasId,
    this.checkinLat,
    this.checkinLng,
    this.checkinTime,
    this.checkinDate,
    this.checkoutLat,
    this.checkoutLng,
    this.checkoutTime,
    this.checkoutDate,
    this.videoUser,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory AbsenModel.fromJson(Map<String, dynamic> json) {
    return AbsenModel(
      id: json['id'],
      userId: json['user_id'],
      tugasId: json['tugas_id'],
      checkinLat: json['checkin_lat'] != null
          ? double.tryParse(json['checkin_lat'].toString())
          : null,
      checkinLng: json['checkin_lng'] != null
          ? double.tryParse(json['checkin_lng'].toString())
          : null,
      checkinTime: json['checkin_time'],
      checkinDate: json['checkin_date'],
      checkoutLat: json['checkout_lat'] != null
          ? double.tryParse(json['checkout_lat'].toString())
          : null,
      checkoutLng: json['checkout_lng'] != null
          ? double.tryParse(json['checkout_lng'].toString())
          : null,
      checkoutTime: json['checkout_time'],
      checkoutDate: json['checkout_date'],
      videoUser: json['video_user'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
