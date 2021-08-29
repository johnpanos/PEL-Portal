import 'dart:convert';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class ManageUsersPage extends StatefulWidget {
  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {

  List<User> userList = [];

  @override
  void initState() {
    super.initState();
    fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        AuthService.getUser(user.uid).then((_) {
          setState(() {});
          if (currUser.roles.contains("ADMIN")) {
            getUsers();
          }
        });
      }
      else {
        router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
      }
    });
  }

  void getUsers() async {
    await AuthService.getAuthToken().then((_) async {
      await http.get(Uri.parse("$API_HOST/api/users"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          var userJson = jsonDecode(value.body)["data"];
          userList.clear();
          for (int i = 0; i < userJson.length; i++) {
            setState(() {
              userList.add(new User.fromJson(userJson[i]));
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CupertinoButton(
                                  onPressed: () => router.navigateTo(context, "/", transition: TransitionType.fadeIn),
                                  child: Text("Back to Home", style: TextStyle(fontFamily: "Ubuntu", color: pelBlue),),
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
                                    Text(
                                      "Manage Users (${userList.length})",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Container(
                                      height: MediaQuery.of(context).size.height - 320,
                                      child: ListView.builder(
                                        itemCount: userList.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return ExpansionTile(
                                            title: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.all(Radius.circular(100)),
                                                        child: ExtendedImage.network(
                                                          "$PROXY_HOST/${userList[index].profilePicture!}",
                                                          height: 75,
                                                          width: 75,
                                                        ),
                                                      ),
                                                      Padding(padding: EdgeInsets.all(16)),
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SelectableText(
                                                            "${userList[index].firstName!} ${userList[index].lastName!}",
                                                            style: TextStyle(color: currTextColor, fontSize: 20),
                                                          ),
                                                          Padding(padding: EdgeInsets.all(2)),
                                                          SelectableText(
                                                            "${userList[index].email!}",
                                                            style: TextStyle(color: currDividerColor, fontSize: 16),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible: userList[index].verification!.status == "VERIFIED",
                                                    child: Tooltip(
                                                      message: "User Verified",
                                                      child: Icon(Icons.check_circle, color: pelGreen,)
                                                    )
                                                  )
                                                ],
                                              ),
                                            ),
                                            children: [
                                              ListTile(
                                                title: SelectableText("Gender", style: TextStyle(color: currTextColor),),
                                                trailing: SelectableText("${userList[index].gender}", style: TextStyle(color: currTextColor),),
                                              ),
                                              ListTile(
                                                title: SelectableText("School", style: TextStyle(color: currTextColor),),
                                                trailing: SelectableText("${userList[index].school}", style: TextStyle(color: currTextColor),),
                                              ),
                                              ListTile(
                                                title: SelectableText("Grad Year", style: TextStyle(color: currTextColor),),
                                                trailing: SelectableText("${userList[index].gradYear}", style: TextStyle(color: currTextColor),),
                                              ),
                                              ListTile(
                                                title: SelectableText("Verification", style: TextStyle(color: currTextColor),),
                                                trailing: Container(
                                                  width: 300,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      SelectableText("${userList[index].verification?.status}", style: TextStyle(color: currTextColor),),
                                                      Visibility(
                                                        visible: userList[index].verification?.status == "VERIFIED" || userList[index].verification?.status == "UPLOADED",
                                                        child: CupertinoButton(
                                                          child: Text("View", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                          color: pelGreen,
                                                          onPressed: () => launch(userList[index].verification!.fileUrl!),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ExpansionTile(
                                                title: SelectableText("Connections", style: TextStyle(color: currTextColor),),
                                                children: [
                                                  ListTile(
                                                    title: SelectableText("Discord Tag", style: TextStyle(color: currTextColor),),
                                                    trailing: SelectableText("${userList[index].connections?.discordTag}", style: TextStyle(color: currTextColor),),
                                                  ),
                                                  ListTile(
                                                    title: SelectableText("Steam ID", style: TextStyle(color: currTextColor),),
                                                    trailing: SelectableText("${userList[index].connections?.steamId?.split("/id/")[1]}", style: TextStyle(color: currTextColor),),
                                                  ),
                                                  ListTile(
                                                    title: SelectableText("Valorant ID", style: TextStyle(color: currTextColor),),
                                                    trailing: SelectableText("${userList[index].connections?.valorantId}", style: TextStyle(color: currTextColor),),
                                                  ),
                                                  ListTile(
                                                    title: SelectableText("League of Legends ID", style: TextStyle(color: currTextColor),),
                                                    trailing: SelectableText("${userList[index].connections?.leagueId}", style: TextStyle(color: currTextColor),),
                                                  ),
                                                  ListTile(
                                                    title: SelectableText("Battle Tag", style: TextStyle(color: currTextColor),),
                                                    trailing: SelectableText("${userList[index].connections?.battleTag}", style: TextStyle(color: currTextColor),),
                                                  ),
                                                  ListTile(
                                                    title: SelectableText("Rocket ID", style: TextStyle(color: currTextColor),),
                                                    trailing: SelectableText("${userList[index].connections?.rocketId}", style: TextStyle(color: currTextColor),),
                                                  ),
                                                ],
                                              ),
                                              ListTile(
                                                title: SelectableText("Last Updated", style: TextStyle(color: currTextColor),),
                                                trailing: SelectableText("${DateFormat().format(userList[index].updatedAt!)}", style: TextStyle(color: currTextColor),),
                                              ),
                                              ListTile(
                                                title: SelectableText("Account Created", style: TextStyle(color: currTextColor),),
                                                trailing: SelectableText("${DateFormat().format(userList[index].createdAt!)}", style: TextStyle(color: currTextColor),),
                                              )
                                            ],
                                          );
                                        },
                                      ),
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
          body: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new Container(
                      padding: new EdgeInsets.only(left: 8, right: 8, top: 8),
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(
                                "Manage Users (${userList.length})",
                                style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              Padding(padding: EdgeInsets.all(8),),
                              Container(
                                height: MediaQuery.of(context).size.height - 175,
                                child: ListView.builder(
                                  itemCount: userList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return ExpansionTile(
                                      title: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.all(Radius.circular(100)),
                                                  child: ExtendedImage.network(
                                                    "$PROXY_HOST/${userList[index].profilePicture!}",
                                                    height: 65,
                                                    width: 65,
                                                  ),
                                                ),
                                                Padding(padding: EdgeInsets.all(8)),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SelectableText(
                                                      "${userList[index].firstName!} ${userList[index].lastName!}",
                                                      style: TextStyle(color: currTextColor, fontSize: 20),
                                                    ),
                                                    Padding(padding: EdgeInsets.all(2)),
                                                    SelectableText(
                                                      "${userList[index].email!}",
                                                      style: TextStyle(color: currDividerColor, fontSize: 16),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                                visible: userList[index].verification!.status == "VERIFIED",
                                                child: Tooltip(
                                                    message: "User Verified",
                                                    child: Icon(Icons.check_circle, color: pelGreen,)
                                                )
                                            )
                                          ],
                                        ),
                                      ),
                                      children: [
                                        ListTile(
                                          title: SelectableText("Gender", style: TextStyle(color: currTextColor),),
                                          trailing: SelectableText("${userList[index].gender}", style: TextStyle(color: currTextColor),),
                                        ),
                                        ListTile(
                                          title: SelectableText("School", style: TextStyle(color: currTextColor),),
                                          trailing: SelectableText("${userList[index].school}", style: TextStyle(color: currTextColor),),
                                        ),
                                        ListTile(
                                          title: SelectableText("Grad Year", style: TextStyle(color: currTextColor),),
                                          trailing: SelectableText("${userList[index].gradYear}", style: TextStyle(color: currTextColor),),
                                        ),
                                        ListTile(
                                          title: SelectableText("Verification", style: TextStyle(color: currTextColor),),
                                          trailing: Container(
                                            width: MediaQuery.of(context).size.width / 2,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                SelectableText("${userList[index].verification?.status}", style: TextStyle(color: currTextColor),),
                                                Visibility(
                                                  visible: userList[index].verification?.status == "VERIFIED" || userList[index].verification?.status == "UPLOADED",
                                                  child: CupertinoButton(
                                                    child: Text("View", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                    color: pelGreen,
                                                    onPressed: () => launch(userList[index].verification!.fileUrl!),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        ExpansionTile(
                                          title: SelectableText("Connections", style: TextStyle(color: currTextColor),),
                                          children: [
                                            ListTile(
                                              title: SelectableText("Discord Tag", style: TextStyle(color: currTextColor),),
                                              trailing: SelectableText("${userList[index].connections?.discordTag}", style: TextStyle(color: currTextColor),),
                                            ),
                                            ListTile(
                                              title: SelectableText("Steam ID", style: TextStyle(color: currTextColor),),
                                              trailing: SelectableText("${userList[index].connections?.steamId?.split("/id/")[1]}", style: TextStyle(color: currTextColor),),
                                            ),
                                            ListTile(
                                              title: SelectableText("Valorant ID", style: TextStyle(color: currTextColor),),
                                              trailing: SelectableText("${userList[index].connections?.valorantId}", style: TextStyle(color: currTextColor),),
                                            ),
                                            ListTile(
                                              title: SelectableText("League of Legends ID", style: TextStyle(color: currTextColor),),
                                              trailing: SelectableText("${userList[index].connections?.leagueId}", style: TextStyle(color: currTextColor),),
                                            ),
                                            ListTile(
                                              title: SelectableText("Battle Tag", style: TextStyle(color: currTextColor),),
                                              trailing: SelectableText("${userList[index].connections?.battleTag}", style: TextStyle(color: currTextColor),),
                                            ),
                                            ListTile(
                                              title: SelectableText("Rocket ID", style: TextStyle(color: currTextColor),),
                                              trailing: SelectableText("${userList[index].connections?.rocketId}", style: TextStyle(color: currTextColor),),
                                            ),
                                          ],
                                        ),
                                        ListTile(
                                          title: SelectableText("Last Updated", style: TextStyle(color: currTextColor),),
                                          trailing: SelectableText("${DateFormat().format(userList[index].updatedAt!)}", style: TextStyle(color: currTextColor),),
                                        ),
                                        ListTile(
                                          title: SelectableText("Account Created", style: TextStyle(color: currTextColor),),
                                          trailing: SelectableText("${DateFormat().format(userList[index].createdAt!)}", style: TextStyle(color: currTextColor),),
                                        )
                                      ],
                                    );
                                  },
                                ),
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
