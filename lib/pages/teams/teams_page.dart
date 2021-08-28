import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/header.dart';
import 'package:pel_portal/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {

  List<Team> teamList = [];

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
                              children: [
                                CupertinoButton(
                                  onPressed: () => router.navigateTo(context, "/", transition: TransitionType.fadeIn),
                                  child: Text("Back to Home", style: TextStyle(fontFamily: "Ubuntu", color: pelBlue),),
                                )
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
                                    Text(
                                      "Create Team",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
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
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      ExtendedImage.network(
                                                        team.logoUrl!,
                                                        height: 100,
                                                        width: 100,
                                                      ),
                                                      Padding(padding: EdgeInsets.all(16)),
                                                      Column(
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
                                                      Padding(padding: EdgeInsets.all(32)),
                                                      Text(
                                                        team.game!,
                                                        style: TextStyle(color: currTextColor, fontSize: 20),
                                                      ),
                                                      Padding(padding: EdgeInsets.all(16)),
                                                      Card(
                                                        color: pelGreen,
                                                        child: Container(
                                                          padding: EdgeInsets.all(8),
                                                          child: Text("Team Captain", style: TextStyle(color: Colors.white, fontSize: 16),),
                                                        ),
                                                      )
                                                    ],
                                                  ),
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