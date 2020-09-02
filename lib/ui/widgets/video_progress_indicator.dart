import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Displays the play/buffering status of the video controlled by [controller].
///
/// If [allowScrubbing] is true, this widget will detect taps and drags and
/// seek the video accordingly.
///
/// [padding] allows to specify some extra padding around the progress indicator
/// that will also detect the gestures.
class FawkesVideoProgressIndicator extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  FawkesVideoProgressIndicator(this.controller,
      {VideoProgressColors colors,
      this.allowScrubbing,
      this.padding = const EdgeInsets.only(top: 5.0),
      this.thumbColor = Colors.white,
      this.thumbSize = 12.0,
      this.thumbBottomPosition = -4,
      this.thumbWidget})
      : colors = colors ?? VideoProgressColors();

  /// The [VideoPlayerController] that actually associates a video with this
  /// widget.
  final VideoPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VideoProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  final Widget thumbWidget;

  final double thumbSize;

  final Color thumbColor;

  final double thumbBottomPosition;

  @override
  _FawkesVideoProgressIndicatorState createState() =>
      _FawkesVideoProgressIndicatorState();
}

class _FawkesVideoProgressIndicatorState
    extends State<FawkesVideoProgressIndicator> {
  _FawkesVideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.initialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Padding(
        padding: widget.padding,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              overflow: Overflow.visible,
              children: [
                Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    LinearProgressIndicator(
                      value: maxBuffering / duration,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colors.bufferedColor),
                      backgroundColor: colors.backgroundColor,
                    ),
                    LinearProgressIndicator(
                      value: position / duration,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colors.playedColor),
                      backgroundColor: Colors.transparent,
                    ),
                  ],
                ),
                Positioned(
                  bottom: widget.thumbBottomPosition,
                  child: widget.thumbWidget ??
                      Container(
                        height: widget.thumbSize,
                        width: widget.thumbSize,
                        margin: EdgeInsets.only(
                            left: (position / duration) * constraints.maxWidth),
                        decoration: BoxDecoration(
                            color: widget.thumbColor, shape: BoxShape.circle),
                      ),
                )
              ],
            );
          },
        ),
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }

    if (widget.allowScrubbing) {
      return _VideoScrubber(
        child: progressIndicator,
        controller: controller,
      );
    } else {
      return progressIndicator;
    }
  }
}

class _VideoScrubber extends StatefulWidget {
  _VideoScrubber({
    @required this.child,
    @required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}
