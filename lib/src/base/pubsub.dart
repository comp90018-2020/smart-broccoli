/// Publish subscribe topics
class PubSubTopics {
  static const String route = "route";
  static const String reset = "reset";
}

/// Base class for publish subscribe class
abstract class PubSubBase {
  void subscribe(String topic, Function callback);
  void unsubscribe(String topic, Function callback);
  void publish(String topic, {dynamic arg});
}

/// Publish/subscribe
class PubSub extends PubSubBase {
  /// Channels, which holds a list of functions for subscribers which are
  /// called with a topic is emitted.
  Map<String, List<Function>> _channels = {};

  PubSub();

  /// Subscribe to topic
  void subscribe(String topic, Function callback) {
    // Initialise list
    if (!_channels.containsKey(topic)) {
      _channels[topic] = [];
    }
    _channels[topic].add(callback);
  }

  /// Unsubscribe from topic
  void unsubscribe(String topic, Function callback) {
    if (!_channels.containsKey(topic)) return;
    _channels[topic].remove(callback);
  }

  /// Publish topic
  void publish(String topic, {dynamic arg}) {
    // No subscribers
    if (!_channels.containsKey(topic)) return;

    // Call functions
    for (Function func in _channels[topic]) {
      if (arg != null) {
        func(arg);
      } else {
        func();
      }
    }
  }
}
