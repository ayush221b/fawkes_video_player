import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../models/player/player_theme.dart';
import '../video_progress_indicator.dart';

class FawkesBottomProgressControls extends StatelessWidget {
  /// The flutter video player controller instance
  final VideoPlayerController flutterVideoPlayerController;

  /// The player theme instance
  final FawkesPlayerTheme playerTheme;

  const FawkesBottomProgressControls(
      {Key key,
      @required this.flutterVideoPlayerController,
      @required this.playerTheme})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 18,
        left: 16,
        right: 16,
        child: FawkesVideoProgressIndicator(
          flutterVideoPlayerController,
          allowScrubbing: true,
          colors: VideoProgressColors(
              playedColor: Color(0xFFFEB330),
              bufferedColor: Color(0xFFFEB330).withOpacity(0.4)),
        ));
  }
}
