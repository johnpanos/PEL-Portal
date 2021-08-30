import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/header.dart';
import 'package:pel_portal/widgets/loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool edited = false;

  @override
  void initState() {
    super.initState();
    fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        AuthService.getUser(user.uid).then((_) {
          setState(() {
          });
        });
      }
      else {
        router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
      }
    });
  }

  Future<void> updateUser() async {
    await AuthService.getAuthToken().then((_) async {
      await http.post(Uri.parse("$API_HOST/api/users"), body: jsonEncode(currUser), headers: {"Authorization": authToken}).then((value) {
        print(value.body);
        if (value.statusCode == 200) {
          router.navigateTo(context, "/profile", transition: TransitionType.fadeIn, replace: true);
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
                                      "Profile",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(100)),
                                      child: ExtendedImage.network(
                                        currUser.profilePicture!,
                                        height: 100,
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            color: pelGreen,
                                            child: InkWell(
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              onTap: () => launch("https://pacificesports.org/discord"),
                                              child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  child: Center(child: Text("Verified Discord Member", style: TextStyle(color: Colors.white, fontSize: 16)))
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                                hintText: "First Name",
                                                icon: Icon(Icons.person),
                                                border: OutlineInputBorder()
                                            ),
                                            controller: TextEditingController()..text = currUser.firstName!,
                                            onChanged: (input) {
                                              currUser.firstName = input;
                                              setState(() {
                                                edited = true;
                                              });
                                            },
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                                hintText: "Last Name",
                                                icon: Icon(Icons.person),
                                                border: OutlineInputBorder()
                                            ),
                                            controller: TextEditingController()..text = currUser.lastName!,
                                            onChanged: (input) {
                                              currUser.lastName = input;
                                              setState(() {
                                                edited = true;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    TextField(
                                      decoration: InputDecoration(
                                          hintText: "Email",
                                          icon: Icon(Icons.mail),
                                          border: OutlineInputBorder()
                                      ),
                                      controller: TextEditingController()..text = currUser.email!,
                                      onChanged: (input) {
                                        currUser.email = input;
                                        setState(() {
                                          edited = true;
                                        });
                                      },
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    new Row(
                                      children: <Widget>[
                                        new Expanded(
                                          flex: 2,
                                          child: new Text(
                                            "Gender",
                                            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16.0),
                                          ),
                                        ),
                                        new Expanded(
                                          flex: 1,
                                          child: new DropdownButton(
                                            value: currUser.gender,
                                            items: [
                                              DropdownMenuItem(child: new Text("Male"), value: "MALE"),
                                              DropdownMenuItem(child: new Text("Female"), value: "FEMALE"),
                                              DropdownMenuItem(child: new Text("Other"), value: "OTHER"),
                                              DropdownMenuItem(child: new Text("Prefer not to say"), value: "OPT-OUT"),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                currUser.gender = value.toString();
                                                edited = true;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.all(8)),
                                    Text("In order to change any of the following information, please please DM the ModMail bot on Discord or email us at contact@pacificesports.org.", style: TextStyle(color: currTextColor, fontSize: 16),),
                                    Padding(padding: EdgeInsets.all(8)),
                                    Container(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CupertinoButton(
                                              onPressed: () {},
                                              child: Text("High School", style: TextStyle(fontFamily: "Ubuntu", color: currUser.roles.contains("HIGH_SCHOOL") ? Colors.white : currTextColor,),),
                                              color: currUser.roles.contains("HIGH_SCHOOL") ? pelBlue : null,
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoButton(
                                              onPressed: () {},
                                              child: Text("College", style: TextStyle(fontFamily: "Ubuntu", color: currUser.roles.contains("COLLEGE") ? Colors.white : currTextColor),),
                                              color: currUser.roles.contains("COLLEGE") ? pelBlue : null,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(4)),
                                    TextField(
                                      decoration: InputDecoration(
                                          hintText: "School Name",
                                          icon: Icon(Icons.location_city),
                                          border: InputBorder.none
                                      ),
                                      controller: TextEditingController()..text = currUser.school!,
                                      enabled: false,
                                    ),
                                    TextField(
                                      decoration: InputDecoration(
                                          hintText: "Graduation Year",
                                          icon: Icon(Icons.school),
                                          border: InputBorder.none
                                      ),
                                      controller: TextEditingController()..text = currUser.gradYear.toString(),
                                      enabled: false,
                                    ),
                                    Visibility(
                                      visible: edited,
                                      child: Container(
                                        width: 500,
                                        height: 50,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: CupertinoButton(
                                                color: pelRed,
                                                padding: EdgeInsets.zero,
                                                child: Text("Discard Changes", style: TextStyle(fontFamily: "Ubuntu"),),
                                                onPressed: () {
                                                  router.navigateTo(context, "/profile", transition: TransitionType.fadeIn, replace: true);
                                                },
                                              ),
                                            ),
                                            Padding(padding: EdgeInsets.all(4)),
                                            Expanded(
                                              child: CupertinoButton(
                                                color: pelBlue,
                                                padding: EdgeInsets.zero,
                                                child: Text("Save Changes", style: TextStyle(fontFamily: "Ubuntu")),
                                                onPressed: () {
                                                  updateUser();
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
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
                                      "Game Connections",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Row(
                                      children: [
                                        Padding(padding: EdgeInsets.all(8),),
                                        Image.asset("images/steam_logo.png", height: 32, width: 32,),
                                        Padding(padding: EdgeInsets.all(8),),
                                        Expanded(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: "Steam Profile URL",
                                                border: currUser.connections!.steamId != "null" ? InputBorder.none : OutlineInputBorder()
                                            ),
                                            onChanged: (input) {
                                              currUser.connections!.steamId = input;
                                            },
                                            initialValue: currUser.connections!.steamId != "null" ? currUser.connections!.steamId! : null,
                                            enabled: currUser.connections!.steamId == "null",
                                            style: TextStyle(color: currTextColor, fontSize: 16),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                        currUser.connections!.steamId != "null" ? CupertinoButton(
                                          onPressed: () {
                                            currUser.connections!.steamId = "null";
                                            updateUser();
                                          },
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(fontFamily: "Ubuntu", color: pelRed),
                                          ),
                                        ) : CupertinoButton(
                                          onPressed: () {
                                            updateUser();
                                          },
                                          color: pelBlue,
                                          child: Text(
                                            "Add",
                                            style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Row(
                                      children: [
                                        Padding(padding: EdgeInsets.all(8),),
                                        Image.asset("images/valorant_logo.png", height: 32, width: 32,),
                                        Padding(padding: EdgeInsets.all(8),),
                                        Expanded(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              hintText: "Valorant ID",
                                              border: currUser.connections!.valorantId != "null" ? InputBorder.none : OutlineInputBorder()
                                            ),
                                            onChanged: (input) {
                                              currUser.connections!.valorantId = input;
                                            },
                                            initialValue: currUser.connections!.valorantId != "null" ? currUser.connections!.valorantId! : null,
                                            enabled: currUser.connections!.valorantId == "null",
                                            style: TextStyle(color: currTextColor, fontSize: 16),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                        currUser.connections!.valorantId != "null" ? CupertinoButton(
                                          onPressed: () {
                                            currUser.connections!.valorantId = "null";
                                            updateUser();
                                          },
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(fontFamily: "Ubuntu", color: pelRed),
                                          ),
                                        ) : CupertinoButton(
                                          onPressed: () {
                                            updateUser();
                                          },
                                          color: pelBlue,
                                          child: Text(
                                            "Add",
                                            style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Row(
                                      children: [
                                        Padding(padding: EdgeInsets.all(8),),
                                        Image.asset("images/league_logo.png", height: 32, width: 32,),
                                        Padding(padding: EdgeInsets.all(8),),
                                        Expanded(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: "League of Legends ID",
                                                border: currUser.connections!.leagueId != "null" ? InputBorder.none : OutlineInputBorder()
                                            ),
                                            onChanged: (input) {
                                              currUser.connections!.leagueId = input;
                                            },
                                            initialValue: currUser.connections!.leagueId != "null" ? currUser.connections!.leagueId! : null,
                                            enabled: currUser.connections!.leagueId == "null",
                                            style: TextStyle(color: currTextColor, fontSize: 16),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                        currUser.connections!.leagueId != "null" ? CupertinoButton(
                                          onPressed: () {
                                            currUser.connections!.leagueId = "null";
                                            updateUser();
                                          },
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(fontFamily: "Ubuntu", color: pelRed),
                                          ),
                                        ) : CupertinoButton(
                                          onPressed: () {
                                            updateUser();
                                          },
                                          color: pelBlue,
                                          child: Text(
                                            "Add",
                                            style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Row(
                                      children: [
                                        Padding(padding: EdgeInsets.all(8),),
                                        Image.asset("images/ow_logo.png", height: 32, width: 32,),
                                        Padding(padding: EdgeInsets.all(8),),
                                        Expanded(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: "Overwatch Battle Tag",
                                                border: currUser.connections!.battleTag != "null" ? InputBorder.none : OutlineInputBorder()
                                            ),
                                            onChanged: (input) {
                                              currUser.connections!.battleTag = input;
                                            },
                                            initialValue: currUser.connections!.battleTag != "null" ? currUser.connections!.battleTag! : null,
                                            enabled: currUser.connections!.battleTag == "null",
                                            style: TextStyle(color: currTextColor, fontSize: 16),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                        currUser.connections!.battleTag != "null" ? CupertinoButton(
                                          onPressed: () {
                                            currUser.connections!.battleTag = "null";
                                            updateUser();
                                          },
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(fontFamily: "Ubuntu", color: pelRed),
                                          ),
                                        ) : CupertinoButton(
                                          onPressed: () {
                                            updateUser();
                                          },
                                          color: pelBlue,
                                          child: Text(
                                            "Add",
                                            style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Row(
                                      children: [
                                        Padding(padding: EdgeInsets.all(8),),
                                        Image.asset("images/rocket_league_logo.png", height: 32, width: 32,),
                                        Padding(padding: EdgeInsets.all(8),),
                                        Expanded(
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: "Rocket ID",
                                                border: currUser.connections!.rocketId != "null" ? InputBorder.none : OutlineInputBorder()
                                            ),
                                            onChanged: (input) {
                                              currUser.connections!.rocketId = input;
                                            },
                                            initialValue: currUser.connections!.rocketId != "null" ? currUser.connections!.rocketId! : null,
                                            enabled: currUser.connections!.rocketId == "null",
                                            style: TextStyle(color: currTextColor, fontSize: 16),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.all(8),),
                                        currUser.connections!.rocketId != "null" ? CupertinoButton(
                                          onPressed: () {
                                            currUser.connections!.rocketId = "null";
                                            updateUser();
                                          },
                                          child: Text(
                                            "Remove",
                                            style: TextStyle(fontFamily: "Ubuntu", color: pelRed),
                                          ),
                                        ) : CupertinoButton(
                                          onPressed: () {
                                            updateUser();
                                          },
                                          color: pelBlue,
                                          child: Text(
                                            "Add",
                                            style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
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
