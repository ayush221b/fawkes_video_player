import 'dart:async';

import 'package:flutter/material.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_position.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper_package.dart';
import 'package:video_player/video_player.dart';

import '../controllers/fawkes_controller.dart';
import '../errors/controller_exception.dart';
import '../models/fawkes_dimensions.dart';
import 'widgets/controls/bottom_position_info.dart';
import 'widgets/controls/bottom_progress_controls.dart';
import 'widgets/controls/central_controls.dart';
import 'widgets/controls/options_bottom_sheet.dart';
import 'widgets/fawkes_control_button.dart';
import 'widgets/loading_indicator.dart';

class FawkesVideoPlayerWithControls extends StatefulWidget {
  /// The FawkesController instance
  final FawkesController fawkesController;

  const FawkesVideoPlayerWithControls(
      {Key key, @required this.fawkesController})
      : super(key: key);
  @override
  _FawkesVideoPlayerWithControlsState createState() =>
      _FawkesVideoPlayerWithControlsState();
}

class _FawkesVideoPlayerWithControlsState
    extends State<FawkesVideoPlayerWithControls> {
  // Get the controller instance passed to the widget
  FawkesController get _controller {
    if (this.widget.fawkesController == null) {
      throw FawkesControllerException(
          message: 'The fawkes controller must not be null');
    }
    return this.widget.fawkesController;
  }

  // Whether the listsner has been attached or not
  bool _attachedListener = false;

  // The current position of the video playback
  Duration _currentPosition;

  // We will use this to hide controls when playing a video
  bool _hideControls = false;

  // Timer which will orchestrate the visibility of controls on interaction with screen
  Timer _controlVisibilityTimer;

  @override
  void initState() {
    super.initState();
    _hideControls = _controller.autoPlay;

    _controller.addListener(() {
      if (!mounted) return;
      if (_controller.isLoading) {
        if (mounted) setState(() {});
      }
      if (_controller.flutterVideoPlayerController != null &&
          _controller.isPlaying &&
          !_hideControls) {
        if (mounted)
          setState(() {
            _hideControls = true;
          });
      }
      if (!_attachedListener &&
          !_controller.isLoading &&
          _controller.flutterVideoPlayerController != null &&
          !_controller.hasError) {
        _controller.flutterVideoPlayerController
            .addListener(_flutterVideoPlayerListener);
      }
    });
  }

  // remove the listeners attached to flutter video player
  _removeFlutterVideoPlayerListeners() {
    _controller.flutterVideoPlayerController
        .removeListener(_flutterVideoPlayerListener);
    if (mounted)
      setState(() {
        _attachedListener = false;
      });
  }

  @override
  void dispose() {
    if (_controlVisibilityTimer != null) _controlVisibilityTimer.cancel();
    super.dispose();
  }

  void _flutterVideoPlayerListener() {
    if (mounted)
      setState(() {
        _currentPosition = _controller.value.position;
        if (!_attachedListener) _attachedListener = true;
      });
  }

  // Seek the video playback backward
  _seekBackward() async {
    await _controller.seekTo(_controller.value.position -
        _controller.seekOptions.backwardSeekDuration);
  }

  // Seek the video playback forward
  _seekForward() async {
    await _controller.seekTo(_controller.value.position +
        _controller.seekOptions.forwardSeekDuration);
  }

  // Handle the dynamic visibility of controls
  void _handleControlsVisibility() {
    if (_controlVisibilityTimer != null) _controlVisibilityTimer.cancel();

    if (mounted)
      setState(() {
        _controlVisibilityTimer =
            Timer(_controller.controlVisibilityDuration, () {
          if (mounted)
            setState(() {
              if (_controller.isPlaying) {
                _hideControls = true;
              }
            });
        });
      });
  }

  // Handle settings button tap
  void _handleSettingsTap() async {
    bool _isCurrentlyPlaying = _controller.isPlaying;
    if (_isCurrentlyPlaying) _controller.pause();
    await showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        builder: (context) {
          return FawkesOptionsBottomSheet(
            playerTheme: _controller.playerTheme,
            controller: _controller,
            removeListeners: _removeFlutterVideoPlayerListeners,
          );
        });
    if (_isCurrentlyPlaying) _controller.play();
  }

  // Handle volume action tap
  void _handleVolumeActionTap() {
    if (_controller.value.volume == 0.0) {
      _controller.setVolume(100.0);
    } else {
      _controller.setVolume(0.0);
    }
    if (mounted) setState(() {});
  }

  // Build the overlay on top of the video being played, when controls are visible
  Widget _buildControlsBackgroundOverlay() {
    return Positioned.fill(
        child: Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black38,
    ));
  }

  // Get the controls for the player
  Widget _buildPlayerControls() {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _hideControls
            ? Container()
            : Stack(
                children: <Widget>[
                  _buildControlsBackgroundOverlay(),
                  FawkesCentralControls(
                    controller: _controller,
                    seekBackward: _seekBackward,
                    seekForward: _seekForward,
                    playerTheme: _controller.playerTheme,
                  ),
                  FawkesBottomProgressControls(
                      flutterVideoPlayerController:
                          _controller.flutterVideoPlayerController,
                      playerTheme: _controller.playerTheme),
                  FawkesBottomPositionInfo(
                      currentPosition: _currentPosition,
                      totalDuration: _controller.value.duration,
                      playerTheme: _controller.playerTheme),
                  Positioned.fill(
                    bottom: 32,
                    right: 18,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FawkesControlButton(
                              onTap: _handleVolumeActionTap,
                              svgPath: _controller.isMuted
                                  ? 'lib/assets/icons/muted.svg'
                                  : 'lib/assets/icons/unmuted.svg',
                              size: 20,
                              color: Colors.white),
                          SizedBox(
                            width: 10,
                          ),
                          if (_controller.isHLSStream ||
                              (_controller.subtitles != null &&
                                  _controller.subtitles.length > 0))
                            FawkesControlButton(
                                onTap: _handleSettingsTap,
                                svgPath: null,
                                icon: Icons.settings,
                                size: 20,
                                color: Colors.white),
                          SizedBox(
                            width: 10,
                          ),
                          FawkesControlButton(
                              onTap: () {
                                _controller.toggleFullScreen();
                              },
                              svgPath: null,
                              icon: _controller.isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              size: 20,
                              color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Build the core video player content
  Widget _buildVideoPlayerContent() {
    return _controller.isLoading
        ? Center(
            child: FawkesLoadingIndicator(
            includeText: false,
          ))
        : _controller.hasError
            ? Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'There was an error playing this video',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                fit: _controller.wrapperProperties.wrapperType ==
                        FawkesWrapperType.FIT
                    ? StackFit.loose
                    : StackFit.expand,
                children: [_buildCorePlayer(), _buildPlayerControls()],
              );
  }

  _buildCorePlayer() {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: SubTitleWrapper(
          subtitleStyle: SubtitleStyle(
              hasBorder: false,
              fontSize: 14,
              textColor: Colors.white,
              backgroundColor: Colors.black.withOpacity(0.6),
              padding: EdgeInsets.all(2),
              position: SubtitlePosition(bottom: 20)),
          subtitleController: SubtitleController(
              showSubtitles: _controller.showSubtitles,
              subtitleUrl: _controller.selectedSubtitle?.subtitleUrl ?? ''),
          videoPlayerController: _controller.flutterVideoPlayerController,
          videoChild: Listener(
              onPointerUp: (details) => _handleControlsVisibility(),
              onPointerDown: (details) {
                if (_hideControls && mounted)
                  setState(() {
                    _hideControls = false;
                  });
              },
              child: VideoPlayer(_controller.flutterVideoPlayerController))),
    );
  }

  // Layout the video player on the screen
  Widget _buildFawkesPlayer() {
    if (_controller.wrapperProperties.wrapperType == FawkesWrapperType.FIT) {
      return _buildVideoPlayerContent();
    } else if (_controller.wrapperProperties.wrapperType ==
        FawkesWrapperType.FILL) {
      return SizedBox.expand(child: _buildVideoPlayerContent());
    } else {
      return Container(
          height: _controller.wrapperProperties.height,
          width: _controller.wrapperProperties.width,
          margin: _controller.wrapperProperties.margin,
          padding: _controller.wrapperProperties.padding,
          decoration: _controller.wrapperProperties.boxDecoration,
          child: Center(child: _buildVideoPlayerContent()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFawkesPlayer();
  }
}
