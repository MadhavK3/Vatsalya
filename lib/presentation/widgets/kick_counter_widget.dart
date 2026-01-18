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
  final Stopwatch _stopwatch = Stopwatch();
  bool _showCelebration = false;

  void _incrementKicks() {
    setState(() {
      _sessionKicks++;
      if (_sessionKicks == 10) {
        _showCelebration = true;
      }
    });

    if (_sessionKicks == 10) {
      // Auto-hide celebration after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showCelebration = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isSessionActive)
          _buildActiveSessionCard(context)
        else
          _buildStartCard(context),
        
        if (_showCelebration)
          _buildCelebrationOverlay(),
      ],
    );
  }

  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.2),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary, size: 100),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Great Job!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '10 kicks reached! Your baby is active!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: Theme.of(context).cardTheme.shape,
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.touch_app, color: Theme.of(context).colorScheme.primary),
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
                    _showCelebration = false;
                    _stopwatch.reset();
                    _stopwatch.start();
                  });
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      shape: Theme.of(context).cardTheme.shape,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Session Active',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isSessionActive = false),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              key: ValueKey(_sessionKicks),
              tween: Tween(begin: 1.0, end: 1.2),
              duration: const Duration(milliseconds: 100),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: _sessionKicks > 0 ? value : 1.0,
                  child: child,
                );
              },
              child: Text(
                '$_sessionKicks',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text('Kicks detected', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _incrementKicks,
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 40),
                    Text('TAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextButton.icon(
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
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Finish and Save Session'),
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
