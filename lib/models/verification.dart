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
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fileUrl': fileUrl,
    'status': status,
    'createdAt': createdAt.toString(),
    'updatedAt': updatedAt.toString(),
  };

}