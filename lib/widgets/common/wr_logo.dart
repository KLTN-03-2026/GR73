import 'package:flutter/material.dart';

class WRLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final VoidCallback? onTap;
  const WRLogo({super.key, this.size = 28, this.showText = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5C8A), Color(0xFFFFA64D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'W',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.6,
          height: 1.0,
        ),
      ),
    );

    Widget content = box;
    if (showText) {
      content = LayoutBuilder(
        builder: (context, constraints) {
          final needCompact = constraints.maxWidth < (size + 80);
          if (needCompact) return box;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              box,
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'WR Studios',
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: content);
  }
}
