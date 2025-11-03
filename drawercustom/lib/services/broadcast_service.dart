class BroadcastService {
  static final BroadcastService _instance = BroadcastService._internal();
  factory BroadcastService() => _instance;
  BroadcastService._internal();

  String? _lastBroadcastMessage;
  DateTime? _lastBroadcastTime;

  void saveLastBroadcast(String message) {
    _lastBroadcastMessage = message;
    _lastBroadcastTime = DateTime.now();
  }

  String? get lastBroadcastMessage => _lastBroadcastMessage;
  DateTime? get lastBroadcastTime => _lastBroadcastTime;

  bool get hasLastBroadcast => _lastBroadcastMessage != null;
}
