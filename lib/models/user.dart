import 'package:pel_portal/models/connections.dart';

class User {

  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? gender;
  String? school;
  int? gradYear;
  String? profilePicture;

  DateTime? createdAt;
  DateTime? updatedAt;

  List<String> roles = [];

  Connections? connections;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    email = json['email'];
    gender = json['gender'];
    school = json['school'];
    gradYear = json['gradYear'];
    profilePicture = json['profilePicture'];
    createdAt = DateTime.parse(json['createdAt']);
    updatedAt = DateTime.parse(json['updatedAt']);
    roles = json['roles'];
    connections = Connections.fromJson(json['connections']);
  }

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'gender': gender,
    'school': school,
    'gradYear': gradYear,
    'profilePicture': profilePicture,
    'createdAt': createdAt.toString(),
    'updatedAt': updatedAt.toString(),
    'updatedAt': roles.toString(),
  };

}