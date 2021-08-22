import 'package:fluro/fluro.dart';
import 'package:pel_portal/models/user.dart';

final router = FluroRouter();

const String API_HOST = "http://localhost:6001";

User currUser = new User();