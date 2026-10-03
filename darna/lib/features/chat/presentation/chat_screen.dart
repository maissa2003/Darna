import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../home/presentation/auth_provider.dart';
import '../../listings/models/property.dart';
import '../data/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final Property property;
  final String studentId;
  final String ownerId;

  const ChatScreen({
    super.key,
    required this.property,
    required this.studentId,
    required this.ownerId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();

  String get _conversationId => ChatRepository.conversationId(
    propertyId: widget.property.id,
    studentId: widget.studentId,
    ownerId: widget.ownerId,
  );

  @override
  void initState() {
    super.initState();
    ChatRepository.markRead(
      _conversationId,
      context.read<AuthProvider>().user?.id ?? '',
    );
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    final user = context.read<AuthProvider>().user;
    if (text.isEmpty || user == null) return;
    await ChatRepository.send(
      propertyId: widget.property.id,
      studentId: widget.studentId,
      ownerId: widget.ownerId,
      senderId: user.id,
      text: text,
    );
    _text.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final messages = ChatRepository.messages(_conversationId);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.property.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFEAF4F1),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.home_work_outlined, color: Color(0xFF0E7C7B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.property.pricePerMonth.toInt()} TND / mois - ${widget.property.city}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Posez une question au proprietaire.'),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(18),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final mine = message.senderId == user?.id;
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: mine
                                ? const Color(0xFF0E7C7B)
                                : const Color(0xFFE9ECEB),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: mine ? Colors.white : Colors.black87,
                              height: 1.35,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ecrire un message...',
                        filled: true,
                        fillColor: const Color(0xFFF2F4F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF0E7C7B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
