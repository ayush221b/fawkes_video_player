import 'package:meta/meta.dart';

class FawkesSubtitle {
  /// The language name of the subtitle
  final String languageName;

  /// The language code of the subtitles
  final String languageCode;

  /// The url to the subtitle file
  final String subtitleUrl;

  FawkesSubtitle(
      {@required this.languageName,
      @required this.subtitleUrl,
      this.languageCode});

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is FawkesSubtitle &&
        o.languageName == languageName &&
        o.languageCode == languageCode &&
        o.subtitleUrl == subtitleUrl;
  }

  @override
  int get hashCode =>
      languageName.hashCode ^ languageCode.hashCode ^ subtitleUrl.hashCode;
}
