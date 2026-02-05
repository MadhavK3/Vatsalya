import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/iot_providers.dart';
import 'package:maternal_infant_care/presentation/pages/iot_dashboard_page.dart';

class IoTStatusWidget extends ConsumerWidget {
  const IoTStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(iotControllerProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IoTDashboardPage()),
          );
        },
        customBorder: Theme.of(context).cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.hub, color: Colors.teal, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Devices',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    devicesAsync.when(
                      data: (devices) {
                        final connected = devices.where((d) => d.isConnected).length;
                        return Text(
                          '$connected active devices',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        );
                      },
                      loading: () => const Text('Loading...'),
                      error: (_, __) => const Text('Status unavailable'),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
