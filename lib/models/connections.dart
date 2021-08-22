class Connections {

  String? userId;
  String? discordId;
  String? discordTag;
  String? discordToken;
  String? riotId;
  String? battleTag;
  String? battleToken;
  String? rocketId;

  Connections();

  Connections.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    discordId = json['discordId'];
    discordTag = json['discordTag'];
    discordToken = json['discordToken'];
    riotId = json['riotId'];
    battleTag = json['battleTag'];
    battleToken = json['battleToken'];
    rocketId = json['rocketId'];
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'discordId': discordId,
    'discordTag': discordTag,
    'discordToken': discordToken,
    'riotId': riotId,
    'battleTag': battleTag,
    'battleToken': battleToken,
    'rocketId': rocketId
  };

}