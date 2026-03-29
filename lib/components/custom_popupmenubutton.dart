import 'package:flutter/material.dart';

class CustomPopupMenuButton extends StatefulWidget {
  const CustomPopupMenuButton({
    super.key,
    required this.menuItems,
    this.icon = Icons.more_vert,
    this.iconColor = Colors.black,
    this.iconSize = 24.0,
    this.menuWidth = 150.0,
    this.paddingRight = 0.0,
  });

  final List<PopupMenuEntry> menuItems;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double menuWidth;
  final double paddingRight;

  @override
  State<CustomPopupMenuButton> createState() => _CustomPopupMenuButtonState();
}

class _CustomPopupMenuButtonState extends State<CustomPopupMenuButton> {
  void _showMenu() {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;
    final Size overlaySize = overlay.size;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromLTWH(
        buttonPosition.dx + buttonSize.width - widget.menuWidth,
        buttonPosition.dy + buttonSize.height,
        widget.menuWidth,
        overlaySize.height,
      ),
      Offset.zero & overlaySize,
    );

    showMenu(
      context: context,
      position: position,
      items: widget.menuItems,
      constraints: BoxConstraints(
        maxWidth: widget.menuWidth,
      ),
      color: Colors.white,
    ).then((value) {
      if (value != null) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showMenu,
      child: Padding(
        padding: EdgeInsets.only(left: 4, right: widget.paddingRight),
        child: Icon(
          widget.icon,
          color: widget.iconColor,
          size: widget.iconSize,
        ),
      ),
    );
  }
}
