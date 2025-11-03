import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/services/alice_service.dart';

class AliceButton extends StatefulWidget {
  final Widget child;

  const AliceButton({super.key, required this.child});

  @override
  State<AliceButton> createState() => _AliceButtonState();
}

class _AliceButtonState extends State<AliceButton> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap(Offset position) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Check if the tap is in the bottom-left corner (e.g., a 50x50 area)
    if (position.dx <= 50 && position.dy >= size.height - 50) {
      final now = DateTime.now();
      if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
        _tapCount = 1;
      } else {
        _tapCount++;
      }
      _lastTapTime = now;

      if (_tapCount == 3) {
        _tapCount = 0;
        AliceService.alice.showInspector();
      }
    } else {
      _tapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _handleTap(details.globalPosition),
      child: widget.child,
    );
  }
}
