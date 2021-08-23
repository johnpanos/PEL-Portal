import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/header.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    AuthService.checkAuth();
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
      return Scaffold(
        backgroundColor: currBackgroundColor,
        body: Column(
          children: [
            Header(),
            Container(
              child: Center(child: Text("home page"),),
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
            Header(),
            Container(
              child: Center(child: Text("onboarding page"),),
            )
          ],
        ),
      );
    }
  }
}
