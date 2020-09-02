import 'package:flutter/material.dart';

import '../../../models/player/player_theme.dart';
import '../../../utils/util.dart';

class FawkesBottomPositionInfo extends StatelessWidget {
  /// The current position of playback
  final Duration currentPosition;

  /// The total duration of the video
  final Duration totalDuration;

  /// The fawkes player theme instance
  final FawkesPlayerTheme playerTheme;

  const FawkesBottomPositionInfo(
      {Key key,
      @required this.currentPosition,
      @required this.totalDuration,
      @required this.playerTheme})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        bottom: 32,
        left: 16,
        child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              FawkesUtils.formatCurrentPosition(currentPosition) +
                  ' / ' +
                  FawkesUtils.formatCurrentPosition(totalDuration),
              style: TextStyle(
                color: Colors.white,
              ),
            )));
  }
}
