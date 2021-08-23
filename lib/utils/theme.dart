import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

bool darkMode = false;


final pelBlue = Color(0xFF3D52D5);
final pelGreen = Color(0xFF1B998B);
final pelRed = Color(0xFFE83151);
final pelGrey = Color(0xFF323232);

// LIGHT THEME
const lightTextColor = Colors.black;
const lightBackgroundColor = Color(0xFFf9f9f9);
const lightCardColor = Colors.white;
const lightDividerColor = Color(0xFFC9C9C9);

// DARK THEME
const darkTextColor = Color(0xFFFFFFFF);
const darkBackgroundColor = Color(0xFF231f20);
const darkCardColor = Color(0xFF323232);
const darkDividerColor = Color(0xFF808080);

// CURRENT COLORs
var currTextColor = lightTextColor;
var currBackgroundColor = lightBackgroundColor;
var currCardColor = lightCardColor;
var currDividerColor = lightDividerColor;

ThemeData mainTheme = new ThemeData(
    accentColor: pelBlue,
    primaryColor: pelBlue,
    brightness: Brightness.light,
    fontFamily: "Ubuntu",
    cardTheme: CardTheme(
      color: currCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    )
);