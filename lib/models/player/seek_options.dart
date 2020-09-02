class FawkesSeekOptions {
  /// The duration by which the video should go backward when the left
  /// action icon is pressed in the centeral controls
  final Duration backwardSeekDuration;

  /// The duration by which the video should go forward when the right
  /// action icon is pressed in the centeral controls
  final Duration forwardSeekDuration;
  FawkesSeekOptions({
    this.backwardSeekDuration,
    this.forwardSeekDuration,
  });
}
