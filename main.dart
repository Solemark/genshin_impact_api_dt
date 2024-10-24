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

String _jsonEncode(Object? data) => JsonEncoder.withIndent(' ').convert(data);
Response _generalHandler(Request request) => Response(
      200,
      headers: _jsonHeaders,
      body: _jsonEncode({
        "artifacts": "/artifacts",
        "characters": "/characters",
        "weapons": "/weapons",
      }),
    );

Future<List<String>> _getListData(String type) async {
  List<String> res = await Directory("data/$type")
      .list()
      .map((element) => element.toString().split("/").last.replaceAll(".json'", ""))
      .toList();
  res.sort();
  return res;
}

Future<Response> _typeHandler(Request request, String type) async =>
    Response(200, headers: _jsonHeaders, body: _jsonEncode(await _getListData(type)));

Future<String> _getData(String type, String name) async => await File("data/$type/$name.json").readAsString();

Future<Response> _nameHandler(Request request, String type, String name) async =>
    Response(200, headers: _jsonHeaders, body: await _getData(type, name));

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
