import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:intl/intl.dart';

class KickCounterWidget extends ConsumerStatefulWidget {
  const KickCounterWidget({super.key});

  @override
  ConsumerState<KickCounterWidget> createState() => _KickCounterWidgetState();
}

class _KickCounterWidgetState extends ConsumerState<KickCounterWidget> {
  bool _isSessionActive = false;
  int _sessionKicks = 0;
  DateTime? _sessionStartTime;
  Stopwatch _stopwatch = Stopwatch();

  @override
  Widget build(BuildContext context) {
    if (_isSessionActive) {
      return _buildActiveSessionCard(context);
    }
    return _buildStartCard(context);
  }

  Widget _buildStartCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.touch_app, color: Colors.pink),
                ),
                const SizedBox(width: 12),
                Text(
                  'Kick Counter',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Track your baby\'s movement patterns.'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isSessionActive = true;
                    _sessionStartTime = DateTime.now();
                    _sessionKicks = 0;
                    _stopwatch.reset();
                    _stopwatch.start();
                  });
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionCard(BuildContext context) {
    return Card(
      color: Colors.pink[50], // Soft pink background
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Session Active',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.pink[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_sessionKicks kicks',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _sessionKicks++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('TAP KICK!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                _stopwatch.stop();
                if (_sessionKicks > 0) {
                  final repo = await ref.read(kickLogRepositoryProvider.future);
                  await repo.saveSession(
                    _sessionKicks, 
                    _stopwatch.elapsed,
                    startTime: _sessionStartTime,
                  );
                }
                setState(() {
                  _isSessionActive = false;
                });
              },
              child: const Text('Finish Session'),
            ),
          ],
        ),
      ),
    );
  }
}
