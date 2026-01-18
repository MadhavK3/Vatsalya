import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/presentation/viewmodels/ai_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';

class ChatHistoryDrawer extends ConsumerWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoAsync = ref.watch(chatHistoryRepositoryProvider);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                Icon(Icons.history, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Text(
                  'Chat History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('New Chat'),
            onTap: () {
              ref.read(aiResponseProvider.notifier).startNewSession();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          Expanded(
            child: repoAsync.when(
              data: (repo) {
                // We need to listen to a stream or force rebuild when list changes.
                // For now, let's just fetch. To make it reactive, we might need a StreamProvider or similar 
                // but standard Hive usage often involves ValueListenable.
                // Let's use a simple StateProvider or similar in a real app, 
                // but here we can rely on parent rebuilding or just fetch on build.
                // Better approach: AiChatNotifier keeps track of sessions or helps refresh.
                // Simpler: Just query repo here.
                final sessions = repo.getSessions();
                
                if (sessions.isEmpty) {
                  return const Center(child: Text('No saved chats'));
                }

                return ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return Dismissible(
                      key: Key(session.id),
                      background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        repo.deleteSession(session.id);
                        // If current session is deleted, clear it? handled by notifier logic ideally
                        if (ref.read(aiResponseProvider.notifier).currentSessionId == session.id) {
                            ref.read(aiResponseProvider.notifier).startNewSession();
                        }
                      },
                      child: ListTile(
                        title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(DateFormat.yMMMd().add_jm().format(session.lastUpdated)),
                        onTap: () {
                          ref.read(aiResponseProvider.notifier).loadSession(session.id);
                          Navigator.pop(context);
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                             await repo.deleteSession(session.id);
                             if (ref.read(aiResponseProvider.notifier).currentSessionId == session.id) {
                                ref.read(aiResponseProvider.notifier).startNewSession();
                             }
                             // Force rebuild? In riverpod we might want a "sessionsProvider"
                             // Since we don't have one, simplistic way:
                             (context as Element).markNeedsBuild(); 
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e,s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
