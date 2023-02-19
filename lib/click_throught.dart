import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_youtube_pip/draggable_app_bar.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class BottomBarMouseHoverHold extends HookWidget {
  final Function onAction;
  const BottomBarMouseHoverHold({super.key, required this.onAction});

  final widgetHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final insideCounter = useState<int>(0);

    useEffect(() {
      final timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
        final point = await screenRetriever.getCursorScreenPoint();
        final windowPosition = await windowManager.getPosition();
        final topLeft = Offset(windowPosition.dx, windowPosition.dy + height - widgetHeight);
        final bottomRight = Offset(windowPosition.dx + width, windowPosition.dy + height);
        if (pointInsideOffsets(point, topLeft, bottomRight)) {
          insideCounter.value++;
          if (insideCounter.value > 2) {
            // windowManager.setIgnoreMouseEvents(false);
            onAction();
          }
        } else {
          insideCounter.value = 0;
        }
      });

      return () {
        timer.cancel();
      };
    }, [height, width]);

    return Container(
      color: Colors.blue,
      width: width,
      height: widgetHeight,
      child: const Center(
        child: Text(
          "Hover and hold mouse here",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

bool pointInsideOffsets(Offset point, Offset topLeft, Offset bottomRight) {
  if (point.dx > topLeft.dx && point.dx < bottomRight.dx && point.dy > topLeft.dy && point.dy < bottomRight.dy) {
    return true;
  }
  return false;
}

class ClickThroughButton extends HookWidget {
  final Function? onPressed;
  const ClickThroughButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isHover = useState(false);
    final hover = isHover.value;

    return MouseRegion(
        onEnter: (event) {
          isHover.value = true;
        },
        onExit: (event) {
          isHover.value = false;
        },
        child: GestureDetector(
          onTap: (() {
            // windowManager.setIgnoreMouseEvents(true);
            if (onPressed != null) onPressed!();
          }),
          child: Container(
            height: DraggableAppBar.compactHeight,
            decoration: BoxDecoration(
              color: hover ? const Color(0x11FFFFFF) : Colors.transparent,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: const Center(
                child: Text(
              "Click through",
              style: TextStyle(color: Color(0xAAFFFFFF), fontWeight: FontWeight.w500),
            )),
          ),
        ));
  }
}
