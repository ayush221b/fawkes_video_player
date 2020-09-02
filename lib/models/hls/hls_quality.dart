import 'package:meta/meta.dart';

/// The purpose of this class is to parse and store the different HLS Resolutions available
class FawkesHLSQuality {
  /// The resolution being offered
  final String resolution;

  /// The m3u8 url to the resolution being offered
  final String sourceUrl;

  FawkesHLSQuality({
    @required this.resolution,
    @required this.sourceUrl,
  });

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is FawkesHLSQuality &&
        o.resolution == resolution &&
        o.sourceUrl == sourceUrl;
  }

  @override
  int get hashCode => resolution.hashCode ^ sourceUrl.hashCode;

  @override
  String toString() =>
      'FawkesHLSQuality(resolution: $resolution, sourceUrl: $sourceUrl)';
}
