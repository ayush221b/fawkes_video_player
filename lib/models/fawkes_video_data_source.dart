import 'package:meta/meta.dart';

import '../errors/data_source_exception.dart';

enum FawkesVideoSourceType { FILE, NETWORK, ASSET }

/// To correctly parse information about the video to be played
class FawkesVideoDataSource {
  /// The type of video source
  final FawkesVideoSourceType sourceType;

  /// The path to the video
  /// This should be a local path if sourceType is set to `FawkesVideoSourceType.FILE`,
  /// and a valid network url if the sourceType is set to `FawkesVideoSourceType.NETWORK`
  /// Ensure that the video is present as an asset in your project, if you set this to `FawkesVideoSourceType.ASSET`
  final String path;

  FawkesVideoDataSource({@required this.sourceType, @required this.path}) {
    if (sourceType == null || path == null || path.length == 0) {
      throw FawkesDataSourceException(
          message:
              'sourceType must not be null, and path must not be null or an empty string');
    }
    if (sourceType == FawkesVideoSourceType.NETWORK &&
        !_isValidNetworkPath(path)) {
      throw FawkesDataSourceException(
          message:
              'sourceType was set to FawkesVideoSourceType.NETWORK but the path provided was invalid, please provide a valid network url');
    }
  }

  /// To check if we have a valid url when the fawkes video type is set to `NETWORK`
  bool _isValidNetworkPath(String networkpath) {
    final networkPathRegex = new RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');

    return networkPathRegex.hasMatch(networkpath);
  }

  FawkesVideoDataSource copyWith({
    FawkesVideoSourceType sourceType,
    String path,
  }) {
    return FawkesVideoDataSource(
      sourceType: sourceType ?? this.sourceType,
      path: path ?? this.path,
    );
  }
}
