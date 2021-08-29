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
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:pel_portal/utils/game_data.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/header.dart';
import 'package:pel_portal/widgets/loading.dart';
import 'package:pel_portal/widgets/sidebar.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {

  List<Team> teamList = [];

  bool creating = false;
  Team newTeam = new Team();
  bool uploadingLogo = false;
  bool loading = false;

  String joinTeamId = "";

  @override
  void initState() {
    super.initState();
    fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        AuthService.getUser(user.uid).then((_) {
          setState(() {});
          getTeams();
        });
      }
      else {
        router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
      }
    });
  }

  Future<void> getTeams() async {
    await AuthService.getAuthToken().then((_) async {
      await http.get(Uri.parse("$API_HOST/api/users/${currUser.id}/teams"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          var teamsJson = jsonDecode(value.body)["data"];
          for (int i = 0; i < teamsJson.length; i++) {
            setState(() {
              teamList.add(Team.fromJson(teamsJson[i]));
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

  Future<void> joinTeam() async {
    await AuthService.getAuthToken().then((_) async {
      await http.get(Uri.parse("$API_HOST/api/teams/$joinTeamId"), headers: {"Authorization": authToken}).then((value) async {
        if (value.statusCode == 200) {
          await AuthService.getAuthToken().then((_) async {
            await http.post(Uri.parse("$API_HOST/api/users/${currUser.id}/teams/$joinTeamId"), headers: {"Authorization": authToken}).then((value) async {
              if (value.statusCode == 200) {
                router.navigateTo(context, "/teams", transition: TransitionType.fadeIn, replace: true);
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

  Future<void> selectLogo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select Logo",
      type: FileType.custom,
      allowedExtensions: ['png'],
    );
    if (result != null) {
      try {
        Uint8List fileBytes = result.files.first.bytes!;
        String fileName = result.files.first.name;
        setState(() {
          uploadingLogo = true;
        });
        await FirebaseStorage.instance.ref('teams/logos/$fileName').putData(fileBytes).then((snapshot) async {
          newTeam.logoUrl = await snapshot.ref.getDownloadURL();
          setState(() {});
        });
      } catch (e) {
        print(e);
        CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            borderRadius: 8,
            width: 300,
            confirmBtnColor: pelRed,
            title: "Error!",
            text: e.toString()
        );
      }
      setState(() {
        uploadingLogo = false;
      });
    }
  }

  Future<void> createTeam() async {
    setState(() {
      loading = true;
    });
    if (newTeam.name != "" && !newTeam.name!.contains("'")) {
      newTeam.createdAt = DateTime.now();
      newTeam.updatedAt = DateTime.now();
      await AuthService.getAuthToken().then((_) async {
        await http.post(Uri.parse("$API_HOST/api/teams"), body: jsonEncode(newTeam), headers: {"Authorization": authToken}).then((value) async {
          if (value.statusCode == 200) {
            setState(() {
              newTeam = new Team.fromJson(jsonDecode(value.body)["data"]);
            });
            await AuthService.getAuthToken().then((_) async {
              await http.post(Uri.parse("$API_HOST/api/users/${currUser.id}/teams/${newTeam.id}"), headers: {"Authorization": authToken}).then((value) async {
                if (value.statusCode == 200) {
                  currUser.roles.add("${newTeam.id}-CAPTAIN");
                  await AuthService.getAuthToken().then((_) async {
                    await http.post(Uri.parse("$API_HOST/api/users"), body: jsonEncode(currUser), headers: {"Authorization": authToken}).then((value) {
                      print(value.body);
                      if (value.statusCode == 200) {
                        router.navigateTo(context, "/teams/${newTeam.id}", transition: TransitionType.fadeIn);
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
    else {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          borderRadius: 8,
          width: 300,
          confirmBtnColor: pelRed,
          title: "Error!",
          text: "Team name cannot be empty or contain the character \" ' \""
      );
    }
    setState(() {
      loading = false;
    });
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
                                  onPressed: () => router.navigateTo(context, "/", transition: TransitionType.fadeIn),
                                  child: Text("Back to Home", style: TextStyle(fontFamily: "Ubuntu", color: pelBlue),),
                                ),
                                Visibility(
                                  visible: !creating,
                                  child: CupertinoButton(
                                    color: pelBlue,
                                    child: Text("Create Team", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                    onPressed: () {
                                      setState(() {
                                        creating = true;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          new AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                            height: creating ? null : 0,
                            padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      "Create Team",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    uploadingLogo ? Container(
                                      padding: EdgeInsets.all(32),
                                      child: HeartbeatProgressIndicator(
                                        child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
                                      ),
                                    ) : ExtendedImage.network(
                                      "$PROXY_HOST/${newTeam.logoUrl}",
                                      width: 200,
                                      height: 200,
                                    ),
                                    Padding(padding: EdgeInsets.all(4),),
                                    CupertinoButton(
                                      child: Text("Edit Logo", style: TextStyle(fontFamily: "Ubuntu", color: pelBlue),),
                                      onPressed: () {
                                        selectLogo();
                                      },
                                    ),
                                    Padding(padding: EdgeInsets.all(16),),
                                    Row(
                                      children: [
                                        new Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: "Team Name",
                                              border: OutlineInputBorder()
                                            ),
                                            onChanged: (input) {
                                              newTeam.name = input;
                                            },
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(16),),
                                        Text("Game:", style: TextStyle(color: currTextColor, fontSize: 16),),
                                        Padding(padding: EdgeInsets.all(8),),
                                        new Expanded(
                                          child: new DropdownButton(
                                            value: newTeam.game,
                                            items: games.map((e) => DropdownMenuItem(
                                              child: Text(e),
                                              value: e,
                                            )).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                newTeam.game = value.toString();
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.all(16),),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CupertinoButton(
                                            color: pelRed,
                                            padding: EdgeInsets.zero,
                                            child: Text("Cancel", style: TextStyle(fontFamily: "Ubuntu"),),
                                            onPressed: () {
                                              setState(() {
                                                creating = false;
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(4)),
                                        Expanded(
                                          child: loading ? Container(
                                            padding: EdgeInsets.all(32),
                                            child: HeartbeatProgressIndicator(
                                              child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
                                            ),
                                          ) : CupertinoButton(
                                            color: pelBlue,
                                            padding: EdgeInsets.zero,
                                            child: Text("Create", style: TextStyle(fontFamily: "Ubuntu")),
                                            onPressed: () {
                                              createTeam();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                                    Text(
                                      "My Teams",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Column(
                                      children: teamList.map((team) => Container(
                                        child: Card(
                                          child: InkWell(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            onTap: () {
                                              router.navigateTo(context, "/teams/${team.id}", transition: TransitionType.fadeIn);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  ExtendedImage.network(
                                                    "$PROXY_HOST/${team.logoUrl!}",
                                                    height: 100,
                                                    width: 100,
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          team.name!,
                                                          style: TextStyle(color: currTextColor, fontSize: 20),
                                                        ),
                                                        Padding(padding: EdgeInsets.all(2)),
                                                        Text(
                                                          "Team ${team.id!}",
                                                          style: TextStyle(color: currDividerColor, fontSize: 16),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      team.game!,
                                                      style: TextStyle(color: currTextColor, fontSize: 20),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Visibility(
                                                      visible: currUser.roles.contains("${team.id}-CAPTAIN"),
                                                      child: Card(
                                                        color: pelGreen,
                                                        child: Container(
                                                          padding: EdgeInsets.all(8),
                                                          child: Text("Team Captain", style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center,),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Container(
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
                          new Container(
                            width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                            padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      "Join Team",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: "Team Number",
                                              border: OutlineInputBorder()
                                            ),
                                            onChanged: (input) {
                                              joinTeamId = input;
                                            },
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                        CupertinoButton(
                                          color: pelBlue,
                                          child: Text("Join", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                          onPressed: () {
                                            joinTeam();
                                          },
                                        )
                                      ],
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
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset("images/logos/abbrev/abbrev-mono.png", height: 40,),
                Text(
                  "PORTAL",
                  style: TextStyle(fontFamily: "Karla", fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            centerTitle: true,
          ),
          backgroundColor: currBackgroundColor,
          floatingActionButton: Visibility(
            visible: !creating,
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  creating = true;
                });
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      height: creating ? null : 0,
                      padding: new EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                "Create Team",
                                style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(8),),
                              uploadingLogo ? Container(
                                padding: EdgeInsets.all(32),
                                child: HeartbeatProgressIndicator(
                                  child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
                                ),
                              ) : ExtendedImage.network(
                                "$PROXY_HOST/${newTeam.logoUrl}",
                                width: 200,
                                height: 200,
                              ),
                              Padding(padding: EdgeInsets.all(4),),
                              CupertinoButton(
                                child: Text("Edit Logo", style: TextStyle(fontFamily: "Ubuntu", color: pelBlue),),
                                onPressed: () {
                                  selectLogo();
                                },
                              ),
                              Padding(padding: EdgeInsets.all(8),),
                              TextField(
                                decoration: InputDecoration(
                                    hintText: "Team Name",
                                    border: OutlineInputBorder()
                                ),
                                onChanged: (input) {
                                  newTeam.name = input;
                                },
                              ),
                              Padding(padding: EdgeInsets.all(8),),
                              Row(
                                children: [
                                  Text("Game:", style: TextStyle(color: currTextColor, fontSize: 16),),
                                  Padding(padding: EdgeInsets.all(8),),
                                  new Expanded(
                                    child: new DropdownButton(
                                      value: newTeam.game,
                                      items: games.map((e) => DropdownMenuItem(
                                        child: Text(e),
                                        value: e,
                                      )).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          newTeam.game = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(padding: EdgeInsets.all(8),),
                              Row(
                                children: [
                                  Expanded(
                                    child: CupertinoButton(
                                      color: pelRed,
                                      padding: EdgeInsets.zero,
                                      child: Text("Cancel", style: TextStyle(fontFamily: "Ubuntu"),),
                                      onPressed: () {
                                        setState(() {
                                          creating = false;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.all(4)),
                                  Expanded(
                                    child: loading ? Container(
                                      padding: EdgeInsets.all(32),
                                      child: HeartbeatProgressIndicator(
                                        child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
                                      ),
                                    ) : CupertinoButton(
                                      color: pelBlue,
                                      padding: EdgeInsets.zero,
                                      child: Text("Create", style: TextStyle(fontFamily: "Ubuntu")),
                                      onPressed: () {
                                        createTeam();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    new Container(
                      padding: new EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                "My Teams",
                                style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(8),),
                              Column(
                                children: teamList.map((team) => Container(
                                  child: Card(
                                    child: InkWell(
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      onTap: () {
                                        router.navigateTo(context, "/teams/${team.id}", transition: TransitionType.native);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            ExtendedImage.network(
                                              "$PROXY_HOST/${team.logoUrl!}",
                                              height: 65,
                                              width: 65,
                                            ),
                                            Padding(padding: EdgeInsets.all(16)),
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    team.name!,
                                                    style: TextStyle(color: currTextColor, fontSize: 20),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(2)),
                                                  Text(
                                                    "Team ${team.id!}",
                                                    style: TextStyle(color: currDividerColor, fontSize: 16),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(4)),
                                                  Visibility(
                                                    visible: currUser.roles.contains("${team.id}-CAPTAIN"),
                                                    child: Card(
                                                      color: pelGreen,
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        child: Text("Team Captain", style: TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center,),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(padding: EdgeInsets.all(8)),
                                            Container(
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
                    new Container(
                      padding: new EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                "Join Team",
                                style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(8),),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                          hintText: "Team Number",
                                          border: OutlineInputBorder()
                                      ),
                                      onChanged: (input) {
                                        joinTeamId = input;
                                      },
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.all(8),),
                                  CupertinoButton(
                                    color: pelBlue,
                                    child: Text("Join", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                    onPressed: () {
                                      joinTeam();
                                    },
                                  )
                                ],
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
        );
      }
    }
    else {
      return LoadingPage();
    }
  }
}