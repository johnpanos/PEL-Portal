class Connections {

  String? userId;
  String? discordTag;
  String? discordToken;
  String? valorantId;
  String? leagueId;
  String? battleTag;
  String? battleToken;
  String? steamId;
  String? steamToken;
  String? rocketId;

  Connections();

  Connections.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    discordTag = json['discordTag'];
    discordToken = json['discordToken'];
    valorantId = json['valorantId'];
    leagueId = json['leagueId'];
    battleTag = json['battleTag'];
    battleToken = json['battleToken'];
    steamId = json['steamId'];
    steamToken = json['steamToken'];
    rocketId = json['rocketId'];
  }

  Map<String, dynamic> toJson() => {
    'userId': userId ?? "null",
    'discordTag': discordTag ?? "null",
    'discordToken': discordToken ?? "null",
    'valorantId': valorantId ?? "null",
    'leagueId': leagueId ?? "null",
    'battleTag': battleTag ?? "null",
    'battleToken': battleToken ?? "null",
    'steamId': steamId ?? "null",
    'steamToken': steamToken ?? "null",
    'rocketId': rocketId ?? "null"
  };

}