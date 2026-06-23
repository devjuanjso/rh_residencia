import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

/// Texto de uma linha que rola horizontalmente (marquee) apenas quando
/// ultrapassa a largura disponível. Quando cabe, exibe um [Text] normal.
///
/// Evita o overflow ("texto saindo da tela") em títulos longos sem precisar
/// truncar com reticências.
class AutoScrollText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  /// Espaço em branco entre o fim e o reinício do texto ao rolar.
  final double blankSpace;

  /// Velocidade de rolagem em pixels por segundo.
  final double velocity;

  const AutoScrollText({
    super.key,
    required this.text,
    this.style,
    this.blankSpace = 48,
    this.velocity = 30,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tp = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout();

        final cabe = tp.width <= constraints.maxWidth;

        if (cabe) {
          return Text(
            text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }

        return SizedBox(
          height: tp.height,
          child: Marquee(
            text: text,
            style: style,
            blankSpace: blankSpace,
            velocity: velocity,
            startPadding: 0,
            pauseAfterRound: const Duration(seconds: 1),
            accelerationDuration: const Duration(milliseconds: 400),
            decelerationDuration: const Duration(milliseconds: 400),
          ),
        );
      },
    );
  }
}
