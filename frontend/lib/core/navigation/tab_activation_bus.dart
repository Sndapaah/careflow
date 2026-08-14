import 'dart:async';

/// Broadcasts bottom-navigation tab selections to the persistent tab pages.
abstract final class TabActivationBus {
  static final StreamController<int> _controller =
      StreamController<int>.broadcast();

  static Stream<int> get stream => _controller.stream;

  static void notify(int index) => _controller.add(index);
}
