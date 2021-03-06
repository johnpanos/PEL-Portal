import 'dart:convert';

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

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {

  SharedPreferences? prefs;

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
    return Container(
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
              children: [
                Visibility(
                  visible: authenticated,
                  child: CupertinoButton(
                    child: Text("Logout", style: TextStyle(fontFamily: "Ubuntu")),
                    color: pelRed,
                    onPressed: () async {
                      await AuthService.signOut().then((_) async {
                        router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: !authenticated,
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
          )
        ],
      ),
    );
  }
}
