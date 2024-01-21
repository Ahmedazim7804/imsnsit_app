import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConditionalyVisible extends StatelessWidget {
  const ConditionalyVisible(
      {super.key, required this.child, required this.showIf});

  final Widget child;
  final bool showIf;

  @override
  Widget build(BuildContext context) {
    return showIf
        ? SizedBox(
            height: 50,
            child: child
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 500)))
        : const SizedBox.shrink();
  }
}
