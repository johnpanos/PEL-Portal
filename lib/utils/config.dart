import 'package:fluro/fluro.dart';
import 'package:pel_portal/models/user.dart';
import 'package:pel_portal/models/version.dart';

final router = FluroRouter();

Version appVersion = new Version("1.5.1+1");

const String PROXY_HOST = "https://proxy.pacificesports.org";
const String API_HOST = "$PROXY_HOST/https://api.pacificesports.org";

String authToken = "token";

User currUser = new User();