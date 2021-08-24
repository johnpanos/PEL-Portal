import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/pages/onboarding_page.dart';
import 'package:pel_portal/utils/auth_service.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:pel_portal/widgets/header.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:progress_indicators/progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool uploadingVerification = false;

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

  Future<void> uploadStudentProof() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Select verification",
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'pdf', 'jpeg', 'gif', 'webp', 'bmp'],
    );
    if (result != null) {
      try {
        Uint8List fileBytes = result.files.first.bytes!;
        String fileName = result.files.first.name;
        setState(() {
          uploadingVerification = true;
        });
        await FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes).then((snapshot) async {
          currUser.verification!.fileUrl = await snapshot.ref.getDownloadURL();
          setState(() {
            currUser.verification!.userId = currUser.id;
            print(currUser.verification!.fileUrl);
          });
        });
      } catch (e) {
        print(e);
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
        uploadingVerification = false;
      });
    }
  }

  Future<void> sendVerification() async {
    setState(() {
      uploadingVerification = true;
    });
    currUser.verification!.status = "UPLOADED";
    currUser.verification!.updatedAt = DateTime.now();
    currUser.verification!.createdAt = DateTime.now();
    await AuthService.getAuthToken().then((_) async {
      await http.post(Uri.parse("$API_HOST/api/users"), body: jsonEncode(currUser), headers: {"Authorization": authToken}).then((value) {
        print(value.body);
        if (value.statusCode == 200) {
          currUser = new User.fromJson(jsonDecode(value.body)["data"]);
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
    setState(() {
      uploadingVerification = false;
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
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        new Container(
                          width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                          padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                          child: new Text("Welcome back, ${currUser.firstName}.", style: TextStyle(fontFamily: "LEMONMILK", color: currTextColor, fontSize: 35, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
                        ),
                        new Visibility(
                          visible: currUser.verification!.status == null,
                          child: new Container(
                            width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                            padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text("Student Verification Missing!", style: TextStyle(color: currTextColor, fontFamily: "LEMONMILK", fontSize: 35, fontWeight: FontWeight.bold),),
                                    Padding(padding: EdgeInsets.all(16)),
                                    Icon(Icons.error, color: pelRed, size: 75,),
                                    Padding(padding: EdgeInsets.all(16)),
                                    uploadingVerification ? HeartbeatProgressIndicator(
                                      child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
                                    ) : OutlinedButton(
                                      onPressed: ()  {
                                        if (currUser.verification!.fileUrl != null) {
                                          launch(currUser.verification!.fileUrl!);
                                        }
                                        else {
                                          uploadStudentProof();
                                        }
                                      },
                                      child: Container(
                                        width: 500,
                                        height: 100,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(currUser.verification!.fileUrl != null ? Icons.launch : Icons.upload, color: pelBlue,),
                                            Padding(padding: EdgeInsets.all(4)),
                                            Text(currUser.verification!.fileUrl != null ? "File Uploaded" : "Upload File", style: TextStyle(fontSize: 16, color: pelBlue),)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(8)),
                                    Visibility(
                                      visible: currUser.verification!.fileUrl != null,
                                      child: Container(
                                        width: 500,
                                        height: 50,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: CupertinoButton(
                                                color: pelRed,
                                                padding: EdgeInsets.zero,
                                                child: Text("Remove File", style: TextStyle(fontFamily: "Ubuntu"),),
                                                onPressed: () {
                                                  setState(() {
                                                    currUser.verification!.fileUrl = null;
                                                  });
                                                },
                                              ),
                                            ),
                                            Padding(padding: EdgeInsets.all(4)),
                                            Expanded(
                                              child: CupertinoButton(
                                                color: pelBlue,
                                                padding: EdgeInsets.zero,
                                                child: Text("Upload Verification", style: TextStyle(fontFamily: "Ubuntu")),
                                                onPressed: () {
                                                  CoolAlert.show(
                                                      context: context,
                                                      type: CoolAlertType.confirm,
                                                      borderRadius: 8,
                                                      onConfirmBtnTap: () {
                                                        sendVerification();
                                                        router.pop(context);
                                                      },
                                                      width: 300,
                                                      confirmBtnColor: pelBlue,
                                                      title: "Are you sure?",
                                                      text: "Once you confirm this verification request, you will not be able to modify the uploaded file until it has been reviewed."
                                                  );
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(16)),
                                    Text(
                                      "In order to participate in PEL, you must be a current high school or college student in California. Please upload proof of your student status above. You may upload a file in any of the supported formats (.png, .jpg, .jpeg, .gif, .webp, .bmp, .pdf).",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    CupertinoButton(
                                      child: Text("Check out our player eligibility guidelines for more information.", style: TextStyle(color: pelBlue, fontFamily: "Ubuntu"),),
                                      onPressed: () => launch("https://support.pacificesports.org/player-and-team-eligibility"),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        new Visibility(
                          visible: currUser.verification!.status == "UPLOADED",
                          child: new Container(
                            width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                            padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Card(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text("Student Verification Uploaded!", style: TextStyle(color: currTextColor, fontFamily: "LEMONMILK", fontSize: 35, fontWeight: FontWeight.bold),),
                                    Padding(padding: EdgeInsets.all(16)),
                                    Icon(Icons.check_circle, color: pelGreen, size: 75,),
                                    Padding(padding: EdgeInsets.all(16)),
                                    OutlinedButton(
                                      onPressed: ()  {
                                        launch(currUser.verification!.fileUrl!);
                                      },
                                      child: Container(
                                        width: 500,
                                        height: 100,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.launch, color: pelGreen,),
                                            Padding(padding: EdgeInsets.all(4)),
                                            Text("File Uploaded", style: TextStyle(fontSize: 16, color: pelGreen),)
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(16)),
                                    Text(
                                      "Your verification request has been successfully uploaded! We are currently processing your request which may take up to 48 hours. If your request is still processing after that, feel free to reach out to us via our discord server.",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    CupertinoButton(
                                      child: Text("Check out our player eligibility guidelines for more information.", style: TextStyle(color: pelBlue, fontFamily: "Ubuntu"),),
                                      onPressed: () => launch("https://support.pacificesports.org/player-and-team-eligibility"),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: currUser.verification!.status == "VERIFIED",
                          child: new Container(
                            width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                            padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Card(
                              child: Container(
                                height: 600,
                              ),
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
