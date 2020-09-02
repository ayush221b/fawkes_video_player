import 'dart:collection';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import '../errors/data_source_exception.dart';
import '../errors/initialize_exception.dart';
import '../models/fawkes_dimensions.dart';
import '../models/fawkes_video_data_source.dart';
import '../models/hls/enums.dart';
import '../models/hls/hls_quality.dart';
import '../models/player/player_theme.dart';
import '../models/player/seek_options.dart';
import '../models/subtitle.dart';
import '../models/subtitles/subtitle_options.dart';
import '../services/hls_service.dart';

/// The FawkesController will be used to drive and manipulate the FawkesVideoPlayer
class FawkesController extends ChangeNotifier {
  /// The data source for the video
  final FawkesVideoDataSource videoDataSource;

  /// Whether the video player should be auto initialized or not
  /// By default this is set to `true`
  /// If you set this to `false`, you'll have to call the `initialize()` method manually
  final bool autoInitialize;

  /// Whether or not to allow the screen to go to sleep while the video is being played
  /// The default value for this is `false`
  final bool allowScreenToSleepInFullScreenMode;

  /// The video quality to default to, if you are passing a HLS Stream
  /// This value will have no impact if you are playing any video other than
  /// m3u8
  /// By default this will be set to `AUTO`
  final FawkesDefaultHlsQuality defaultStreamQuality;

  /// Whether the video should automatically play once its loaded
  /// By default this is set to `false`
  final bool autoPlay;

  /// Whether the video should start playback on mute
  /// By default this is set to `false`
  /// you can change the volumne later by calling the `setVolume`
  /// method on the controller instance
  final bool startOnMute;

  /// Whether the video should loop or not
  /// By default this is `false`
  /// you can change it later by calling the `setLooping`
  /// method on the controller instance
  final bool loopVideo;

  /// The list of subtitles which will be available for playback
  final List<FawkesSubtitle> subtitles;

  /// The position from which you want to start playback
  final Duration startPosition;

  // Instance of the official video player controller
  VideoPlayerController _videoPlayerController;

  // The selected subtitle that is to be played
  FawkesSubtitle _selectedSubtitle;

  // Whether the mode is full screen
  bool _isFullScreen = false;

  // Whether the video is being played is a HLS Stream or not
  bool _isHLSStream = false;

  // List of available qualities for the given hls stream
  List<FawkesHLSQuality> _availableHLSQualities = [];

  // The currently selected hls quality for playback
  FawkesHLSQuality _playbackQuality;

  // The wrapper properties for the video player
  FawkesWrapperProperties _wrapperProperties;

  /// The seek options for central video controls
  FawkesSeekOptions _seekOptions;

  /// The options to use for subtitle processing
  FawkesSubtitleOptions _subtitleOptions;

  /// The duration for which the controls will be visible when playback starts
  /// and the interaction with the screen is complete
  Duration _controlVisibilityDuration;

  /// The player theme
  FawkesPlayerTheme _playerTheme;

  // Whether we should show the subtitles or not
  bool _showSubtitles = false;

  /// Whether the video is currently muted or not
  bool _isMuted = false;

  // Whether the video player has error or not
  bool _hasError = false;

  // Error message for the player
  String _errorMessage;

  /// Defines if the player will start in fullscreen when play is pressed
  final bool fullScreenByDefault;

  /// Defines the system overlays visible after exiting fullscreen
  final List<SystemUiOverlay> systemOverlaysAfterFullScreen;

  /// Defines the set of allowed device orientations after exiting fullscreen
  final List<DeviceOrientation> deviceOrientationsAfterFullScreen;

  /// This callback will fire when fullscreen has been enabled
  final VoidCallback onFullScreenEnabled;

  /// This callback will fire when fullscreen has been disabled
  final VoidCallback onFullScreenDisabled;

  // Whether the controller is busy doing some work
  // and the loadingwidget should be displayed
  bool _isLoading = false;

