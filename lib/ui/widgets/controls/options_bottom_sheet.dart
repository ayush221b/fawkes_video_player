import 'package:flutter/material.dart';

import '../../../controllers/fawkes_controller.dart';
import '../../../errors/controller_exception.dart';
import '../../../models/player/player_theme.dart';
import 'sheet_tile.dart';

enum FawkesSheetOptionsState { HOME, SELECT_QUALITY, SELECT_SUBTITLES }

class FawkesOptionsBottomSheet extends StatefulWidget {
  /// The player theme instance
  final FawkesPlayerTheme playerTheme;

  /// The fawkes controller instance
  final FawkesController controller;

  /// The method to remove the listeners, in case quality is being changed
  final VoidCallback removeListeners;

  const FawkesOptionsBottomSheet(
      {Key key,
      @required this.playerTheme,
      @required this.controller,
      @required this.removeListeners})
      : super(key: key);
  @override
  _FawkesOptionsBottomSheetState createState() =>
      _FawkesOptionsBottomSheetState();
}

class _FawkesOptionsBottomSheetState extends State<FawkesOptionsBottomSheet> {
  // Get the controller instance passed to the widget
  FawkesController get _controller {
    if (this.widget.controller == null) {
      throw FawkesControllerException(
          message: 'The fawkes controller must not be null');
    }
    return this.widget.controller;
  }

  // Get the player theme
  FawkesPlayerTheme get _playerTheme => this.widget.playerTheme;

  // The current state of the sheet options
  FawkesSheetOptionsState _currentState = FawkesSheetOptionsState.HOME;

  // What happens on back button press
  void _onBackButtonPress() {
    if (_currentState != FawkesSheetOptionsState.HOME) {
      setState(() {
        _currentState = FawkesSheetOptionsState.HOME;
      });
    } else {
      Navigator.pop(context);
    }
  }

  // Build the home content for playback options
  Widget _buildHomeContent() {
    return ListView(
      children: [
        Center(
          child: Text(
            'Playback Options',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        if (_controller.isHLSStream &&
            _controller.availableHLSQualities.length > 0)
          FawkesControlsSheetTile(
              titletext: 'Quality',
              onItemTap: () {
                if (_controller.availableHLSQualities.length > 0) {
                  setState(() {
                    _currentState = FawkesSheetOptionsState.SELECT_QUALITY;
                  });
                }
              },
              trailingText: _controller.playbackQuality == null
                  ? 'AUTO'
                  : _controller.playbackQuality.resolution.split('x')[1] + 'p',
              playerTheme: _playerTheme),
        if (_controller.subtitles != null && _controller.subtitles.length > 0)
          FawkesControlsSheetTile(
              titletext: 'Subtitles',
              onItemTap: () {
                if (_controller.availableHLSQualities.length > 0) {
                  setState(() {
                    _currentState = FawkesSheetOptionsState.SELECT_SUBTITLES;
                  });
                }
              },
              trailingText: _controller.selectedSubtitle == null
                  ? 'OFF'
                  : _controller.selectedSubtitle.languageName,
              playerTheme: _playerTheme),
      ],
    );
  }

  // Build the content to select a quality
  Widget _buildSelectQualityContent() {
    return Column(
      children: [
        Center(
          child: Text(
            'Select Quality',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              ..._controller.availableHLSQualities
                  .map<Widget>((e) => FawkesControlsSheetTile(
                      titletext: e.resolution.split('x')[1] + 'p',
                      onItemTap: () {
                        this.widget.removeListeners();
                        _controller.switchQuality(quality: e);
                        setState(() {});
                      },
                      trailingText: null,
                      trailingWidget: _controller.playbackQuality == e
                          ? Icon(Icons.check)
                          : Container(
                              height: 0,
                              width: 0,
                            ),
                      playerTheme: _playerTheme))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  // Build the content to select a subtitle
  Widget _buildSelectSubtitlesContent() {
    return Column(
      children: [
        Center(
          child: Text(
            'Select Subtitle',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              FawkesControlsSheetTile(
                  titletext: 'OFF',
                  onItemTap: () {
                    _controller.hideSubtitles();
                    setState(() {});
                  },
                  trailingText: null,
                  trailingWidget: _controller.selectedSubtitle == null
                      ? Icon(Icons.check)
                      : Container(
                          height: 0,
                          width: 0,
                        ),
                  playerTheme: _playerTheme),
              ..._controller.subtitles
                  .map<Widget>((e) => FawkesControlsSheetTile(
                      titletext: e.languageName,
                      onItemTap: () {
                        _controller.selectSubtitleForPlayback(e);
                        setState(() {});
                      },
                      trailingText: null,
                      trailingWidget: _controller.selectedSubtitle == e
                          ? Icon(Icons.check)
                          : Container(
                              height: 0,
                              width: 0,
                            ),
                      playerTheme: _playerTheme))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _switchContent() {
    switch (_currentState) {
      case FawkesSheetOptionsState.SELECT_QUALITY:
        return _buildSelectQualityContent();
      case FawkesSheetOptionsState.SELECT_SUBTITLES:
        return _buildSelectSubtitlesContent();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
            height: 300,
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            duration: Duration(milliseconds: 150),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: _switchContent()),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: _onBackButtonPress,
            ),
          ),
        ),
      ],
    );
  }
}
