class Team {
  int? id;
  String? name;
  String? logoUrl;
  String? game;
  String? avgRank;

  DateTime? createdAt;
  DateTime? updatedAt;

  Team();

  Team.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logoUrl = json['logoUrl'];
    game = json['game'];
    avgRank = json['avgRank'];
    createdAt = DateTime.tryParse(json['createdAt']);
    updatedAt = DateTime.tryParse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() => {
    'id': id ?? "null",
    'name': name ?? "null",
    'logoUrl': logoUrl ?? "null",
    'game': game ?? "null",
    'avgRank': avgRank ?? "null",
    'createdAt': createdAt != null ? createdAt.toString() : "null",
    'updatedAt': updatedAt != null ? updatedAt.toString() : "null",
  };
}