import 'package:flutter/material.dart';

/// An independent top gradient padding component that stays upper of the hero card.
/// Blends the status bar area smoothly so any image in the hero card matches cleanly.
class TopGradientPadding extends StatelessWidget {
  final double? height;
  final List<Color>? colors;
  final List<double>? stops;

  const TopGradientPadding({
    super.key,
    this.height,
    this.colors,
    this.stops,
  });

  @override
  Widget build(BuildContext context) {
    if (colors == null) {
      return const SizedBox.shrink();
    }

    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalHeight = height ?? (statusBarHeight + 50.0);

    return IgnorePointer(
      child: SizedBox(
        height: totalHeight,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors!,
              stops: stops,
            ),
          ),
        ),
      ),
    );
  }
}
