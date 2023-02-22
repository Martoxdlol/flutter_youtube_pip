import 'package:fluent_ui/fluent_ui.dart' as fluent_ui;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_youtube_pip/routes/menu.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_manager/window_manager.dart';

class DraggableAppBar extends HookWidget implements PreferredSizeWidget {
  final String title;
  final Brightness brightness;
  final Color backgroundColor;
  final bool compact;
  final bool autoHide;
  final void Function()? onBack;
  final List<Widget> actions;

  const DraggableAppBar({
    super.key,
    required this.title,
    required this.brightness,
    required this.backgroundColor,
    this.actions = const [],
    this.compact = false,
    this.autoHide = false,
    this.onBack,
  });

  static const compactHeight = 30.0;

  double get height => compact ? compactHeight : kToolbarHeight;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isHover = useState(false);

    final child = Opacity(
      opacity: (isHover.value || !autoHide) ? 1 : 0,
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              height: height,
              width: width,
              child: WindowCaption(
                backgroundColor: backgroundColor,
                brightness: brightness,
              ),
            ),
          ),
          SizedBox(
            height: height,
            width: width - 150,
            child: Row(children: [
              AppBarButton(
                height: height,
                width: 50,
                onTap: onBack,
                child: const Icon(
                  fluent_ui.FluentIcons.back,
                  size: 13,
                ),
              ),
              ...actions,
            ]),
          )
        ],
      ),
    );

    return MouseRegion(
      onEnter: (event) {
        isHover.value = true;
      },
      onExit: (event) {
        isHover.value = false;
      },
      child: child,
    );
  }

  Widget getAppBarTitle(String title) {
    if (UniversalPlatform.isWeb) {
      return Align(
        alignment: AlignmentDirectional.center,
        child: Text(title),
      );
    } else {
      return DragToMoveArea(
        child: SizedBox(
          height: height,
          child: Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class AppBarButton extends HookWidget {
  const AppBarButton({
    super.key,
    this.height,
    this.width,
    this.onTap,
    required this.child,
  });

  final void Function()? onTap;
  final double? width;
  final double? height;
  final Widget child;

  @override
  fluent_ui.Widget build(fluent_ui.BuildContext context) {
    final isHover = useState(false);
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: MouseRegion(
        onEnter: (event) {
          isHover.value = true;
        },
        onExit: (event) {
          isHover.value = false;
        },
        child: Container(
          color: isHover.value ? Colors.white10 : null,
          width: width,
          height: height,
          child: Center(
            child: child,
          ),
        ),
      ),
    );
  }
}
