class FawkesUtils {
  /// the role of this function is to accept the current position duration of video playback
  /// and then format it into a pretty, human readable string
  static String formatCurrentPosition(Duration currentPosition) {
    if (currentPosition == null) return '';

    String formattedDuration = '';

    int seconds = currentPosition.inSeconds;

    int displaySeconds = seconds % 60;

    if (displaySeconds > 9) {
      formattedDuration = '$displaySeconds';
    } else {
      formattedDuration = '0$displaySeconds';
    }

    int minutes = seconds ~/ 60;
    if (minutes > 99) minutes = minutes % 60;

    if (minutes == 0) {
      formattedDuration = '00:' + formattedDuration;
    } else if (minutes < 99) {
      if (minutes <= 9) {
        formattedDuration = '0$minutes:' + formattedDuration;
      } else {
        formattedDuration = '$minutes:' + formattedDuration;
      }
    }

    int hours = seconds ~/ 3600;

    if (hours > 0) {
      if (hours <= 9) {
        formattedDuration = '0$hours:' + formattedDuration;
      } else {
        formattedDuration = '$hours:' + formattedDuration;
      }
    }

    return formattedDuration;
  }
}
