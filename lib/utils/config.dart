import 'package:fluro/fluro.dart';
import 'package:pel_portal/models/user.dart';

final router = FluroRouter();

const String PROXY_HOST = "http://localhost:5000";
const String API_HOST = "$PROXY_HOST/http://localhost:6001";

String authToken = "token";

User currUser = new User();