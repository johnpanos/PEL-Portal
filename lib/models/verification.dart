import 'package:intl/intl.dart';

class Verification {

  String? userId;
  String? fileUrl;
  String? status;

  DateTime? createdAt;
  DateTime? updatedAt;

  Verification();

  Verification.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    fileUrl = json['fileUrl'];
    status = json['status'];
    createdAt = DateTime.tryParse(json['createdAt']);
    updatedAt = DateTime.tryParse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() => {
    'userId': userId ?? "null",
    'fileUrl': fileUrl ?? "null",
    'status': status ?? "null",
    'createdAt': createdAt != null ? createdAt! : "null",
    'updatedAt': updatedAt != null ? updatedAt! : "null",
  };

}