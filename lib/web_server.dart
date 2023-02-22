import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:http/http.dart' as http;

int port = 32452;

bool isServerWorking = false;

Future<void> initWebServer() async {
  var handler = const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

  HttpServer? server;
  for (int i = 0; i < 1000; i++) {
    try {
      port = 32452 + i;
      server = await shelf_io.serve(handler, 'localhost', port);
      break;
      // ignore: empty_catches
    } catch (e) {}
  }

  if (server == null) {
    throw Exception('Failed to start server');
  }

  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

bool chekingServer = false;
void initWebServerStatusCheker() {
  updateServerStatus();
  if (chekingServer) return;
  chekingServer = true;
  Timer.periodic(const Duration(seconds: 5), (timer) {
    updateServerStatus();
  });
}

bool firstTime = true;

void updateServerStatus() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:$port/'));
    if (response.statusCode == 200) {
      isServerWorking = true;
      if (firstTime) {
        firstTime = false;
        print("Web server is working");
      }
    } else {
      isServerWorking = false;
      print("Web server is not working as expected");
    }
  } catch (e) {
    print("Web server is not working");
    isServerWorking = false;
  }
}

bool urlIsVideoPlayer(String url) {
  return url.startsWith('http://localhost') || url.startsWith('https://www.youtube.com/embed/');
}

String getServerUrl(String code) {
  if (!isServerWorking) {
    return 'https://www.youtube.com/embed/$code';
  }
  return 'http://localhost:$port/$code';
}

String content(String code) {
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Youtube PiP</title>
</head>
<body>
    <style>
        body {
          overflow: hidden;
        }
        * {
            padding: 0;
            margin: 0;
        }
        iframe {
            height: 100vh;
            width: 100vw;
        }
    </style>
    <iframe id="frame" style="width: 100vw; height: 100vh" title="YouTube video player"
        frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"></iframe>
    <script>
      document.getElementById("frame").src = "https://www.youtube.com/embed/$code?autoplay=1"
    </script>
</body>
</html>
''';
}

// Removed: "allowfullscreen" from iframe

String enableAutoPlayScriptContent() {
  return '''var context = new AudioContext(),
      oscillator = context.createOscillator();
      
      // Connect the oscillator to our speakers
      oscillator.connect(context.destination);
      // DEBUG ONLY
      // oscillator.start(context.currentTime);
      // oscillator.stop(context.currentTime + 3);''';
}

Response _echoRequest(Request request) {
  final code = request.requestedUri.path;
  return Response.ok(content(code), headers: {'content-type': 'text/html'});
}
