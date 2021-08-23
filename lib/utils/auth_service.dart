import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("userID")) {
      print("FB User logged");
      String userID = prefs.getString("userID")!;
      await AuthService.getAuthToken();
      var response = await http.get(Uri.parse("$API_HOST/api/users/$userID"), headers: {"Authorization": authToken});
      if (response.statusCode == 200) {
        currUser = new User.fromJson(jsonDecode(response.body)["data"]);
        print("====== USER DEBUG INFO ======");
        print("FIRST NAME: ${currUser.firstName}");
        print("LAST NAME: ${currUser.lastName}");
        print("EMAIL: ${currUser.email}");
        print("====== =============== ======");
      }
      else {
        // logged but not user data found!
        print("PEL User not found! Logging out FB");
        fb.FirebaseAuth.instance.signOut();
        prefs.remove("userID");
        currUser = new User();
      }
    }
    else {
      print("FB User not logged");
    }
  }

  static Future<void> getAuthToken() async {
    authToken = await fb.FirebaseAuth.instance.currentUser!.getIdToken(true);
    // await Future.delayed(const Duration(milliseconds: 100));
  }
}