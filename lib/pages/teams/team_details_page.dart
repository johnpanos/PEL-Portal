import 'dart:convert';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:pel_portal/utils/game_data.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/header.dart';
import 'package:pel_portal/widgets/loading.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class TeamDetailsPage extends StatefulWidget {
  String id;
  TeamDetailsPage(this.id);
  @override
  _TeamDetailsPageState createState() => _TeamDetailsPageState(this.id);
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {

  String id;
  Team team = new Team();
  List<User> userList = [];

  _TeamDetailsPageState(this.id);

  @override
  void initState() {
    super.initState();
    fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        AuthService.getUser(user.uid).then((_) {
          setState(() {});
          getTeam();
        });
      }
      else {
        router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
      }
    });
  }

  getTeam() async {
    await AuthService.getAuthToken().then((_) async {
      await http.get(Uri.parse("$API_HOST/api/teams/${int.parse(id)}"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          var teamJson = jsonDecode(value.body)["data"];
          setState(() {
            team = new Team.fromJson(teamJson);
          });
          userList.clear();
          for (int i = 0; i < teamJson["users"].length; i++) {
            setState(() {
              userList.add(new User.fromJson(teamJson["users"][i]["user"]));
            });
          }
        }
        else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              borderRadius: 8,
              width: 300,
              confirmBtnColor: pelRed,
              title: "Error!",
              text: jsonDecode(value.body)["data"]["message"]
          );
        }
      });
    });
  }

  void updateTeam() async {
    await AuthService.getAuthToken().then((_) async {
      await http.post(Uri.parse("$API_HOST/api/teams"), body: jsonEncode(team), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          var teamJson = jsonDecode(value.body)["data"];
          setState(() {
            team = new Team.fromJson(teamJson);
          });
          userList.clear();
          for (int i = 0; i < teamJson["users"].length; i++) {
            setState(() {
              userList.add(new User.fromJson(teamJson["users"][i]["user"]));
            });
          }
        }
        else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              borderRadius: 8,
              width: 300,
              confirmBtnColor: pelRed,
              title: "Error!",
              text: jsonDecode(value.body)["data"]["message"]
          );
        }
      });
    });
  }

  Future<void> removeMember(User user) async {
    await AuthService.getAuthToken().then((_) async {
      await http.delete(Uri.parse("$API_HOST/api/users/${user.id}/teams/${team.id}"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          getTeam();
        }
        else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              borderRadius: 8,
              width: 300,
              confirmBtnColor: pelRed,
              title: "Error!",
              text: jsonDecode(value.body)["data"]["message"]
          );
        }
      });
    });
  }

  String getUsername(User user) {
    if (team.game == "VALORANT") {
      return "Riot ID: ${user.connections!.valorantId}";
    }
    else if (team.game == "League of Legends") {
      return "Riot ID: ${user.connections!.leagueId}";
    }
    else if (team.game == "Overwatch") {
      return "BattleTag: ${user.connections!.battleTag}";
    }
    else if (team.game == "Rocket League") {
      return "Rocket ID: ${user.connections!.rocketId}";
    }
    else if (team.game == "Splitgate") {
      return "Steam Profile: ${user.connections!.steamId}";
    }
    else {
      return "Game not found";
    }
  }

  @override
  Widget build(BuildContext context) {
      if (currUser.id != null && currUser.verification!.status == "VERIFIED") {
        if (MediaQuery.of(context).size.width > 800) {
          return Scaffold(
            backgroundColor: currBackgroundColor,
            body: Column(
              children: [
                Header(),
                Padding(padding: EdgeInsets.all(8)),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            new Container(
                              width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CupertinoButton(
                                    onPressed: () => router.navigateTo(context, "/teams", transition: TransitionType.fadeIn),
                                    child: Text("Back to Teams", style: TextStyle(fontFamily: "Ubuntu", color: pelBlue),),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                              padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                              child: Card(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      ExtendedImage.network(
                                        "$PROXY_HOST/${team.logoUrl}",
                                        width: 100,
                                        height: 100,
                                      ),
                                      Text(
                                        "${team.name}",
                                        style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                      ),
                                      Padding(padding: EdgeInsets.all(8),),
                                      Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                Text("Game:", style: TextStyle(color: currTextColor, fontSize: 16),),
                                                Padding(padding: EdgeInsets.all(8),),
                                                new Container(
                                                  width: 200,
                                                  child: new DropdownButton(
                                                    value: team.game,
                                                    items: games.map((e) => DropdownMenuItem(
                                                      child: Text(e),
                                                      value: e,
                                                    )).toList(),
                                                    onChanged: null
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text("Avg Rank:", style: TextStyle(color: currTextColor, fontSize: 16),),
                                                Padding(padding: EdgeInsets.all(8),),
                                                new Container(
                                                  width: 200,
                                                  child: new DropdownButton(
                                                    value: team.avgRank,
                                                    items: gameRanks[team.game]!.map((e) => DropdownMenuItem(
                                                      child: Text(e),
                                                      value: e,
                                                    )).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        team.avgRank = value.toString();
                                                      });
                                                      updateTeam();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(8),),
                                      Column(
                                        children: userList.map((user) => Container(
                                          child: Card(
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                                    child: ExtendedImage.network(
                                                      "$PROXY_HOST/${user.profilePicture!}",
                                                      height: 75,
                                                      width: 75,
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${user.firstName!} ${user.lastName!}",
                                                        style: TextStyle(color: currTextColor, fontSize: 20),
                                                      ),
                                                      Padding(padding: EdgeInsets.all(2)),
                                                      Text(
                                                        "${user.email!}",
                                                        style: TextStyle(color: currDividerColor, fontSize: 16),
                                                      )
                                                    ],
                                                  ),
                                                  Padding(padding: EdgeInsets.all(32)),
                                                  SelectableText(
                                                    "Discord: ${user.connections!.discordTag}",
                                                    style: TextStyle(color: currTextColor, fontSize: 20),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  SelectableText(
                                                    getUsername(user),
                                                    style: TextStyle(color: currTextColor, fontSize: 20),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Visibility(
                                                    visible: user.roles.contains("${team.id}-CAPTAIN"),
                                                    child: Card(
                                                      color: pelGreen,
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        child: Text("Team Captain", style: TextStyle(color: Colors.white, fontSize: 16),),
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: currUser.roles.contains("${team.id}-CAPTAIN") && user.id != currUser.id,
                                                    child: CupertinoButton(
                                                      child: Text("Remove", style: TextStyle(color: pelRed, fontFamily: "Ubuntu"),),
                                                      onPressed: () {
                                                        CoolAlert.show(
                                                            context: context,
                                                            type: CoolAlertType.confirm,
                                                            borderRadius: 8,
                                                            onConfirmBtnTap: () {
                                                              removeMember(user);
                                                              router.pop(context);
                                                            },
                                                            width: 300,
                                                            confirmBtnColor: pelBlue,
                                                            title: "Are you sure?",
                                                            text: "Are you sure you want to remove this team member?"
                                                        );
                                                      },
                                                    )
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )).toList(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(16),),
                          ],
                        )
                    ),
                  ),
                )
              ],
            ),
          );
        }
        else {
          return Scaffold(
            backgroundColor: currBackgroundColor,
            body: Column(
              children: [
                Container(
                  child: Center(child: Text("home page"),),
                )
              ],
            ),
          );
        }
      }
      else {
        return LoadingPage();
      }
    }
  }