  FawkesController(
      {@required this.videoDataSource,
      this.onFullScreenEnabled,
      this.onFullScreenDisabled,
      this.autoInitialize = true,
      this.allowScreenToSleepInFullScreenMode = false,
      this.defaultStreamQuality = FawkesDefaultHlsQuality.AUTO,
      this.subtitles,
      this.fullScreenByDefault = false,
      this.autoPlay = false,
      this.startOnMute = false,
      this.startPosition,
      this.systemOverlaysAfterFullScreen,
      this.deviceOrientationsAfterFullScreen = const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      this.loopVideo = false}) {
    assert(videoDataSource != null, 'The video data source must not be null');
    // The following checks ensure that whenever the controller is initialized
    // null is not passed to these by mistake
    assert(allowScreenToSleepInFullScreenMode != null,
        'Boolean value cannot be null');
    assert(autoPlay != null, 'Boolean value cannot be null');
    assert(startOnMute != null, 'Boolean value cannot be null');
    assert(loopVideo != null, 'Boolean value cannot be null');
    assert(autoInitialize != null, 'Boolean value cannot be null');
    _wrapperProperties = FawkesWrapperProperties();
    _seekOptions = FawkesSeekOptions(
        backwardSeekDuration: Duration(seconds: 10),
        forwardSeekDuration: Duration(seconds: 10));
    _controlVisibilityDuration = Duration(seconds: 3);
    _playerTheme = FawkesPlayerTheme();
    _subtitleOptions = FawkesSubtitleOptions();
    if (autoInitialize) {
      initialize();
    }
  }

  /// Exposes the VideoPlayerValue instance of the underlying player
  VideoPlayerValue get value {
    _checkInitializedGuard();

    return _videoPlayerController.value;
  }

  FawkesWrapperProperties get wrapperProperties => _wrapperProperties;

  FawkesSeekOptions get seekOptions => _seekOptions;

  Duration get controlVisibilityDuration => _controlVisibilityDuration;

  FawkesPlayerTheme get playerTheme => _playerTheme;

  FawkesSubtitleOptions get subtitleOptions => _subtitleOptions;

  bool get isPlaying {
    return value.isPlaying;
  }

  bool get isLooping {
    return value.isLooping;
  }

  bool get isBuffering {
    return value.isBuffering;
  }

  /// Exposes flutter's videoPlayerController that is being used under the hood
  /// Please note that it is strongly recommended that you use the fawkesController
  /// for performing operations related to playback
  /// Use this value only when you know what you are doing
  VideoPlayerController get flutterVideoPlayerController {
    return _videoPlayerController;
  }

  /// Exposes whether or not a stream is a HLS Stream or not
  bool get isHLSStream => _isHLSStream;

  bool get isFullScreen => _isFullScreen;

  /// Exposes the list of available playback qualities for a HLS Stream
  List<FawkesHLSQuality> get availableHLSQualities => _availableHLSQualities;

  /// Exposes the currently selected hls quality which is being/about to be
  /// played back
  FawkesHLSQuality get playbackQuality => _playbackQuality;

  /// Whether the subtitles are to be shown or not
  bool get showSubtitles => _showSubtitles;

  /// The subtitle which is currently selected for playback
  FawkesSubtitle get selectedSubtitle => _selectedSubtitle;

  /// Exposes whether the video player has error or not
  bool get hasError => _hasError;

  /// Exposes the error encountered by the video player
  String get errorMessage => _errorMessage;

  /// Exposes whether the controller is currently busy doing some work
  bool get isLoading => _isLoading;

  /// Whether the video is currently muted or not
  bool get isMuted => _isMuted;

  /// Set the wrapper properties for the video player
  void setWrapperProperties(FawkesWrapperProperties properties) {
    if (properties == null) return;
    _wrapperProperties = properties;
    notifyListeners();
  }

  /// Set the seek options for the video player
  void setSeekOptions(FawkesSeekOptions seekOptions) {
    if (seekOptions == null) return;
    _seekOptions = seekOptions;
    notifyListeners();
  }

  /// Set the controls visibility duration for the video player
  void setControlsVisibilityDuration(Duration duration) {
    if (duration == null) return;
    _controlVisibilityDuration = duration;
    notifyListeners();
  }

  /// Set the player theme for the video player
  void setPlayerTheme(FawkesPlayerTheme theme) {
    if (theme == null) return;
    _playerTheme = theme;
    notifyListeners();
  }

  /// Set the subtitle options used for processing of the same
  void setSubtitleOptions(FawkesSubtitleOptions options) {
    if (options == null) return;
    _subtitleOptions = options;
    notifyListeners();
  }

