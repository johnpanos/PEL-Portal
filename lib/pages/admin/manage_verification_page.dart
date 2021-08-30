import 'dart:convert';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:easy_web_view2/easy_web_view2.dart';
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

class ManageVerificationPage extends StatefulWidget {
  @override
  _ManageVerificationPageState createState() => _ManageVerificationPageState();
}

class _ManageVerificationPageState extends State<ManageVerificationPage> {

  List<User> userList = [];

  static ValueKey key = ValueKey('key_0');

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
            User user = new User.fromJson(userJson[i]);
            if (user.verification?.status == "UPLOADED") {
              setState(() {
                userList.add(user);
              });
            }
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

  void updateUser(User user) async {
    await AuthService.getAuthToken().then((_) async {
      await http.post(Uri.parse("$API_HOST/api/users"), body: jsonEncode(user), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {

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
    if (currUser.id != null && currUser.roles.contains("ADMIN")) {
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
                                      "Verification Requests (${userList.length})",
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
                                                ],
                                              ),
                                            ),
                                            children: [
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
                                                  width: 500,
                                                  height: 100,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed: ()  {
                                                            launch(userList[index].verification!.fileUrl!);
                                                          },
                                                          child: Container(
                                                            height: 100,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Icon(Icons.launch, color: pelBlue,),
                                                                Padding(padding: EdgeInsets.all(4)),
                                                                Text("View File", style: TextStyle(fontSize: 16, color: pelBlue),)
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(padding: EdgeInsets.all(2)),
                                                      Expanded(
                                                        child: CupertinoButton(
                                                          padding: EdgeInsets.zero,
                                                          child: Text("Deny", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                          color: pelRed,
                                                          onPressed: () {
                                                            userList[index].verification!.status = "null";
                                                            updateUser(userList[index]);
                                                            setState(() {
                                                              userList.removeAt(index);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      Padding(padding: EdgeInsets.all(2)),
                                                      Expanded(
                                                        child: CupertinoButton(
                                                          padding: EdgeInsets.zero,
                                                          child: Text("Approve", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                          color: pelGreen,
                                                          onPressed: () {
                                                            userList[index].verification!.status = "VERIFIED";
                                                            updateUser(userList[index]);
                                                            setState(() {
                                                              userList.removeAt(index);
                                                            });
                                                          }
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Container(
                                              //   height: MediaQuery.of(context).size.height / 2,
                                              //   width: MediaQuery.of(context).size.width / 2,
                                              //   child: Stack(
                                              //     children: [
                                              //       EasyWebView(
                                              //         headers: { "Content-Type": "text/html" },
                                              //         src: userList[index].verification!.fileUrl!,
                                              //         onLoaded: () {
                                              //           print('$key: Loaded: ${userList[index].verification!.fileUrl!}');
                                              //         },
                                              //         key: key
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),
                                              ListTile(
                                                title: SelectableText("Verification Submitted", style: TextStyle(color: currTextColor),),
                                                trailing: SelectableText("${DateFormat().format(userList[index].verification!.createdAt!)}", style: TextStyle(color: currTextColor),),
                                              ),
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
                                "Verification Requests (${userList.length})",
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
                                          ],
                                        ),
                                      ),
                                      children: [
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
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: ()  {
                                                      launch(userList[index].verification!.fileUrl!);
                                                    },
                                                    child: Container(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.launch, color: pelBlue,),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(padding: EdgeInsets.all(2)),
                                                Expanded(
                                                  child: CupertinoButton(
                                                    padding: EdgeInsets.zero,
                                                    child: Text("Deny", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                    color: pelRed,
                                                    onPressed: () {
                                                      userList[index].verification!.status = "null";
                                                      updateUser(userList[index]);
                                                      setState(() {
                                                        userList.removeAt(index);
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Padding(padding: EdgeInsets.all(2)),
                                                Expanded(
                                                  child: CupertinoButton(
                                                      padding: EdgeInsets.zero,
                                                      child: Text("Approve", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                                      color: pelGreen,
                                                      onPressed: () {
                                                        userList[index].verification!.status = "VERIFIED";
                                                        updateUser(userList[index]);
                                                        setState(() {
                                                          userList.removeAt(index);
                                                        });
                                                      }
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: SelectableText("Verification Submitted", style: TextStyle(color: currTextColor),),
                                          trailing: SelectableText("${DateFormat().format(userList[index].verification!.createdAt!)}", style: TextStyle(color: currTextColor),),
                                        ),
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
