import 'package:flutter/material.dart';

import '../../../models/player/player_theme.dart';

class FawkesControlsSheetTile extends StatelessWidget {
  /// The title text
  final String titletext;

  /// The trailing text
  final String trailingText;

  /// The trailing widget
  final Widget trailingWidget;

  /// Instance of the player theme
  final FawkesPlayerTheme playerTheme;

  /// The function to be executed on tap
  final Function onItemTap;

  const FawkesControlsSheetTile(
      {Key key,
      @required this.titletext,
      @required this.onItemTap,
      @required this.trailingText,
      this.trailingWidget,
      @required this.playerTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onItemTap,
      title: Text(
        titletext ?? '',
        style: TextStyle(fontSize: 18),
      ),
      trailing: trailingWidget ??
          Text(
            trailingText,
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFFFEB330),
                decorationStyle: TextDecorationStyle.solid,
                decorationThickness: 2.0),
          ),
    );
  }
}
