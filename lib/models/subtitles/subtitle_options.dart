import 'package:subtitle_wrapper_package/subtitle_controller.dart';

class FawkesSubtitleOptions {
  /// The type of subtitle file being processed
  /// Defaults to `SubtitleType.webvtt`
  final SubtitleType subtitleType;

  FawkesSubtitleOptions({this.subtitleType = SubtitleType.webvtt});

  FawkesSubtitleOptions copyWith({
    SubtitleDecoder decoder,
    SubtitleType subtitleType,
  }) {
    return FawkesSubtitleOptions(
      subtitleType: subtitleType ?? this.subtitleType,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is FawkesSubtitleOptions && o.subtitleType == subtitleType;
  }

  @override
  int get hashCode => subtitleType.hashCode;
}
