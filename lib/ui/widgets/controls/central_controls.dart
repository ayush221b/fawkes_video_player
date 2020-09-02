import 'package:flutter/material.dart';

import '../../../controllers/fawkes_controller.dart';
import '../../../models/player/player_theme.dart';
import '../fawkes_control_button.dart';

class FawkesCentralControls extends StatelessWidget {
  /// The fawkes controller instance
  final FawkesController controller;

  /// The function to seek backward
  final Function seekBackward;

  /// The function to seek forward
  final Function seekForward;

  /// The player theme
  final FawkesPlayerTheme playerTheme;

  const FawkesCentralControls(
      {Key key,
      @required this.controller,
      @required this.seekBackward,
      @required this.seekForward,
      @required this.playerTheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FawkesControlButton(
            onTap: seekBackward,
            size: 40,
            color: Colors.white,
            svgPath: 'lib/assets/icons/10_reverse.svg',
          ),
          SizedBox(
            width: 40,
          ),
          FawkesControlButton(
              onTap: controller.togglePause,
              svgPath: controller.isPlaying
                  ? 'lib/assets/icons/pause.svg'
                  : 'lib/assets/icons/play.svg',
              size: 68,
              color: Colors.white),
          SizedBox(
            width: 40,
          ),
          FawkesControlButton(
            onTap: seekForward,
            size: 40,
            color: Colors.white,
            svgPath: 'lib/assets/icons/10_forward.svg',
          ),
        ],
      ),
    ));
  }
}
