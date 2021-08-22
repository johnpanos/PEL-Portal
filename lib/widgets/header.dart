import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/utils/theme.dart';

class Header extends StatefulWidget {
  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                TextButton(
                  child: Text("Login"),
                  onPressed: () {

                  },
                ),
                CupertinoButton(
                  child: Text("Login"),
                  color: pelBlue,
                  onPressed: () {

                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
