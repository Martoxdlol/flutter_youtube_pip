import 'package:fluent_ui/fluent_ui.dart';

class OpenMenuButton extends StatelessWidget {
  final void Function()? onPressed;
  const OpenMenuButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Button(
      style: ButtonStyle(backgroundColor: ButtonState.resolveWith(((states) {
        if (states.isPressing) return Colors.grey[180];
        return Colors.grey[160];
      }))),
      onPressed: onPressed,
      child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              const Icon(
                FluentIcons.collapse_menu,
                color: Colors.white,
              ),
              Container(
                width: 10,
              ),
              const Text("OPEN MENU", style: TextStyle(color: Colors.white)),
            ],
          )),
    );
  }
}
