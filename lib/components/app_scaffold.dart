import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_youtube_pip/draggable_app_bar.dart';

class AppScaffold extends HookWidget {
  final Widget content;
  final Widget? floatingActionButton;
  final bool autoHideTitleBar;
  final bool? showBack;
  final void Function()? onBack;
  final Color? color;

  const AppScaffold({
    super.key,
    required this.content,
    this.onBack,
    this.floatingActionButton,
    this.autoHideTitleBar = false,
    this.showBack,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final appBar = DraggableAppBar(
      title: 'Flutter Youtube PIP',
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      compact: true,
      autoHide: autoHideTitleBar,
      onBack: onBack,
    );

    return Scaffold(
      body: Stack(children: [
        Positioned(
          top: !autoHideTitleBar ? DraggableAppBar.compactHeight : 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: content,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: appBar,
        ),
      ]),
    );
  }
}
