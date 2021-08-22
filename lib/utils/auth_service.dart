import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString("userID") ?? "";
    if (userID != "") {
      var response = await http.get(Uri.parse("$API_HOST/api/users/$userID"));
      if (response.statusCode == 200) {
        currUser = new User.fromJson(jsonDecode(response.body));
        print("====== USER DEBUG INFO ======");
        print("FIRST NAME: ${currUser.firstName}");
        print("LAST NAME: ${currUser.lastName}");
        print("EMAIL: ${currUser.email}");
        print("====== =============== ======");
        return true;
      }
      else {
        // logged but not user data found!
        fb.FirebaseAuth.instance.signOut();
        prefs.remove("userID");
        return false;
      }
    }
    else {
      return false;
    }
  }
}