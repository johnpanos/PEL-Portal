import 'dart:convert';
import 'dart:typed_data';

import 'package:cool_alert/cool_alert.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:markdown_editable_textinput/format_markdown.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:pel_portal/models/team.dart';
import 'package:pel_portal/models/tournament.dart';
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

class TournamentsPage extends StatefulWidget {
  @override
  _TournamentsPageState createState() => _TournamentsPageState();
}

class _TournamentsPageState extends State<TournamentsPage> {

  List<Tournament> tournamentList = [];
  List<Tournament> pastTournaments = [];

  bool creating = false;
  Tournament newTournament = new Tournament();
  bool loading = false;

  String joinTeamId = "";

  @override
  void initState() {
    super.initState();
    fb.FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        AuthService.getUser(user.uid).then((_) {
          setState(() {});
          getTournaments();
        });
      }
      else {
        router.navigateTo(context, "/", transition: TransitionType.fadeIn, replace: true);
      }
    });
  }

  Future<void> getTournaments() async {
    await AuthService.getAuthToken().then((_) async {
      await http.get(Uri.parse("$API_HOST/api/tournaments"), headers: {"Authorization": authToken}).then((value) {
        if (value.statusCode == 200) {
          var tournamentJson = jsonDecode(value.body)["data"];
          for (int i = 0; i < tournamentJson.length; i++) {
            Tournament tournament = Tournament.fromJson(tournamentJson[i]);
            if (tournament.seasonEnd!.isAfter(DateTime.now())) {
              setState(() {
                tournamentList.add(tournament);
              });
            }
            else {
              setState(() {
                pastTournaments.add(tournament);
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

  Future<void> createTournament() async {
    setState(() {
      loading = true;
    });
    if (newTournament.name != "" && !newTournament.name!.contains("'")) {
      newTournament.createdAt = DateTime.now();
      newTournament.updatedAt = DateTime.now();
      await AuthService.getAuthToken().then((_) async {
        await http.post(Uri.parse("$API_HOST/api/tournaments"), body: jsonEncode(newTournament), headers: {"Authorization": authToken}).then((value) async {
          if (value.statusCode == 200) {
            setState(() {
              newTournament = new Tournament.fromJson(jsonDecode(value.body)["data"]);
            });
            router.navigateTo(context, "/tournaments/${newTournament.id}", transition: TransitionType.fadeIn);
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
          text: "Team name cannot be empty or contain the character \" ' \""
      );
    }
    setState(() {
      loading = false;
    });
  }

  String getGameImage(Tournament tournament) {
    if (tournament.game == "VALORANT") {
      return "images/valorant_logo.png";
    }
    else if (tournament.game == "League of Legends") {
      return "images/league_logo.png";
    }
    else if (tournament.game == "Overwatch") {
      return "images/ow_logo.png";
    }
    else if (tournament.game == "Rocket League") {
      return "images/rocket_league_logo.png";
    }
    else if (tournament.game == "Splitgate") {
      return "images/splitgate_logo.png";
    }
    else {
      return "images/logos/icon/mark-color.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currUser.id != null && currUser.verification!.status == "VERIFIED") {
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
                                Visibility(
                                  visible: !creating && currUser.roles.contains("ADMIN"),
                                  child: CupertinoButton(
                                    color: pelBlue,
                                    child: Text("Create Tournament", style: TextStyle(fontFamily: "Ubuntu", color: Colors.white),),
                                    onPressed: () {
                                      setState(() {
                                        creating = true;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          new AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: (MediaQuery.of(context).size.width > 1300) ? 1100 : MediaQuery.of(context).size.width - 50,
                            height: creating ? null : 0,
                            padding: new EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Visibility(
                              visible: creating && currUser.roles.contains("ADMIN"),
                              child: Card(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Text(
                                        "Create Tournament",
                                        style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                      ),
                                      Padding(padding: EdgeInsets.all(8),),
                                      Image.asset(
                                        getGameImage(newTournament),
                                        width: 100,
                                        height: 100,
                                      ),
                                      Padding(padding: EdgeInsets.all(8),),
                                      Row(
                                        children: [
                                          new Expanded(
                                            flex: 2,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                  hintText: "Tournament Name",
                                                  border: OutlineInputBorder()
                                              ),
                                              onChanged: (input) {
                                                newTournament.name = input;
                                              },
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(16),),
                                          new Expanded(
                                            flex: 1,
                                            child: TextField(
                                              decoration: InputDecoration(
                                                  hintText: "Division",
                                                  border: OutlineInputBorder()
                                              ),
                                              onChanged: (input) {
                                                newTournament.division = input;
                                              },
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(16),),
                                          Text("Game:", style: TextStyle(color: currTextColor, fontSize: 16),),
                                          Padding(padding: EdgeInsets.all(8),),
                                          new Expanded(
                                            flex: 1,
                                            child: new DropdownButton(
                                              value: newTournament.game,
                                              items: games.map((e) => DropdownMenuItem(
                                                child: Text(e),
                                                value: e,
                                              )).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  newTournament.game = value.toString();
                                                });
                                              },
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(8),),
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.all(16),),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CupertinoButton(
                                              child: Text("High School", style: TextStyle(fontFamily: "Ubuntu", color: newTournament.type == "HIGH_SCHOOL" ? Colors.white : currTextColor),),
                                              color: newTournament.type == "HIGH_SCHOOL" ? pelBlue : currCardColor,
                                              onPressed: () {
                                                setState(() {
                                                  newTournament.type = "HIGH_SCHOOL";
                                                });
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoButton(
                                              child: Text("College", style: TextStyle(fontFamily: "Ubuntu", color: newTournament.type == "COLLEGE" ? Colors.white : currTextColor),),
                                              color: newTournament.type == "COLLEGE" ? pelBlue : currCardColor,
                                              onPressed: () {
                                                setState(() {
                                                  newTournament.type = "COLLEGE";
                                                });
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: CupertinoButton(
                                              child: Text("College/HS", style: TextStyle(fontFamily: "Ubuntu", color: newTournament.type == "BOTH" ? Colors.white : currTextColor),),
                                              color: newTournament.type == "BOTH" ? pelBlue : currCardColor,
                                              onPressed: () {
                                                setState(() {
                                                  newTournament.type = "BOTH";
                                                });
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.all(16),),
                                      MarkdownTextInput(
                                        (String value) => setState(() => newTournament.desc = value),
                                        "",
                                        label: 'Description\n\nHint: This field supports Markdown!',
                                        maxLines: 10,
                                        actions: MarkdownType.values,
                                      ),
                                      Padding(padding: EdgeInsets.all(16),),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(right: 8),
                                                      child: new Text(
                                                        "Registration Opens: ",
                                                        style: TextStyle(fontSize: 16),
                                                      ),
                                                    ),
                                                    new Expanded(
                                                      child: DateTimeField(
                                                        decoration: InputDecoration(
                                                          border: OutlineInputBorder()
                                                        ),
                                                        format: DateFormat("yyyy-MM-dd HH:mm"),
                                                        onChanged: (date) {
                                                          print("Set start $date");
                                                          newTournament.registrationStart = date;
                                                        },
                                                        onShowPicker: (context, currentValue) async {
                                                          final date = await showDatePicker(
                                                              context: context,
                                                              firstDate: DateTime(1900),
                                                              initialDate:
                                                              currentValue ?? DateTime.now(),
                                                              lastDate: DateTime(2100));
                                                          if (date != null) {
                                                            final time = await showTimePicker(
                                                              initialEntryMode:
                                                              TimePickerEntryMode.input,
                                                              context: context,
                                                              initialTime: TimeOfDay.fromDateTime(
                                                                  currentValue ?? DateTime.now()),
                                                            );
                                                            return DateTimeField.combine(date, time);
                                                          } else {
                                                            return currentValue;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(padding: EdgeInsets.all(4),),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(right: 8),
                                                      child: new Text(
                                                        "Registration Closes: ",
                                                        style: TextStyle(fontSize: 16),
                                                      ),
                                                    ),
                                                    new Expanded(
                                                      child: DateTimeField(
                                                        decoration: InputDecoration(
                                                            border: OutlineInputBorder()
                                                        ),
                                                        format: DateFormat("yyyy-MM-dd HH:mm"),
                                                        onChanged: (date) {
                                                          print("Set start $date");
                                                          newTournament.registrationEnd = date;
                                                        },
                                                        onShowPicker: (context, currentValue) async {
                                                          final date = await showDatePicker(
                                                              context: context,
                                                              firstDate: DateTime(1900),
                                                              initialDate:
                                                              currentValue ?? DateTime.now(),
                                                              lastDate: DateTime(2100));
                                                          if (date != null) {
                                                            final time = await showTimePicker(
                                                              initialEntryMode:
                                                              TimePickerEntryMode.input,
                                                              context: context,
                                                              initialTime: TimeOfDay.fromDateTime(
                                                                  currentValue ?? DateTime.now()),
                                                            );
                                                            return DateTimeField.combine(date, time);
                                                          } else {
                                                            return currentValue;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(8),),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(right: 8),
                                                      child: new Text(
                                                        "Season Starts: ",
                                                        style: TextStyle(fontSize: 16),
                                                      ),
                                                    ),
                                                    new Expanded(
                                                      child: DateTimeField(
                                                        decoration: InputDecoration(
                                                            border: OutlineInputBorder()
                                                        ),
                                                        format: DateFormat("yyyy-MM-dd HH:mm"),
                                                        onChanged: (date) {
                                                          print("Set start $date");
                                                          newTournament.seasonStart = date;
                                                        },
                                                        onShowPicker: (context, currentValue) async {
                                                          final date = await showDatePicker(
                                                              context: context,
                                                              firstDate: DateTime(1900),
                                                              initialDate:
                                                              currentValue ?? DateTime.now(),
                                                              lastDate: DateTime(2100));
                                                          if (date != null) {
                                                            final time = await showTimePicker(
                                                              initialEntryMode:
                                                              TimePickerEntryMode.input,
                                                              context: context,
                                                              initialTime: TimeOfDay.fromDateTime(
                                                                  currentValue ?? DateTime.now()),
                                                            );
                                                            return DateTimeField.combine(date, time);
                                                          } else {
                                                            return currentValue;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(padding: EdgeInsets.all(4),),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(right: 8),
                                                      child: new Text(
                                                        "Playoffs Start: ",
                                                        style: TextStyle(fontSize: 16),
                                                      ),
                                                    ),
                                                    new Expanded(
                                                      child: DateTimeField(
                                                        decoration: InputDecoration(
                                                            border: OutlineInputBorder()
                                                        ),
                                                        format: DateFormat("yyyy-MM-dd HH:mm"),
                                                        onChanged: (date) {
                                                          print("Set start $date");
                                                          newTournament.playoffStart = date;
                                                        },
                                                        onShowPicker: (context, currentValue) async {
                                                          final date = await showDatePicker(
                                                              context: context,
                                                              firstDate: DateTime(1900),
                                                              initialDate:
                                                              currentValue ?? DateTime.now(),
                                                              lastDate: DateTime(2100));
                                                          if (date != null) {
                                                            final time = await showTimePicker(
                                                              initialEntryMode:
                                                              TimePickerEntryMode.input,
                                                              context: context,
                                                              initialTime: TimeOfDay.fromDateTime(
                                                                  currentValue ?? DateTime.now()),
                                                            );
                                                            return DateTimeField.combine(date, time);
                                                          } else {
                                                            return currentValue;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(padding: EdgeInsets.all(4),),
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(right: 8),
                                                      child: new Text(
                                                        "Season Ends:    ",
                                                        style: TextStyle(fontSize: 16),
                                                      ),
                                                    ),
                                                    new Expanded(
                                                      child: DateTimeField(
                                                        decoration: InputDecoration(
                                                            border: OutlineInputBorder()
                                                        ),
                                                        format: DateFormat("yyyy-MM-dd HH:mm"),
                                                        onChanged: (date) {
                                                          print("Set start $date");
                                                          newTournament.seasonEnd = date;
                                                        },
                                                        onShowPicker: (context, currentValue) async {
                                                          final date = await showDatePicker(
                                                              context: context,
                                                              firstDate: DateTime(1900),
                                                              initialDate:
                                                              currentValue ?? DateTime.now(),
                                                              lastDate: DateTime(2100));
                                                          if (date != null) {
                                                            final time = await showTimePicker(
                                                              initialEntryMode:
                                                              TimePickerEntryMode.input,
                                                              context: context,
                                                              initialTime: TimeOfDay.fromDateTime(
                                                                  currentValue ?? DateTime.now()),
                                                            );
                                                            return DateTimeField.combine(date, time);
                                                          } else {
                                                            return currentValue;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.all(16),),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CupertinoButton(
                                              color: pelRed,
                                              padding: EdgeInsets.zero,
                                              child: Text("Cancel", style: TextStyle(fontFamily: "Ubuntu"),),
                                              onPressed: () {
                                                setState(() {
                                                  creating = false;
                                                });
                                              },
                                            ),
                                          ),
                                          Padding(padding: EdgeInsets.all(4)),
                                          Expanded(
                                            child: loading ? Container(
                                              padding: EdgeInsets.all(32),
                                              child: HeartbeatProgressIndicator(
                                                child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
                                              ),
                                            ) : CupertinoButton(
                                              color: pelBlue,
                                              padding: EdgeInsets.zero,
                                              child: Text("Create", style: TextStyle(fontFamily: "Ubuntu")),
                                              onPressed: () {
                                                createTournament();
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                                      "Tournaments",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Column(
                                      children: tournamentList.map((tournament) => Container(
                                        child: Card(
                                          child: InkWell(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            onTap: () {
                                              router.navigateTo(context, "/tournaments/${tournament.id}", transition: TransitionType.fadeIn);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    getGameImage(tournament),
                                                    height: 100,
                                                    width: 100,
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "${tournament.name!}  •  Div ${tournament.division}",
                                                            style: TextStyle(color: currTextColor, fontSize: 20),
                                                          ),
                                                          Padding(padding: EdgeInsets.all(2)),
                                                          Text(
                                                            "${DateFormat("yMMMd").format(tournament.seasonStart!)} – ${DateFormat("yMMMd").format(tournament.seasonEnd!)}",
                                                            style: TextStyle(color: currDividerColor, fontSize: 16),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Card(
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        child: Text(
                                                          tournament.game!,
                                                          style: TextStyle(color: currTextColor, fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Card(
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        child: Text(
                                                          "${tournament.type! == "HIGH_SCHOOL" ? "High School" : tournament.type! == "COLLEGE" ? "College" : "College/HS"}",
                                                          style: TextStyle(color: currTextColor, fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Container(
                                                      child: Icon(Icons.arrow_forward_ios, color: currDividerColor,)
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )).toList(),
                                    )
                                  ],
                                ),
                              ),
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
                                      "Past Tournaments",
                                      style: TextStyle(fontFamily: "LEMONMILK", fontSize: 25, fontWeight: FontWeight.bold),
                                    ),
                                    Padding(padding: EdgeInsets.all(8),),
                                    Column(
                                      children: pastTournaments.map((tournament) => Container(
                                        child: Card(
                                          child: InkWell(
                                            borderRadius: BorderRadius.all(Radius.circular(8)),
                                            onTap: () {
                                              router.navigateTo(context, "/tournaments/${tournament.id}", transition: TransitionType.fadeIn);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    getGameImage(tournament),
                                                    height: 100,
                                                    width: 100,
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "${tournament.name!}  •  Div ${tournament.division}",
                                                            style: TextStyle(color: currTextColor, fontSize: 20),
                                                          ),
                                                          Padding(padding: EdgeInsets.all(2)),
                                                          Text(
                                                            "${DateFormat("yMMMd").format(tournament.seasonStart!)} – ${DateFormat("yMMMd").format(tournament.seasonEnd!)}",
                                                            style: TextStyle(color: currDividerColor, fontSize: 16),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Card(
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        child: Text(
                                                          tournament.game!,
                                                          style: TextStyle(color: currTextColor, fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Card(
                                                      child: Container(
                                                        padding: EdgeInsets.all(8),
                                                        child: Text(
                                                          "${tournament.type! == "HIGH_SCHOOL" ? "High School" : tournament.type! == "COLLEGE" ? "College" : "College/HS"}",
                                                          style: TextStyle(color: currTextColor, fontSize: 20),
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(padding: EdgeInsets.all(16)),
                                                  Container(
                                                      child: Icon(Icons.arrow_forward_ios, color: currDividerColor,)
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )).toList(),
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
      return LoadingPage();
    }
  }
}