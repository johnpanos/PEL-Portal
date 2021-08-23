import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:http/http.dart' as http;
import 'package:progress_indicators/progress_indicators.dart';

class RegisterPage extends StatefulWidget {
  String token;
  RegisterPage(this.token);
  @override
  _RegisterPageState createState() => _RegisterPageState(this.token);
}

class _RegisterPageState extends State<RegisterPage> {

  String token;
  bool checkingAuth = true;
  bool creatingAccount = false;

  _RegisterPageState(this.token);

  void getDiscordInfo() {
    http.get(Uri.parse("https://discord.com/api/oauth2/@me"), headers: {"Authorization": "Bearer $token"}).then((value) {
      setState(() {
        currUser.connections!.userId = jsonDecode(value.body)["user"]["id"];
        currUser.connections!.discordTag = "${jsonDecode(value.body)["user"]["username"]}#${jsonDecode(value.body)["user"]["discriminator"]}";
        currUser.connections!.discordToken = token;
        currUser.profilePicture = "https://cdn.discordapp.com/avatars/${currUser.connections!.userId}/${jsonDecode(value.body)["user"]["avatar"]}.webp";
      });
      getAuthState();
    });
  }

  void getAuthState() {
    http.post(Uri.parse("${API_HOST.split(PROXY_HOST + "/")[1]}/api/auth/login"), body: jsonEncode({
      "id": currUser.connections!.userId
    })).then((value) {
      fb.FirebaseAuth.instance.setPersistence(fb.Persistence.LOCAL);
      fb.FirebaseAuth.instance.signInWithCustomToken(jsonDecode(value.body)["data"]["token"]).then((value) async {
        if (fb.FirebaseAuth.instance.currentUser != null) {
          print("Signed in with discord token");
          currUser.id = fb.FirebaseAuth.instance.currentUser!.uid;
          currUser.connections!.userId = fb.FirebaseAuth.instance.currentUser!.uid;
          currUser.createdAt = DateTime.now();
          currUser.updatedAt = DateTime.now();
          await AuthService.getAuthToken().then((_) async {
            var response = await http.get(Uri.parse("$API_HOST/api/users/${currUser.id}"), headers: {"Authorization": authToken});
            if (response.statusCode == 200) {
              currUser = new User.fromJson(jsonDecode(response.body)["data"]);
              print("====== USER DEBUG INFO ======");
              print("FIRST NAME: ${currUser.firstName}");
              print("LAST NAME: ${currUser.lastName}");
              print("EMAIL: ${currUser.email}");
              print("====== =============== ======");
              router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
            }
            else {
              print("User does not exist yet, finish creating account");
            }
          });
          setState(() {
            checkingAuth = false;
          });;
        }
      });
    });
  }

