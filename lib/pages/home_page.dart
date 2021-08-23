import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pel_portal/pages/onboarding_page.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/header.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fb;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
      }
    });
  }

  Future<void> getUsers() async {
    await AuthService.getAuthToken().then((value) async {
      var response = await http.get(Uri.parse("$API_HOST/api/users"), headers: {"Authorization": authToken});
      print(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currUser.id != null) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Container(
                          width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                          padding: new EdgeInsets.all(16.0),
                          child: new Text("Welcome back, ${currUser.firstName}.", style: TextStyle(fontFamily: "LEMONMILK", color: currTextColor, fontSize: 35, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
                        ),
                        new Container(
                          width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                          child: Card(
                            child: Container(
                              height: 1000,
                            ),
                          ),
                        )
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
      return OnboardingPage();
    }
  }
}
