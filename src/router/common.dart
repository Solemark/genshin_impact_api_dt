import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';

/// the JSON headers for responses
final jsonHeaders = {
  'content-type': 'application/json',
  'Cache-Control': 'no-store',
};

/// Takes [Object]s and returns JSON [String]
String jsonEncode(Object data) => JsonEncoder.withIndent(' ').convert(data);

/// Returns the content of a directory or "invalid directory" on [PathNotFoundException]
Future<Object> getList(String type) async {
  try {
    List<String> res = await Directory("data/$type").list().map((f) {
      String i = f.toString().split("/").last;
      return i.substring(0, i.length - 6);
    }).toList();
    return res..sort();
  } on PathNotFoundException {
    return jsonEncode("directory: $type not found");
  }
}

/// Returns the content of a file or "invalid path" on [PathNotFoundException]
Future<String> getFile(String type, String name) async {
  try {
    return await File("data/$type/$name.json").readAsString();
  } on PathNotFoundException {
    return jsonEncode("path: $type/$name not found");
  }
}

/// Creates and returns a [Future] for the [Response]
Future<Response> createResponse(int status, Object message) async =>
    Response(status, headers: jsonHeaders, body: message);
