import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import '../controllers/fawkes_controller.dart';
import '../errors/controller_exception.dart';
import 'fawkes_video_player_with_controls.dart.dart';

/// A video player plugin built on top of the official Flutter video_player
/// It has support for quality swithcing and subtitle playback when playing HLS Streams
/// If you encounter any issues, feel free to:
/// File an issue here: TODO
/// Or Raise a PR to : TODO
class FawkesVideoPlayer extends StatefulWidget {
  /// The FawkesController instance
  final FawkesController fawkesController;

  const FawkesVideoPlayer({Key key, @required this.fawkesController})
      : super(key: key);

  @override
  _FawkesVideoPlayerState createState() => _FawkesVideoPlayerState();
}

class _FawkesVideoPlayerState extends State<FawkesVideoPlayer> {
  // Get the controller instance passed to the widget
  FawkesController get _controller {
    if (this.widget.fawkesController == null) {
      throw FawkesControllerException(
          message: 'The fawkes controller must not be null');
    }
    return this.widget.fawkesController;
  }

  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    _controller.removeListener(listener);
    super.dispose();
  }

  @override
  void didUpdateWidget(FawkesVideoPlayer oldWidget) {
    if (oldWidget.fawkesController != widget.fawkesController) {
      _controller.addListener(listener);
    }
    super.didUpdateWidget(oldWidget);
  }

  void listener() async {
    if (_controller.isFullScreen && !_isFullScreen) {
      _isFullScreen = true;
      await _pushFullScreenWidget(context);
    } else if (!_controller.isFullScreen && _isFullScreen) {
      Navigator.of(context, rootNavigator: true).pop();
      _isFullScreen = false;
    }
  }

  Widget _buildFullScreenVideo(
    BuildContext context,
    Animation<double> animation,
  ) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
          alignment: Alignment.center,
          color: Colors.black,
          child: FawkesVideoPlayerWithControls(fawkesController: _controller)),
    );
  }

  AnimatedWidget _defaultRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return _buildFullScreenVideo(context, animation);
      },
    );
  }

  Widget _fullScreenRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _defaultRoutePageBuilder(
      context,
      animation,
      secondaryAnimation,
    );
  }

  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final TransitionRoute<Null> route = PageRouteBuilder<Null>(
      pageBuilder: _fullScreenRoutePageBuilder,
    );

    SystemChrome.setEnabledSystemUIOverlays([]);
    if (_controller.value.aspectRatio < 1) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else if (_controller.value.aspectRatio > 1) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    if (!_controller.allowScreenToSleepInFullScreenMode) {
      Wakelock.enable();
    }

    await Navigator.of(context, rootNavigator: true).push(route);
    _isFullScreen = false;
    _controller.exitFullScreen();

    // The wakelock plugins checks whether it needs to perform an action internally,
    // so we do not need to check Wakelock.isEnabled.
    Wakelock.disable();

    SystemChrome.setEnabledSystemUIOverlays(
        _controller.systemOverlaysAfterFullScreen ?? [SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations(
        _controller.deviceOrientationsAfterFullScreen);
  }

  @override
  Widget build(BuildContext context) {
    return FawkesVideoPlayerWithControls(
      fawkesController: _controller,
    );
  }
}
