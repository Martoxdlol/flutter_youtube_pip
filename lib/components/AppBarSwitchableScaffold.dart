import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:youtube_pip/components/TitleBarUtil.dart';

class TitleBar extends StatelessWidget {
  final Function? onBack;
  final bool? showBack;
  const TitleBar({super.key, this.showBack, this.onBack});

  @override
  Widget build(BuildContext context) {
    // final double width = MediaQuery.of(context).size.width;
    // final double height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.grey[160],
      child: WindowTitleBarBox(
        child: Row(
          children: [
            (showBack == true
                ? WindowButton(
                    onPressed: () {
                      if (onBack != null) {
                        onBack!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    iconBuilder: (buttonContext) => SizedBox(
                      height: appWindow.titleBarHeight,
                      child: const Icon(
                        FluentIcons.back,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  )
                : Container()),
            Expanded(child: MoveWindow()),
            const WindowButtons()
          ],
        ),
      ),
    );
  }
}

class TitleBarSwitchableScaffold extends HookWidget {
  final Widget content;
  final Widget? floatingActionButton;
  final bool? autoHideTitleBar;
  final bool? showBack;
  final Function? onBack;
  final Color? color;
  const TitleBarSwitchableScaffold(
      {super.key,
      required this.content,
      this.onBack,
      this.floatingActionButton,
      this.autoHideTitleBar,
      this.showBack,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        color: color ?? Colors.transparent,
        padding: EdgeInsets.only(
            top: (autoHideTitleBar == true) ? 0 : appWindow.titleBarHeight),
        child: content,
      ),
      Positioned(
        bottom: 20,
        right: 40,
        child: floatingActionButton ?? Container(),
      ),
      ShowOnHover(
        showAlways: !(autoHideTitleBar == true),
        child: TitleBar(showBack: showBack, onBack: onBack),
      )
    ]);
  }
}

class ShowOnHover extends HookWidget {
  final Widget child;
  final bool? showAlways;
  const ShowOnHover({super.key, required this.child, this.showAlways});

  @override
  Widget build(BuildContext context) {
    final isHover = useState(false);

    final double opcty = (showAlways == true) ? 1 : (isHover.value ? 1 : 0);

    return MouseRegion(
      onEnter: (event) {
        isHover.value = true;
      },
      onExit: (event) {
        isHover.value = false;
      },
      child: Opacity(
        opacity: opcty,
        child: child,
      ),
    );
  }
}
