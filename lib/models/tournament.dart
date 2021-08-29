import 'package:pel_portal/utils/config.dart';

class Tournament {
  int? id;
  String? name;
  String? desc;
  String? game = "VALORANT";
  String? type = "HIGH_SCHOOL";
  String? division;

  DateTime? registrationStart;
  DateTime? registrationEnd;
  DateTime? seasonStart;
  DateTime? seasonEnd;
  DateTime? playoffStart;

  DateTime? updatedAt;
  DateTime? createdAt;

  Tournament();

  Tournament.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    desc = json['desc'];
    game = json['game'];
    type = json['type'];
    division = json['division'];
    registrationStart = DateTime.tryParse(json['registrationStart']);
    registrationEnd = DateTime.tryParse(json['registrationEnd']);
    seasonStart = DateTime.tryParse(json['seasonStart']);
    seasonEnd = DateTime.tryParse(json['seasonEnd']);
    playoffStart = DateTime.tryParse(json['playoffStart']);
    createdAt = DateTime.tryParse(json['createdAt']);
    updatedAt = DateTime.tryParse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name ?? "null",
    'desc': desc ?? "null",
    'game': game ?? "null",
    'type': type ?? "null",
    'division': division ?? "null",
    'registrationStart': registrationStart != null ? registrationStart.toString() : "null",
    'registrationEnd': registrationEnd != null ? registrationEnd.toString() : "null",
    'seasonStart': seasonStart != null ? seasonStart.toString() : "null",
    'seasonEnd': seasonEnd != null ? seasonEnd.toString() : "null",
    'playoffStart': playoffStart != null ? playoffStart.toString() : "null",
    'createdAt': createdAt != null ? createdAt.toString() : "null",
    'updatedAt': updatedAt != null ? updatedAt.toString() : "null",
  };
}