import 'package:shelf/shelf.dart';
import 'common.dart';

/// Returns JSON response for top level routes
Future<Response> generalHandler(Request request) async =>
    createResponse(200, jsonEncode(["artifacts", "characters", "weapons"]));

/// Returns JSON response for second level routes
Future<Response> typeHandler(Request request, String type) async =>
    createResponse(200, jsonEncode(await getList(type)));

/// Returns JSON response for third level routes
Future<Response> nameHandler(Request request, String type, String name) async =>
    createResponse(200, await getFile(type, name));
