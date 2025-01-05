import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'router/handlers.dart';

Future<void> main() async {
  // Set up the router
  final Router _router = new Router()
    ..get("/", generalHandler)
    ..get("/<type>", typeHandler)
    ..get("/<type>/<name>", nameHandler);
  final _cascade = Cascade().add(_router.call);

  // Start the server
  HttpServer _server = await serve(
    logRequests().addHandler(_cascade.handler),
    InternetAddress.anyIPv4,
    8080,
  );
  print('Serving at http://${_server.address.host}:${_server.port}');
}
