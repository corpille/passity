import 'dart:io';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf/src/message.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:mime/mime.dart' as mime;
import 'package:less_dart/less.dart';
import 'package:args/args.dart';

Less less = new Less();

String rewritting(String filePath) {
  if (filePath == "/" || filePath.isEmpty) {
    filePath = '/index.html';
  } else if (filePath.indexOf("/packages") != -1) {
    var index = filePath.indexOf("/packages");
    filePath = filePath.substring(index);
  }
  return filePath;
}

var path = "web/";
var rewrittingFunc = rewritting;

Future<Response> requestHandler(Request request) async {
  var filePath = request.url.path;

  if (filePath.startsWith("api/")) {
    var path =
        Uri.parse(request.requestedUri.toString().replaceAll("/api", ""));

    request = new Request(request.method, path,
        protocolVersion: request.protocolVersion,
        headers: request.headers,
        handlerPath: request.handlerPath,
        body: getBody(request),
        context: request.context);

    return proxyHandler("http://127.0.0.1:8001")(request);
  }
  filePath = path + rewrittingFunc(filePath);
  if (!filePath.split("/").last.contains(".")) {
    filePath = path + "/index.html";
  }
  var file = new File(filePath);

  var fileStat = file.statSync();
  var headers = <String, String>{
    HttpHeaders.CONTENT_LENGTH: fileStat.size.toString()
  };

  var contentType = mime.lookupMimeType(file.path);
  if (contentType != null) {
    headers[HttpHeaders.CONTENT_TYPE] = contentType;
  }
  headers["cache-control"] = "no-cache";

  if (filePath.indexOf(".css") != -1 && filePath.indexOf(".min.css") == -1) {
    List<String> args = [];
    //less = new Less();

    args.add('-no-color');
    args.add('--strict-math=on');
    args.add('--strict-units=on');
    args.add(filePath.replaceAll(".css", ".less"));
    args.add(filePath);
    await less.transform(args);
    file = new File(filePath);
  }
  return new Response.ok(file.openRead(), headers: headers);
}

void startServer() {
  Process.run('dart', ['bin/api.dart', "--port", "8001"]).then(
      (ProcessResult results) {
    print(results.stdout);
  });
  print("Server Ready on http://localhost:8001/ !");
}

main(List<String> args) {
  var parser = new ArgParser();

  parser.addOption('port',
      abbr: 'p',
      help: 'port of the client',
      defaultsTo: '8080',
      valueHelp: '8080');
  parser.addFlag('server',
      abbr: 's', defaultsTo: false, help: 'launch the server of bin');
  parser.addFlag('help', abbr: 'h', defaultsTo: false, help: 'print the help');

  var results = parser.parse(args);

  if (results['help'] == true) {
    print(parser.usage);
  } else {
    var cascade = new Cascade().add(requestHandler);
    if (results['server'] == true) {
      startServer();
    }
    shelf_io.serve(cascade.handler, 'localhost', int.parse(results['port']));
    print("Server running on http://localhost:${results['port']}/ !");
  }
}
