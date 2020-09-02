class FawkesDataSourceException implements Exception {
  String _message;

  FawkesDataSourceException(
      {String message =
          'There was a problem with the source provided to FawkesVideoPlayer'}) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
