import 'dart:async';

class EventBus {
  final StreamController<dynamic> _streamController;

  EventBus() : _streamController = StreamController<dynamic>.broadcast();

  Stream<T> on<T>() {
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  void fire(event) {
    _streamController.add(event);
  }

  void dispose() {
    _streamController.close();
  }
}

// Global EventBus instance
final EventBus eventBus = EventBus();

// Event for graph type selection
class GraphTypeSelectedEvent {
  final String graphType;
  GraphTypeSelectedEvent(this.graphType);
}

// Event for emergency signals
class EmergencySignalEvent {
  final DateTime timestamp;
  EmergencySignalEvent({DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

// Globally accessible variable for current graph type
String selectedGraphType = 'all'; // Default to show all graphs
