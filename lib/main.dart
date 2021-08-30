import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:pel_portal/pages/admin/manage_users_page.dart';
import 'package:pel_portal/pages/admin/manage_verification_page.dart';
import 'package:pel_portal/pages/auth/register_page.dart';
import 'package:pel_portal/pages/home_page.dart';
import 'package:pel_portal/pages/not_found_page.dart';
import 'package:pel_portal/pages/profile/profile_page.dart';
import 'package:pel_portal/pages/teams/team_details_page.dart';
import 'package:pel_portal/pages/teams/teams_page.dart';
import 'package:pel_portal/pages/tournaments/tournament_details_page.dart';
import 'package:pel_portal/pages/tournaments/tournaments_page.dart';
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
  print('PEL Portal v${appVersion.toString()}');
  FirebaseApp app = await Firebase.initializeApp();
  print('Initialized default app $app');
  FirebaseAnalytics analytics = FirebaseAnalytics();

  router.define('/', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new HomePage();
  }));

  router.define('/register/:token', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new RegisterPage(params!["token"][0]);
  }));

  // ADMIN ROUTES
  router.define('/admin/users', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new ManageUsersPage();
  }));
  router.define('/admin/verification', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new ManageVerificationPage();
  }));

  // PROFILE ROUTES
  router.define('/profile', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new ProfilePage();
  }));

  // TEAMS ROUTES
  router.define('/teams', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new TeamsPage();
  }));
  router.define('/teams/:id', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new TeamDetailsPage(params!["id"][0]);
  }));

  // TOURNAMENTS ROUTES
  router.define('/tournaments', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new TournamentsPage();
  }));
  router.define('/tournaments/:id', handler: new Handler(handlerFunc: (BuildContext? context, Map<String, dynamic>? params) {
    return new TournamentDetailsPage(params!["id"][0]);
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