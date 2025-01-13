import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  HttpServer server = await HttpServer.bind("localhost", 8080);
  print("listening on: ${server.address.host}:${server.port}");
  await for (HttpRequest req in server) {
    switch (req.method) {
      case "GET":
        await getRouteHandler(req);
        break;
      default:
        await sendJsonMessage(req.response, 400, jsonEncode("invalid request method: ${req.method}"));
    }
    req.response.close();
  }
}

Future<void> getRouteHandler(HttpRequest req) async {
  List<String> url = req.uri.toString().split('/')..removeWhere((i) => i == "");
  try {
    if (url.isEmpty) {
      await sendJsonMessage(req.response, 200, jsonEncode(["artifacts", "characters", "weapons"]));
    } else if (url.length == 1) {
      await sendJsonMessage(req.response, 200, jsonEncode(await getTypeList(url[0])));
    } else if (url.length == 2) {
      String res = await File("data/${url[0]}/${url[1]}.json").readAsString();
      await sendJsonMessage(req.response, 200, res);
    } else {
      throw PathNotFoundException("", OSError());
    }
  } on PathNotFoundException {
    await sendJsonMessage(req.response, 404, jsonEncode("invalid route: /${url.join('/')}"));
  } on Exception {
    await sendJsonMessage(req.response, 500, jsonEncode("server error"));
  }
}

String jsonEncode(Object data) => JsonEncoder.withIndent(' ').convert(data);

Future<List<String>> getTypeList(String type) async {
  return await Directory("data/$type").list().map((f) {
    String i = f.toString().split("/").last;
    return i.substring(0, i.length - 6);
  }).toList()
    ..sort();
}

Future<void> sendJsonMessage(HttpResponse res, int statusCode, Object msg) async {
  res.statusCode = statusCode;
  res.headers.add(HttpHeaders.cacheControlHeader, "no-store");
  res.headers.add(HttpHeaders.contentTypeHeader, "application/json");
  res.write(msg);
}
