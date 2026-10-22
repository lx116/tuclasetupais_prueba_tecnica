/// Whether the contacts are available to features that depend on the list.
///
/// There is no cache: when the list call fails, nothing is available to the
/// detail until a later list call succeeds.
class ContactsAvailability {
  bool _isAvailable = true;

  bool get isAvailable => _isAvailable;

  void markFailed() => _isAvailable = false;

  void markAvailable() => _isAvailable = true;
}
