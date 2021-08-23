import 'package:flutter/material.dart';
import 'package:pel_portal/utils/theme.dart';

class NotFoundPage extends StatefulWidget {
  @override
  _NotFoundPageState createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currBackgroundColor,
      body: Column(
        children: [
          Container(
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
          Center(
            child: Container(
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text("Error 404", style: TextStyle(fontFamily: "LEMONMILK", fontSize: 40),),
                      Text("Uh-oh! We couldn't find that.", style: TextStyle(),),
                    ],
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
