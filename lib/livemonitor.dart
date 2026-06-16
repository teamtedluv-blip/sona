import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mic_stream/mic_stream.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class LiveMonitor extends StatefulWidget {
  const LiveMonitor({super.key});

  @override
  State<LiveMonitor> createState() => _LiveMonitorPageState();
}

class _LiveMonitorPageState extends State<LiveMonitor> {
  Stream<List<int>>? _micStream;
  StreamSubscription<List<int>>? _subscription;

  double db = 0.0;
  double smoothedDb = 0.0;
  double baseline = 0.0;

  bool running = false;

  // 🎯 START MIC
  Future<void> start() async {
    try {
      _micStream = await MicStream.microphone(
        audioSource: AudioSource.MIC,
        sampleRate: 44100,
      );

      if (_micStream == null) return;

      _subscription = _micStream!.listen((List<int> samples) {
        if (samples.isEmpty) return;

        double rms = 0;

        for (final s in samples) {
          rms += s * s;
        }

        rms = sqrt(rms / samples.length);

        double currentDb = 20 * log(rms + 1e-7);

        // 🔥 smoothing (stable meter)
        smoothedDb = (smoothedDb * 0.85) + (currentDb * 0.15);

        setState(() {
          db = (smoothedDb - baseline).clamp(0, 100);
        });
      });

      setState(() => running = true);
    } catch (e) {
      debugPrint("Mic error: $e");
    }
  }

  // 🛑 STOP MIC
  void stop() {
    _subscription?.cancel();
    _subscription = null;

    setState(() => running = false);
  }

  // 🎯 CALIBRATION
  void calibrate() {
    setState(() {
      baseline = smoothedDb;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Calibrated to environment noise")),
    );
  }

  // 🟢 ZONE COLOR
  Color getColor() {
    if (db < 40) return Colors.green;
    if (db < 55) return Colors.yellow;
    if (db < 70) return Colors.orange;
    if (db < 85) return Colors.redAccent;
    return Colors.red;
  }

  String getZoneLabel() {
    if (db < 40) return "SAFE";
    if (db < 55) return "MODERATE";
    if (db < 70) return "ELEVATED";
    if (db < 85) return "HIGH";
    return "DANGEROUS";
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeDb = db.clamp(0, 100);
    final progress = safeDb / 100;

    return Scaffold(
      appBar: AppBar(title: const Text(" Noise Monitor"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 📊 GAUGE
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  interval: 20,

                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 40,
                      color: Colors.green,
                    ),
                    GaugeRange(
                      startValue: 40,
                      endValue: 55,
                      color: Colors.yellow,
                    ),
                    GaugeRange(
                      startValue: 55,
                      endValue: 70,
                      color: Colors.orange,
                    ),
                    GaugeRange(
                      startValue: 70,
                      endValue: 85,
                      color: Colors.redAccent,
                    ),
                    GaugeRange(
                      startValue: 85,
                      endValue: 100,
                      color: Colors.red,
                    ),
                  ],

                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: db.clamp(0, 100).toDouble(),
                      enableAnimation: true,
                    ),
                  ],

                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${db.toStringAsFixed(1)} dB",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getZoneLabel(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: getColor(),
                            ),
                          ),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.1,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 📏 SCALE LABELS
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("0"),
                Text("20"),
                Text("40"),
                Text("60"),
                Text("80"),
                Text("100"),
              ],
            ),

            const SizedBox(height: 30),

            // 🎛 CONTROLS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: calibrate,
                  icon: const Icon(Icons.tune),
                  label: const Text("Calibrate"),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: running ? stop : start,
                  icon: Icon(running ? Icons.stop : Icons.play_arrow),
                  label: Text(running ? "Stop" : "Start"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
