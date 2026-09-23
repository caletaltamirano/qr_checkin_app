/// Thrown when an operation needs the server but the device is offline.
class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}
