class FawkesControllerException implements Exception {
  String _message;

  FawkesControllerException(
      {String message = 'There was a problem with the FawkesController'}) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}
