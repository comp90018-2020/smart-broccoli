/// Publish subscribe topics

enum PubSubTopic {
  ROUTE,
  TIMER,
  // From Firebase
  SESSION_START,
  SESSION_ACTIVATED,
  QUIZ_UPDATE,
  QUIZ_DELETE,
  QUIZ_CREATE,
  GROUP_UPDATE,
  GROUP_MEMBER_CHANGE,
  GROUP_DELETE,
  // For join page
  NAME_CHANGE,
  // For group deletion (while in group page)
  GROUP_DELETE_ACTIVE
}

/// Base class for publish subscribe class
abstract class PubSubBase {
  void subscribe(PubSubTopic topic, Function(dynamic) callback);
  void unsubscribe(PubSubTopic topic, Function(dynamic) callback);
  void publish(PubSubTopic topic, {dynamic arg});
}

/// Publish/subscribe
class PubSub extends PubSubBase {
  /// Channels, which holds a list of functions for subscribers which are
  /// called with a topic is emitted.
  Map<PubSubTopic, List<Function(dynamic)>> _channels = {};

  /// Instance held locally
  static final PubSub _singleton = PubSub._internal();

  /// Internal constructor
  PubSub._internal();

  /// PubSub instance
  factory PubSub() {
    return _singleton;
  }

  /// Subscribe to topic
  void subscribe(PubSubTopic topic, Function(dynamic) callback) {
    // Initialise list
    if (!_channels.containsKey(topic)) {
      _channels[topic] = [];
    }
    _channels[topic].add(callback);
  }

  /// Unsubscribe from topic
  void unsubscribe(PubSubTopic topic, Function(dynamic) callback) {
    if (!_channels.containsKey(topic)) return;
    _channels[topic].remove(callback);
  }

  /// Publish topic
  void publish(PubSubTopic topic, {dynamic arg}) {
    // No subscribers
    if (!_channels.containsKey(topic)) return;

    // Call functions
    _channels[topic].forEach((Function func) => func(arg));
  }
}
