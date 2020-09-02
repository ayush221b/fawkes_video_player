class FawkesWrapperException implements Exception {
  String _message;

  FawkesWrapperException(
      {String message =
          'There was a problem in laying out FawkesVideoPlayer'}) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
