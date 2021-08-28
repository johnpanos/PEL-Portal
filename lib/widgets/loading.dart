import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(32),
        child: HeartbeatProgressIndicator(
          child: Image.asset("images/logos/icon/mark-color.png", height: 50,),
        ),
      ),
    );
  }
}
