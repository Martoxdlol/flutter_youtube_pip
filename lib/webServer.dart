import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

int port = 32452;

Future<void> initWebServer() async {
  var handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_echoRequest);

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

String getServerUrl(String code) {
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
        frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen></iframe>
    <script>

      document.getElementById("frame").src = "https://www.youtube.com/embed/$code?autoplay=1"
    </script>

</body>

</html>
''';
}

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
