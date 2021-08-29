import 'dart:convert';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/models/tournament.dart';
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

class TournamentDetailsPage extends StatefulWidget {
  String id;
  TournamentDetailsPage(this.id);
  @override
  _TournamentDetailsPageState createState() => _TournamentDetailsPageState(this.id);
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage> {

  String id;
  Tournament tournament = new Tournament();

  bool registered = false;
  Team registeredTeam = Team();
  bool registering = false;
  String battlefyCode = "_ _ _ _ _ _ _";

  List<Team> registerTeams = [];

  List<Team> teamList = [];

  _TournamentDetailsPageState(this.id);

  @override
  void initState() {
    super.initState();
    fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        AuthService.getUser(user.uid).then((_) {
          setState(() {});
          getTournament();
        });
      }
      else {
        router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
      }
    });
  }

  getTournament() async {
    await AuthService.getAuthToken().then((_) async {
      await http.get(Uri.parse("$API_HOST/api/tournaments/${int.parse(id)}"), headers: {"Authorization": authToken}).then((value) async {
        if (value.statusCode == 200) {
          var tournamentJson = jsonDecode(value.body)["data"];
          setState(() {
            tournament = new Tournament.fromJson(tournamentJson);
          });
          for (int i = 0; i < tournamentJson["teams"].length; i++) {
            getTournamentTeams(tournamentJson["teams"][i]["teamId"]);
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

  Future<void> getTournamentTeams(int teamId) async {
    await AuthService.getAuthToken().then((_) async {
      await http.get(Uri.parse("$API_HOST/api/teams/$teamId"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          var teamJson = jsonDecode(value.body)["data"];
          setState(() {
            teamList.add(Team.fromJson(teamJson));
          });
          if (teamJson["users"].toString().contains(currUser.id!)) {
            setState(() {
              registered = true;
              registeredTeam = Team.fromJson(teamJson);
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
              title: "Error getting teams!",
              text: jsonDecode(value.body)["data"]["message"]
          );
        }
      });
    });
  }

  Future<void> removeTournamentTeam(Team team) async {
    await AuthService.getAuthToken().then((_) async {
      await http.delete(Uri.parse("$API_HOST/api/tournaments/${tournament.id}/teams/${team.id}"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          setState(() {
            teamList.remove(team);
          });
        }
        else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              borderRadius: 8,
              width: 300,
              confirmBtnColor: pelRed,
              title: "Error getting teams!",
              text: jsonDecode(value.body)["data"]["message"]
          );
        }
      });
    });
  }

  void handleRegistration() {
    if (DateTime.now().isBefore(tournament.registrationEnd!)) {
      if (currUser.roles.contains(tournament.type) || tournament.type == "BOTH") {
        setState(() {
          registering = true;
        });
        currUser.roles.forEach((role) async {
          if (role.contains("-CAPTAIN")) {
            await AuthService.getAuthToken().then((_) async {
              await http.get(Uri.parse("$API_HOST/api/teams/${role.split("-CAPTAIN")[0]}"), headers: {"Authorization": authToken}).then((value) {
                if (value.statusCode == 200) {
                  Team team = Team.fromJson(jsonDecode(value.body)["data"]);
                  if (team.game == tournament.game) {
                    setState(() {
                      registerTeams.add(team);
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
                      title: "Error getting teams!",
                      text: jsonDecode(value.body)["data"]["message"]
                  );
                }
              });
            });
          }
        });
      }
      else {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            borderRadius: 8,
            width: 300,
            confirmBtnColor: pelRed,
            title: "Error!",
            text: "You must be a ${tournament.type} student to register in this tournament!"
        );
      }
    }
  }

  Future<void> registerTournament(Team team) async {
    await AuthService.getAuthToken().then((_) async {
      await http.post(Uri.parse("$API_HOST/api/tournaments/${tournament.id}/teams/${team.id}"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          setState(() {
            teamList.add(team);
            registeredTeam = team;
            registering = false;
            registered = true;
          });
          CoolAlert.show(
              context: context,
              type: CoolAlertType.success,
              borderRadius: 8,
              width: 300,
              confirmBtnColor: pelGreen,
              title: "Success!",
              text: "Your team has been registered successfully! Don't forget to grab your Battlefy code and register your team through the Battlefy link in the tournament description."
          );
        }
        else {
          CoolAlert.show(
              context: context,
              type: CoolAlertType.error,
              borderRadius: 8,
              width: 300,
              confirmBtnColor: pelRed,
              title: "Error getting teams!",
              text: jsonDecode(value.body)["data"]["message"]
          );
        }
      });
    });
  }

  Future<void> getTournamentCode() async {
    await AuthService.getAuthToken().then((_) async {
      await http.get(Uri.parse("$API_HOST/api/tournaments/${tournament.id}/codes"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          if (jsonDecode(value.body)["data"].toString().length < 12) {
            setState(() {
              battlefyCode = jsonDecode(value.body)["data"];
            });
          }
          else {
            CoolAlert.show(
                context: context,
                type: CoolAlertType.error,
                borderRadius: 8,
                width: 300,
                confirmBtnColor: pelRed,
                title: "Error!",
                text: jsonDecode(value.body)["data"]
            );
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

  String getGameImage() {
    if (tournament.game == "VALORANT") {
      return "images/valorant_logo.png";
    }
    else if (tournament.game == "League of Legends") {
      return "images/league_logo.png";
    }
    else if (tournament.game == "Overwatch") {
      return "images/ow_logo.png";
    }
    else if (tournament.game == "Rocket League") {
      return "images/rocket_league_logo.png";
    }
    else if (tournament.game == "Splitgate") {
      return "images/splitgate_logo.png";
    }
    else {
      return "images/logos/icon/mark-color.png";
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
                                  onPressed: () => router.navigateTo(context, "/tournaments", transition: TransitionType.fadeIn),
                                  child: Text("Back to Tournaments", style: TextStyle(fontFamily: "Ubuntu", color: pelBlue),),
                                ),
                              ],
                            ),
                          ),
                          tournament.id != null ? new Container(
                            width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                            padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Card(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Text(
                                            "${tournament.name}",
                                            style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                          ),
                                          Padding(padding: EdgeInsets.all(8),),
                                          Image.asset(
                                            getGameImage(),
                                            height: 100,
                                            width: 100,
                                          ),
                                          Padding(padding: EdgeInsets.all(8),),
                                          Text(
                                            "${tournament.game}  •  ${tournament.type! == "HIGH_SCHOOL" ? "High School" : tournament.type! == "COLLEGE" ? "College" : "College/HS"}  •  Division ${tournament.division}",
                                            style: TextStyle(fontSize: 20, color: currTextColor),
                                          ),
                                          Padding(padding: EdgeInsets.all(8),),
                                          MarkdownBody(
                                            data: tournament.desc!,
                                            shrinkWrap: true,
                                            onTapLink: (String text, String? href, String title) {
                                              launch(href!);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(8),),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Card(
                                        child: Container(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Schedule",
                                                style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                              ),
                                              Padding(padding: EdgeInsets.all(8),),
                                              ListTile(
                                                title: Text(
                                                  "Season: ",
                                                  style: TextStyle(color: currTextColor),
                                                ),
                                                trailing: Text(
                                                  "${DateFormat("yMMMd").format(tournament.seasonStart!)} – ${DateFormat("yMMMd").format(tournament.seasonEnd!)}",
                                                  style: TextStyle(color: currTextColor),
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  "Playoffs Start: ",
                                                  style: TextStyle(color: currTextColor),
                                                ),
                                                trailing: Text(
                                                  "${DateFormat("yMMMd").format(tournament.playoffStart!)}",
                                                  style: TextStyle(color: currTextColor),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(8),),
                                      Card(
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 100),
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Registration",
                                                style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                              ),
                                              Padding(padding: EdgeInsets.all(8),),
                                              ListTile(
                                                title: Text(
                                                  "Registration: ",
                                                  style: TextStyle(color: currTextColor),
                                                ),
                                                trailing: Text(
                                                  "${DateFormat("yMMMd").format(tournament.registrationStart!)} – ${DateFormat("yMMMd").format(tournament.registrationEnd!)}",
                                                  style: TextStyle(color: currTextColor),
                                                ),
                                              ),
                                              Padding(padding: EdgeInsets.all(8),),
                                              Visibility(
                                                visible: !registered && DateTime.now().isBefore(tournament.registrationStart!),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: CupertinoButton(
                                                    child: Text("Registration hasn't started yet!", style: TextStyle(fontFamily: "Ubuntu", color: pelBlue),),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: !registered && !registering && DateTime.now().isBefore(tournament.registrationEnd!) && DateTime.now().isAfter(tournament.registrationStart!),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: CupertinoButton(
                                                    child: Text("Register", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                    color: pelBlue,
                                                    onPressed: () {
                                                      handleRegistration();
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: !registered && registering,
                                                child: Container(
                                                  width: double.infinity,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Select team to register:",
                                                        style: TextStyle(color: currTextColor, fontSize: 20),
                                                      ),
                                                      Padding(padding: EdgeInsets.all(4)),
                                                      Column(
                                                        children: registerTeams.map((team) => Container(
                                                          child: Card(
                                                            child: InkWell(
                                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                                              onTap: () {
                                                                registerTournament(team);
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.all(8),
                                                                child: Row(
                                                                  children: [
                                                                    ExtendedImage.network(
                                                                      "$PROXY_HOST/${team.logoUrl!}",
                                                                      height: 75,
                                                                      width: 75,
                                                                    ),
                                                                    Padding(padding: EdgeInsets.all(16)),
                                                                    Expanded(
                                                                      child: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            "${team.name!}",
                                                                            style: TextStyle(color: currTextColor, fontSize: 20),
                                                                          ),
                                                                          Padding(padding: EdgeInsets.all(2)),
                                                                          Text(
                                                                            "Team ${team.id}",
                                                                            style: TextStyle(color: currDividerColor, fontSize: 16),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )).toList(),
                                                      ),
                                                      Text(
                                                        "Don't see your team? You must be a Team Captain to register for tournaments.",
                                                        style: TextStyle(color: currTextColor, fontSize: 16),
                                                      ),
                                                    ],
                                                  )
                                                )
                                              ),
                                              Visibility(
                                                visible: !registered && DateTime.now().isAfter(tournament.registrationEnd!),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: CupertinoButton(
                                                    child: Text("Registration closed!", style: TextStyle(fontFamily: "Ubuntu", color: pelRed),),
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: registered,
                                                child: Container(
                                                  width: double.infinity,
                                                  child: CupertinoButton(
                                                    child: Text("Registered", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                    color: pelGreen,
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: registered,
                                                child: Container(
                                                  width: double.infinity,
                                                  child: Card(
                                                    child: Container(
                                                      padding: EdgeInsets.all(8),
                                                      child: Row(
                                                        children: [
                                                          ExtendedImage.network(
                                                            "$PROXY_HOST/${registeredTeam.logoUrl}",
                                                            height: 75,
                                                            width: 75,
                                                          ),
                                                          Padding(padding: EdgeInsets.all(16)),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "${registeredTeam.name}",
                                                                  style: TextStyle(color: currTextColor, fontSize: 20),
                                                                ),
                                                                Padding(padding: EdgeInsets.all(2)),
                                                                Text(
                                                                  "Team ${registeredTeam.id}",
                                                                  style: TextStyle(color: currDividerColor, fontSize: 16),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: registered && currUser.roles.contains("${registeredTeam.id}-CAPTAIN"),
                                                child: Container(
                                                  width: double.infinity,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        battlefyCode != "_ _ _ _ _ _ _" ? "Don't forget to register on Battlefy with the code below!"
                                                        : "Click the button below to get your Battlefy code!",
                                                        style: TextStyle(color: currTextColor, fontSize: 16),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: SelectableText(
                                                              battlefyCode,
                                                              style: TextStyle(color: currTextColor, fontSize: 35),
                                                            ),
                                                          ),
                                                          CupertinoButton(
                                                            padding: EdgeInsets.all(16),
                                                            child: Text("Get Code", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                            color: pelBlue,
                                                            onPressed: () {
                                                              getTournamentCode();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ) : LoadingPage(),
                          new Container(
                            width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                            padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      "Teams",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Column(
                                      children: teamList.map((team) => Container(
                                        child: Card(
                                          child: InkWell(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            onTap: () {
                                              if (currUser.roles.contains("ADMIN")) {
                                                router.navigateTo(context, "/teams/${team.id}", transition: TransitionType.fadeIn);
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  ExtendedImage.network(
                                                    "$PROXY_HOST/${team.logoUrl!}",
                                                    height: 75,
                                                    width: 75,
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "${team.name!}",
                                                          style: TextStyle(color: currTextColor, fontSize: 20),
                                                        ),
                                                        Padding(padding: EdgeInsets.all(2)),
                                                        Text(
                                                          "Team ${team.id}",
                                                          style: TextStyle(color: currDividerColor, fontSize: 16),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Visibility(
                                                      visible: currUser.roles.contains("ADMIN"),
                                                      child: CupertinoButton(
                                                        child: Text("Remove", style: TextStyle(color: pelRed, fontFamily: "Ubuntu"),),
                                                        onPressed: () {
                                                          CoolAlert.show(
                                                              context: context,
                                                              type: CoolAlertType.confirm,
                                                              borderRadius: 8,
                                                              onConfirmBtnTap: () {
                                                                removeTournamentTeam(team);
                                                                router.pop(context);
                                                              },
                                                              width: 300,
                                                              confirmBtnColor: pelBlue,
                                                              title: "Are you sure?",
                                                              text: "Are you sure you want to remove this team"
                                                          );
                                                        },
                                                      )
                                                  ),
                                                  Visibility(
                                                      visible: currUser.roles.contains("ADMIN"),
                                                      child: Icon(Icons.arrow_forward_ios, color: currDividerColor,)
                                                  )
                                                ],
                                              ),
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