import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/pages/auth/register_page.dart';
import 'package:pel_portal/pages/home_page.dart';
import 'package:pel_portal/pages/not_found_page.dart';
import 'package:pel_portal/utils/config.dart';
import 'package:pel_portal/utils/theme.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) => Container(
    height: 100.0,
    child: new Material(
      child: new Center(
        child: new Text(details.exceptionAsString(), style: TextStyle(color: pelRed),),
      ),
    ),
  );

  FirebaseApp app = await Firebase.initializeApp();
  print('Initialized default app $app');
  FirebaseAnalytics analytics = FirebaseAnalytics();

  router.define('/', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new HomePage();
  }));

  router.define('/register/:token', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new RegisterPage(params!["token"][0]);
  }));

  router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return NotFoundPage();
  });

  setPathUrlStrategy();
  runApp(new MaterialApp(
    title: "PEL Portal",
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    theme: mainTheme,
    onGenerateRoute: router.generator,
    navigatorObservers: [
      FirebaseAnalyticsObserver(analytics: analytics),
    ],
  ));
}