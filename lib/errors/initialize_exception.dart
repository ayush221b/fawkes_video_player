class FawkesNotInitializedException implements Exception {
  String _message;

  FawkesNotInitializedException(
      {String message = 'FawkesController was not initialized'}) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
