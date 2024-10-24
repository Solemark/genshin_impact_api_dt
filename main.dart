import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

final _router = shelf_router.Router()
  ..get("/", _generalHandler)
  ..get("/<type>", _typeHandler)
  ..get("/<type>/<name>", _nameHandler);

final _jsonHeaders = {
  'content-type': 'application/json',
  'Cache-Control': 'no-store',
};

String _jsonEncode(Object data) => JsonEncoder.withIndent(' ').convert(data);
Response _generalHandler(Request request) {
  return Response(
    200,
    headers: _jsonHeaders,
    body: _jsonEncode({
      "artifacts": "artifacts",
      "characters": "characters",
      "weapons": "weapons",
    }),
  );
}

Future<Object> _getListData(String type) async {
  try {
    List<String> res = await Directory("data/$type")
        .list()
        .map((element) => element.toString().split("/").last.replaceAll(".json'", ""))
        .toList();
    res.sort();
    return res;
  } catch (e) {
    return _jsonEncode("directory: $type not found");
  }
}

Future<Response> _typeHandler(Request request, String type) async {
  Object res = await _getListData(type);
  return Response(200, headers: _jsonHeaders, body: _jsonEncode(res));
}

Future<String> _getData(String type, String name) async {
  try {
    return await File("data/$type/$name.json").readAsString();
  } on PathNotFoundException {
    return _jsonEncode("path: $type/$name not found");
  }
}

Future<Response> _nameHandler(Request request, String type, String name) async {
  return Response(200, headers: _jsonHeaders, body: await _getData(type, name));
}

Future<void> main() async {
  final int port = 8080;
  final cascade = Cascade().add(_router.call);
  final server = await shelf_io.serve(
    logRequests().addHandler(cascade.handler),
    InternetAddress.anyIPv4,
    port,
  );
  print('Serving at http://${server.address.host}:${server.port}');
}
