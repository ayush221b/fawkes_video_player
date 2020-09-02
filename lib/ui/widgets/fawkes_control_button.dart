import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FawkesControlButton extends StatelessWidget {
  final Function onTap;

  final String svgPath;

  final double size;

  final Color color;

  final IconData icon;

  const FawkesControlButton(
      {Key key,
      @required this.onTap,
      @required this.svgPath,
      @required this.size,
      this.icon,
      @required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: icon != null
          ? Icon(
              icon,
              color: color,
              size: size,
            )
          : SvgPicture.asset(
              svgPath,
              width: size,
              height: size,
              color: color,
            ),
    );
  }
}
