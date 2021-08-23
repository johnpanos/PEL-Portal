import 'package:intl/intl.dart';
import 'package:pel_portal/models/connections.dart';
import 'package:pel_portal/models/verification.dart';

class User {

  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? gender = "MALE";
  String? school;
  int? gradYear;
  String? profilePicture;

  DateTime? createdAt;
  DateTime? updatedAt;

  List<String> roles = [];

  Connections? connections = new Connections();
  Verification? verification = new Verification();

  User();

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    gender = json['gender'];
    school = json['school'];
    gradYear = json['gradYear'];
    profilePicture = json['profilePicture'];
    createdAt = DateTime.tryParse(json['createdAt']);
    updatedAt = DateTime.tryParse(json['updatedAt']);
    json['roles'].forEach((role) {
      roles.add(role);
    });
    if (json['connections']["userId"] != null) {
      connections = Connections.fromJson(json['connections']);
    }
    if (json['verification']["userId"] != null) {
      verification = Verification.fromJson(json['verification']);
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id ?? "null",
      'firstName': firstName ?? "null",
      'lastName': lastName ?? "null",
      'email': email ?? "null",
      'gender': gender ?? "null",
      'school': school ?? "null",
      'gradYear': gradYear ?? "null",
      'profilePicture': profilePicture ?? "null",
      'createdAt': createdAt != null ? createdAt! : "null",
      'updatedAt': updatedAt != null ? updatedAt! : "null",
      'roles': roles,
    };
    if (connections!.userId != null) {
      json.addAll({'connections': connections});
    }
    if (verification!.userId != null) {
      json.addAll({'verification': verification});
    }
    return json;
  }

}