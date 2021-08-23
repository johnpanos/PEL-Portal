import 'dart:convert';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  /// only call this function when fb auth state has been verified!
  /// sets the [currUser] to retrieved user with [id] from db
  static Future<void> getUser(String id) async {
    await AuthService.getAuthToken();
    var response = await http.get(Uri.parse("$API_HOST/api/users/$id"), headers: {"Authorization": authToken});
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
      print("PEL User not found! Try logging out and back in.");
      // fb.FirebaseAuth.instance.signOut();
      // currUser = new User();
    }
  }

  static Future<void> signOut() async {
    await fb.FirebaseAuth.instance.signOut();
    currUser = new User();
  }

  static Future<void> getAuthToken() async {
    authToken = await fb.FirebaseAuth.instance.currentUser!.getIdToken(true);
    // await Future.delayed(const Duration(milliseconds: 100));
  }
}