  /// Initialise the fawkes video player controller
  /// Calling this function will parse through the provided video data source and
  /// identify the available resolutions (if an HLS stream is provided)
  Future<void> initialize() async {
    setLoading(true);
    // Complete the initialization process of video player
    await _resetVideoPlayer();

    // Perform the post initialization actions, as required
    await _postInitializationActions(
        shouldPlay: autoPlay,
        shouldMute: startOnMute,
        shouldLoop: loopVideo,
        position: startPosition);

    if (fullScreenByDefault) {
      _videoPlayerController.addListener(_fullScreenListener);
    }
    setLoading(false);
  }

  // Reset/Initialise the video player instance
  Future<bool> _resetVideoPlayer() async {
    // If the dataSource is null, there is no point in initialising
    if (videoDataSource == null) return false;

    // Clear the specifics
    _resetVideoSpecifics();

    try {
      if (videoDataSource.sourceType == FawkesVideoSourceType.FILE) {
        // Check if we have a legit file on the provided path
        File _sourceFile = File(videoDataSource.path);
        if (_sourceFile == null)
          throw FawkesDataSourceException(
              message: 'The file path provided is invalid');
        _videoPlayerController = VideoPlayerController.file(_sourceFile);
      } else if (videoDataSource.sourceType == FawkesVideoSourceType.ASSET) {
        _videoPlayerController =
            VideoPlayerController.asset(videoDataSource.path);
      } else {
        // Now that we know the data source is a network file, let's check if it's a HLS Stream
        if (videoDataSource.path.endsWith('.m3u8')) {
          // Okay, yayy! This is a HLS stream let's perform our analysis now
          _isHLSStream = true;

          // First up, we need to get the available resolutions for this stream
          _availableHLSQualities =
              await FawkesHLSService.fetchAvailableResolutions(
                  hlsLink: videoDataSource.path);
          _sortHLSQualities();
          // Now that we have the qualities, let's see what the user selected to have as the initial quality
          // If the quality is set to auto, we have to pass the defalt path to videoPlayerController
          if (defaultStreamQuality == FawkesDefaultHlsQuality.AUTO) {
            _videoPlayerController =
                VideoPlayerController.network(videoDataSource.path);
          } else {
            _selectDefaultHLSUrl();
            _videoPlayerController =
                VideoPlayerController.network(_playbackQuality.sourceUrl);
          }
        } else {
          // Since this url is not a HLS Stream, let's go ahead and construct the video player controller
          // No deep analysis is required in this case
          _videoPlayerController =
              VideoPlayerController.network(videoDataSource.path);
        }
      }

      // Proceed to initialising the controller
      await _videoPlayerController.initialize();

      // Return true
      return true;
    } catch (err, stacktrace) {
      // Set the error value
      _errorMessage = err.toString();
      _hasError = true;
      notifyListeners();

      print(err);
      print(stacktrace);
      return false;
    }
  }

  // This function is used for taking the actions as preferred by the user, post initialization
  Future<void> _postInitializationActions(
      {bool shouldPlay = true,
      bool shouldMute = false,
      bool shouldLoop = false,
      Duration position}) async {
    if (shouldPlay) {
      await play();
    }
    if (position != null) {
      await seekTo(position);
    }
    if (shouldMute) {
      await setVolume(0.0);
    }

    await setLooping(shouldLoop);
  }

  /// Sort the available HLS Qualities
  void _sortHLSQualities() {
    if (_availableHLSQualities.length > 0) {
      Map<FawkesHLSQuality, int> products = {};

      _availableHLSQualities.forEach((quality) {
        int dimension1 = int.tryParse(quality.resolution.split('x')[0]);
        int dimension2 = int.tryParse(quality.resolution.split('x')[1]);
        if (dimension1 != null && dimension2 != null) {
          int product = dimension1 * dimension2;
          products[quality] = product;
        }
      });

      var sortedKeys = products.keys.toList(growable: false)
        ..sort((k1, k2) => products[k1].compareTo(products[k2]));
      LinkedHashMap<FawkesHLSQuality, int> sortedMap =
          new LinkedHashMap.fromIterable(sortedKeys,
              key: (k) => k, value: (k) => products[k]);

      _availableHLSQualities = sortedMap.keys.toList();
    }
  }

  // Get the HLS sourceUrl as per quality set by default
  void _selectDefaultHLSUrl() {
    _playbackQuality = defaultStreamQuality == FawkesDefaultHlsQuality.HIGH
        ? _availableHLSQualities.last
        : _availableHLSQualities.first;
  }

