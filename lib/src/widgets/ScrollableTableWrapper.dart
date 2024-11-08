import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollableTableWrapper extends StatelessWidget {
  final Widget child;
  final ScrollController horizontalScrollController;
  final ScrollController verticalScrollController;

  ScrollableTableWrapper({
    Key? key,
    required this.child,
  }) :
        horizontalScrollController = ScrollController(),
        verticalScrollController = ScrollController(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKey: (node, event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _scrollHorizontal(50);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _scrollHorizontal(-50);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dx.abs() > details.delta.dy.abs()) {
            // Movimiento horizontal
            horizontalScrollController.jumpTo(
                horizontalScrollController.offset - details.delta.dx
            );
          } else {
            // Movimiento vertical
            verticalScrollController.jumpTo(
                verticalScrollController.offset - details.delta.dy
            );
          }
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: horizontalScrollController,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: verticalScrollController,
            child: child,
          ),
        ),
      ),
    );
  }

  void _scrollHorizontal(double amount) {
    horizontalScrollController.animateTo(
      horizontalScrollController.offset + amount,
      duration: Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }
}