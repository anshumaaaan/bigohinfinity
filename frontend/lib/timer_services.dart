// timer_service.dart
import 'dart:async';

class TimerService {
  Timer? _timer;

  void startTimer({required Duration interval, required Function callback}) {
    stopTimer(); // Stop any existing timer

    _timer = Timer.periodic(interval, (timer) {
      callback();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isRunning => _timer != null && _timer!.isActive;
}