  /// Switch the quality of the HLS Stream
  /// Make sure the quality object provided is available
  /// you can check the available qualities using the `availableHLSQualities` getter
  Future<void> switchQuality({@required FawkesHLSQuality quality}) async {
    if (quality == null ||
        quality.resolution == null ||
        quality.sourceUrl == null ||
        !availableHLSQualities.contains(quality)) return;

    try {
      bool shouldPlay = isPlaying;

      bool shouldMute = _isMuted;

      bool looping = value.isLooping;

      Duration currentPosition = value.position;

      // Prepare the Video Player Controller
      setLoading(true);

      //await _disposeAndResetController(updatedUrl: quality.sourceUrl);

      if (_videoPlayerController != null &&
          _videoPlayerController.value.initialized) {
        // Since it is already initialised, we must dispose it off and then continue with
        // the new initialisation process for the provided data source
        // If there was a controller, we need to dispose of the old one first
        final oldController = _videoPlayerController;

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await oldController.dispose();

          // Initing new controller
          _videoPlayerController =
              VideoPlayerController.network(quality.sourceUrl)
                ..initialize().then((value) async {
                  await _postInitializationActions(
                      shouldPlay: shouldPlay,
                      shouldMute: shouldMute,
                      shouldLoop: looping,
                      position: currentPosition);

                  setLoading(false);
                });
        });

        // Making sure that controller is not used by setting it to null
        _videoPlayerController = null;
        _playbackQuality = quality;
        notifyListeners();
      }
    } catch (err, stacktrace) {
      // Set the error value
      _errorMessage = err.toString();
      _hasError = true;
      notifyListeners();

      print(err);
      print(stacktrace);
      setLoading(false);
    }
  }

  void togglePause() {
    isPlaying ? pause() : play();
  }

  Future<void> play() async {
    if (value.position == value.duration) {
      await seekTo(Duration.zero);
    }
    await _videoPlayerController.play();
    notifyListeners();
  }

  Future<void> setLooping(bool looping) async {
    await _videoPlayerController.setLooping(looping);
    notifyListeners();
  }

  Future<void> pause() async {
    await _videoPlayerController.pause();
    notifyListeners();
  }

  Future<void> seekTo(Duration moment) async {
    await _videoPlayerController.seekTo(moment);
    notifyListeners();
  }

  void _fullScreenListener() async {
    if (_videoPlayerController.value.isPlaying && !_isFullScreen) {
      enterFullScreen();
      _videoPlayerController.removeListener(_fullScreenListener);
    }
  }

  void enterFullScreen() {
    _isFullScreen = true;
    notifyListeners();
    if (onFullScreenEnabled != null) onFullScreenEnabled();
  }

  void exitFullScreen() {
    _isFullScreen = false;
    notifyListeners();
    if (onFullScreenDisabled != null) onFullScreenDisabled();
  }

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    if (volume < 0) volume = 0.0;
    await _videoPlayerController.setVolume(volume);
    if (volume == 0.0) {
      _isMuted = true;
    } else {
      _isMuted = false;
    }
    notifyListeners();
  }

  /// Select subtitle for playback
  /// The subtitle being passed here must be a part of the `subtitles`
  /// that were passed while creating the controller instance
  void selectSubtitleForPlayback(FawkesSubtitle subtitle) {
    if (subtitles == null ||
        subtitles.length == 0 ||
        subtitle == null ||
        !subtitles.contains(subtitle)) return;
    _selectedSubtitle = subtitle;
    _showSubtitles = true;
    notifyListeners();
  }

  /// Hide subtitles from being displayed
  void hideSubtitles() {
    _showSubtitles = false;
    _selectedSubtitle = null;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    if (_videoPlayerController != null &&
        _videoPlayerController.value.initialized) {
      await _videoPlayerController.dispose();
    }
    super.dispose();
  }

  // Reset the sepecific information that is stored about the video
  void _resetVideoSpecifics() {
    _hasError = false;
    _errorMessage = null;
    _isHLSStream = false;
    _availableHLSQualities = [];
  }

  // Is the videoPlayerController not null and initialised properly
  void _checkInitializedGuard() {
    if (_videoPlayerController == null) throw FawkesNotInitializedException();
  }

  // Set the isLoading status
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
