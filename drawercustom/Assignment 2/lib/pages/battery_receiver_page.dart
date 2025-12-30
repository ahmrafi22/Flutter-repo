import 'package:flutter/material.dart';
import 'dart:async';
import 'package:battery_plus/battery_plus.dart';

class BatteryReceiverPage extends StatefulWidget {
  const BatteryReceiverPage({super.key});

  @override
  State<BatteryReceiverPage> createState() => _BatteryReceiverPageState();
}

class _BatteryReceiverPageState extends State<BatteryReceiverPage> {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  bool _isCharging = false;
  bool _isListening = false;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });

    // Get initial battery level
    try {
      final level = await _battery.batteryLevel;
      if (mounted) {
        setState(() {
          _batteryLevel = level;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _batteryLevel = 85;
        });
      }
    }

    try {
      final state = await _battery.batteryState;
      if (mounted) {
        setState(() {
          _isCharging =
              (state == BatteryState.charging || state == BatteryState.full);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCharging = false;
        });
      }
    }

    try {
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
        (BatteryState state) async {
          if (mounted) {
            setState(() {
              _isCharging =
                  (state == BatteryState.charging ||
                  state == BatteryState.full);
            });
          }

          try {
            final level = await _battery.batteryLevel;
            if (mounted) {
              setState(() {
                _batteryLevel = level;
              });
            }
          } catch (e) {
            // Do Nothing
          }
        },
        onError: (error) {
          debugPrint('Battery state stream error: $error');
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Battery monitoring not available on emulator. Will work on real device.',
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _stopListening() {
    _batteryStateSubscription?.cancel();
    setState(() {
      _isListening = false;
    });
  }

  Color _getBatteryColor(int level) {
    if (level > 60) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  IconData _getBatteryIcon(int level, bool charging) {
    if (charging) return Icons.battery_charging_full;
    if (level > 80) return Icons.battery_full;
    if (level > 60) return Icons.battery_5_bar;
    if (level > 40) return Icons.battery_4_bar;
    if (level > 20) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Notification Receiver'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.broadcast_on_home, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'System Battery Receiver',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            // Battery Status Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getBatteryColor(_batteryLevel).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Transform.rotate(
                    angle: 1.5708, 
                    child: Icon(
                      _getBatteryIcon(_batteryLevel, _isCharging),
                      size: 100,
                      color: _getBatteryColor(_batteryLevel),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_batteryLevel%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getBatteryColor(_batteryLevel),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isCharging
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isCharging ? Icons.power : Icons.power_off,
                          size: 16,
                          color: _isCharging ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isCharging ? 'Charging' : 'Not Charging',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isCharging ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isListening
                            ? _stopListening
                            : _startListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening
                              ? Colors.red
                              : Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_isListening ? Icons.stop : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(
                              _isListening ? 'Stop' : 'Start',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
