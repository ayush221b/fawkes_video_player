import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../models/hls/hls_quality.dart';

class FawkesHLSService {
  /// This function will accept a m3u8 url and then parse the manifest file that is fetches
  /// in order to fetch all the available resolutions for this
  static Future<List<FawkesHLSQuality>> fetchAvailableResolutions(
      {@required String hlsLink}) async {
    List<FawkesHLSQuality> _availableQualities = <FawkesHLSQuality>[];
    try {
      // Request the manifest file
      http.Response response = await http.get(hlsLink);
      // Check if the request was successful
      if (response.statusCode >= 200 &&
          response.statusCode <= 300 &&
          response.bodyBytes != null) {
        // Decode the response to get the string
        String manifestContent = utf8.decode(response.bodyBytes);

        // Prepare the regex for extracting stream info entries available in the manifest
        RegExp streamInfRegex = new RegExp(
          r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)",
          caseSensitive: false,
          multiLine: true,
        );

        // Get the matches for the stream info entries
        List<RegExpMatch> streamInfMatches =
            streamInfRegex.allMatches(manifestContent).toList();
        // Check if we actually got any matches or not
        if (streamInfMatches != null && streamInfMatches.length > 0) {
          streamInfMatches.forEach((RegExpMatch streamInf) {
            String resolution = (streamInf.group(1)).toString();
            String sourceurl = (streamInf.group(3)).toString();
            final urlValidityRegex =
                new RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
            final fileNameWithExtensionRegex = new RegExp(r'(.*)\r?\/');
            final isNetwork = urlValidityRegex.hasMatch(sourceurl);
            final match = fileNameWithExtensionRegex.firstMatch(hlsLink);
            if (!isNetwork) {
              final dataurl = match.group(0);
              sourceurl = "$dataurl$sourceurl";
            }
            if (resolution != null && sourceurl != null) {
              _availableQualities.add(FawkesHLSQuality(
                  resolution: resolution, sourceUrl: sourceurl));
            }
          });
        }
      }
    } catch (err, stacktrace) {
      print(err);
      print(stacktrace);
    }
    return _availableQualities;
  }
}
