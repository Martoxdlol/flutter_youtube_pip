# youtube_pip

This is Picture in Picture player for youtube videos.

It's made with flutter and WebView2.

## Performance

Previous version of this app was made with Electron and the performance whas horrible. 

So I tried making native Windows app but it's to complicaded. I could have but it didn't seem like the best idea. Because of that, I keep trying different things and i found Flutter as the best candidate. It outperforms Electron startup time and it has a more native feeling.

## Interesting tricks

There are some problems with youtube embed into a WebView.

The first is that you cannot **login into Google Account**. To fix that I had to change user-agent header of WebView requests. I finally got a working user-agent (I got it doing alchemy whit user-agent strings).

Sencond, youtube have some **content protection** that prohibits you from playing embed videos on a non auhotized domains or directly in the browser (ex: https://youtube.com/embed/dQw4w9WgXcQ). Music videos and others could not be played. Luckily, if you use a `<iframe/>` on a `localhost` domain it works (I'm not sure why). So I use a local webserver to host a very simple page with an iframe with a localhost domain.

Third, **autoplay**. Nowadays browsers have disabled autoplay if you don't interact with content first. 
That breaks this app when using a local web server (previous problem). 
Doing some expermients I found that if some JavaScript code that played some sound was injected into the webview, the autoplay limitation was bypassed. So I injected a JS code similar to `new AudioContext(); ...` (see webServer.dart) that turned on autoplay feature.