  Future<void> createAccount() async {
    setState(() {
      creatingAccount = true;
    });
    try {
      if (currUser.firstName!.isNotEmpty && currUser.lastName!.isNotEmpty && currUser.email!.isNotEmpty && currUser.school!.isNotEmpty && currUser.school!.isNotEmpty && currUser.gradYear != null) {
        await AuthService.getAuthToken().then((_) async {
          await http.post(Uri.parse("$API_HOST/api/users"), body: jsonEncode(currUser), headers: {"Authorization": authToken}).then((value) {
            print(value.body);
            if (value.statusCode == 200) {
              currUser = new User.fromJson(jsonDecode(value.body)["data"]);
              CoolAlert.show(
                  context: context,
                  type: CoolAlertType.success,
                  borderRadius: 8,
                  barrierDismissible: false,
                  onConfirmBtnTap: () {
                    router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
                  },
                  width: 300,
                  confirmBtnColor: pelGreen,
                  title: "Success!",
                  text: "Your account has been created successfully! Welcome to the Pacific Esports League."
              );
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
            text: "Looks like you forgot to fill out some info!"
        );
      }
    } catch (e) {
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
      creatingAccount = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getDiscordInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currBackgroundColor,
      body: Column(
        children: [
          Container(
            color: currCardColor,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      Image.asset("images/logos/abbrev/abbrev-color.png"),
                      Text(
                        "PORTAL",
                        style: TextStyle(fontFamily: "Karla", fontSize: 67, fontWeight: FontWeight.bold, color: currTextColor),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [],
                  ),
                )
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(8)),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: checkingAuth ? Container(
                  padding: EdgeInsets.all(32),
                  child: HeartbeatProgressIndicator(
                    child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
                  ),
                ) : Container(
                  child: Card(
                    child: Container(
                      width: 500,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Create Account", style: TextStyle(fontFamily: "LEMONMILK", fontSize: 35, fontWeight: FontWeight.bold, color: currTextColor),),
                          Padding(padding: EdgeInsets.all(8)),
                          Text("Create your PEL Portal Account below. If you have a school-issued email address, please use that when creating an account.", style: TextStyle(color: currTextColor), textAlign: TextAlign.center),
                          Padding(padding: EdgeInsets.all(8)),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(75)),
                                  child: ExtendedImage.network(
                                    currUser.profilePicture ?? "",
                                    height: 75,
                                  ),
                                ),
                                Padding(padding: EdgeInsets.all(8)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      currUser.connections?.discordTag ?? "",
                                      style: TextStyle(color: currTextColor, fontSize: 25),
                                    ),
                                    Text(
                                      currUser.connections?.userId.toString() ?? "",
                                      style: TextStyle(color: currDividerColor, fontSize: 25),
                                    )
                                  ],
                                ),
                                Padding(padding: EdgeInsets.all(8)),
                                Tooltip(
                                  message: "Discord Verified",
                                  child: Icon(Icons.check_circle, color: pelGreen, size: 25,)
                                )
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(8)),
                          TextField(
                            decoration: InputDecoration(
                              hintText: "First Name",
                              icon: Icon(Icons.person),
                              border: InputBorder.none
                            ),
                            onChanged: (input) {
                              currUser.firstName = input;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(
                                hintText: "Last Name",
                                icon: Icon(Icons.person),
                                border: InputBorder.none
                            ),
                            onChanged: (input) {
                              currUser.lastName = input;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(
                                hintText: "Email",
                                icon: Icon(Icons.mail),
                                border: InputBorder.none
                            ),
                            onChanged: (input) {
                              currUser.email = input;
                            },
                          ),
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
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(4)),
                          Text("I am a student in...", style: TextStyle(color: currTextColor),),
                          Padding(padding: EdgeInsets.all(4)),
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                  child: CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        currUser.roles.remove("COLLEGE");
                                        currUser.roles.add("HIGH_SCHOOL");
                                      });
                                    },
                                    child: Text("High School", style: TextStyle(fontFamily: "Ubuntu", color: currUser.roles.contains("HIGH_SCHOOL") ? Colors.white : currTextColor,),),
                                    color: currUser.roles.contains("HIGH_SCHOOL") ? pelBlue : null,
                                  ),
                                ),
                                Expanded(
                                  child: CupertinoButton(
                                    onPressed: () {
                                      setState(() {
                                        currUser.roles.remove("HIGH_SCHOOL");
                                        currUser.roles.add("COLLEGE");
                                      });
                                    },
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
                            onChanged: (input) {
                              currUser.school = input;
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(
                                hintText: "Graduation Year",
                                icon: Icon(Icons.school),
                                border: InputBorder.none
                            ),
                            onChanged: (input) {
                              currUser.gradYear = int.tryParse(input);
                            },
                          ),
                          Padding(padding: EdgeInsets.all(8)),
                          Container(
                            width: 500,
                            child: creatingAccount ? Container(
                              padding: EdgeInsets.all(32),
                              child: HeartbeatProgressIndicator(
                                child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
                              ),
                            ) : CupertinoButton(
                              onPressed: () {
                                createAccount();
                              },
                              child: Text("Create Account", style: TextStyle(fontFamily: "Ubuntu"),),
                              color: pelBlue,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
