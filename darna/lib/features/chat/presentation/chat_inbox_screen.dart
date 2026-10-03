import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/presentation/auth_provider.dart';
import '../../listings/data/property_repository.dart';
import '../data/chat_repository.dart';
import 'chat_screen.dart';

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null)
      return const Center(
        child: Text('Connectez-vous pour voir vos messages.'),
      );
    final latestByConversation = <String, dynamic>{};
    for (final message in ChatRepository.forUser(user.id)) {
      latestByConversation.putIfAbsent(message.conversationId, () => message);
    }
    final messages = latestByConversation.values.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: messages.isEmpty
          ? const Center(child: Text('Aucune conversation pour le moment.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final message = messages[index];
                final property = PropertyRepository.byId(message.propertyId);
                if (property == null) return const SizedBox.shrink();
                final otherName = message.ownerId == user.id
                    ? 'Etudiant interesse'
                    : 'Proprietaire';
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFD8EEE8),
                    child: Icon(
                      message.ownerId == user.id
                          ? Icons.person_outline
                          : Icons.home_work_outlined,
                      color: const Color(0xFF0E625A),
                    ),
                  ),
                  title: Text(
                    property.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '$otherName - ${message.text}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        property: property,
                        studentId: message.studentId,
                        ownerId: message.ownerId,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
