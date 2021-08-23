class Connections {

  String? userId;
  String? discordTag;
  String? discordToken;
  String? riotId;
  String? battleTag;
  String? battleToken;
  String? rocketId;

  Connections();

  Connections.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    discordTag = json['discordTag'];
    discordToken = json['discordToken'];
    riotId = json['riotId'];
    battleTag = json['battleTag'];
    battleToken = json['battleToken'];
    rocketId = json['rocketId'];
  }

  Map<String, dynamic> toJson() => {
    'userId': userId ?? "null",
    'discordTag': discordTag ?? "null",
    'discordToken': discordToken ?? "null",
    'riotId': riotId ?? "null",
    'battleTag': battleTag ?? "null",
    'battleToken': battleToken ?? "null",
    'rocketId': rocketId ?? "null"
  };

}