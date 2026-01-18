import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/models/contraction_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ContractionTimerWidget extends ConsumerStatefulWidget {
  const ContractionTimerWidget({super.key});

  @override
  ConsumerState<ContractionTimerWidget> createState() => _ContractionTimerWidgetState();
}

class _ContractionTimerWidgetState extends ConsumerState<ContractionTimerWidget> {
  bool _isTiming = false;
  DateTime? _lastStartTime;
  DateTime? _lastEndTime;
  final Stopwatch _stopwatch = Stopwatch();
  // Timer to update UI every second
  Stream<int>? _timerStream;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                 Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timer, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                Text(
                  'Contraction Timer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
             if (_isTiming)
              StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 1), (i) => i),
                builder: (context, snapshot) {
                  final duration = _stopwatch.elapsed;
                  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
                  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
                  return Text(
                    '$minutes:$seconds',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              )
            else
              Text(
                '00:00',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                   color: Colors.grey[400],
                   fontWeight: FontWeight.bold,
                ),
              ),
              
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_isTiming) {
                          // Stop
                           final endTime = DateTime.now();
                           final duration = _stopwatch.elapsed;
                           _stopwatch.stop();
                           _stopwatch.reset();

                           final repo = await ref.read(contractionRepositoryProvider.future);
                           final history = repo.getContractions();
                           
                           // Calculate interval from previous contraction start
                           int interval = 0;
                           if (history.isNotEmpty) {
                             interval = _lastStartTime!.difference(history.first.startTime).inSeconds.abs(); 
                             // Wait, interval is usually start-to-start. 
                             // If this is the second contraction, difference between this start and last start.
                             // But since we just finished it, we need history to check last one.
                             // Correction: We need to check history for last entry BEFORE saving this one.
                             final last = history.first;
                             interval = _lastStartTime!.difference(last.startTime).inSeconds;
                           }

                           final contraction = ContractionModel(
                             id: const Uuid().v4(),
                             startTime: _lastStartTime!,
                             endTime: endTime,
                             durationSeconds: duration.inSeconds,
                             intervalSeconds: interval > 0 ? interval : 0, 
                           );
                           
                           await repo.addContraction(contraction);
                           
                           setState(() {
                             _isTiming = false;
                             _lastEndTime = endTime;
                           });
                        } else {
                          // Start
                          setState(() {
                            _isTiming = true;
                            _lastStartTime = DateTime.now();
                            _stopwatch.start();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTiming ? Colors.red : Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isTiming ? 'STOP Contraction' : 'START Contraction'),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            _buildHistoryList(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(WidgetRef ref) {
    // We need to watch the repository to update list
    final repoAsync = ref.watch(contractionRepositoryProvider);
    
    return repoAsync.when(
      data: (repo) {
        final contractions = repo.getContractions().take(3).toList();
        if (contractions.isEmpty) return const SizedBox(height: 10, child: Text('No history yet'));
        
        return Column(
          children: contractions.map((c) {
             final duration = Duration(seconds: c.durationSeconds);
             final min = duration.inMinutes;
             final sec = duration.inSeconds.remainder(60);
             
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${DateFormat('h:mm a').format(c.startTime)} - ${min}m ${sec}s'),
              subtitle: c.intervalSeconds > 0 
                ? Text('Interval: ${(c.intervalSeconds/60).toStringAsFixed(1)} min')
                : const Text('First record'),
              leading: const Icon(Icons.fiber_manual_record, size: 12, color: Colors.purple),
            );
          }).toList(),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_,__) => const Text('Error loading history'), 
    );
  }
}
