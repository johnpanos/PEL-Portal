import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileSidebar extends StatefulWidget {
  @override
  _MobileSidebarState createState() => _MobileSidebarState();
}

class _MobileSidebarState extends State<MobileSidebar> {

  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    getAuthState();
  }

  void getAuthState() {
    fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        setState(() {
          authenticated = true;
        });
      }
      else {
        // not logged
        setState(() {
          authenticated = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: EdgeInsets.all(8),
        color: currCardColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: ExtendedImage.network(
                          currUser.profilePicture!,
                          height: 100,
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(8),),
                      Text(
                        "${currUser.firstName} ${currUser.lastName}",
                        style: TextStyle(fontFamily: "LEMONMILK", fontSize: 20, fontWeight: FontWeight.bold),
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
                                    child: Center(child: Text("Verified Discord Member", style: TextStyle(color: Colors.white)))
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(8),),
                      ListTile(
                        leading: Icon(Icons.mail),
                        title: Text(currUser.email!, style: TextStyle(color: currTextColor)),
                      ),
                      ListTile(
                        leading: Icon(Icons.school),
                        title: Text("${currUser.roles.contains("COLLEGE") ? "College" : "High School"} Student", style: TextStyle(color: currTextColor)),
                      ),
                      Center(
                        child: CupertinoButton(
                          child: Text("View Profile", style: TextStyle(color: pelBlue, fontFamily: "Ubuntu"),),
                          onPressed: () {
                            router.navigateTo(context, "/profile", transition: TransitionType.fadeIn);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            authenticated ? Container(
              width: double.infinity,
              child: CupertinoButton(
                child: Text("Logout", style: TextStyle(fontFamily: "Ubuntu")),
                color: pelRed,
                onPressed: () async {
                  await AuthService.signOut().then((_) async {
                    router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
                  });
                },
              ),
            ) : Container(
              width: double.infinity,
              child: CupertinoButton(
                child: Text("Login", style: TextStyle(fontFamily: "Ubuntu"),),
                color: pelBlue,
                onPressed: () {
                  launch("${API_HOST.split(PROXY_HOST + "/")[1]}/api/auth/discord/login", webOnlyWindowName: "_self");
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
