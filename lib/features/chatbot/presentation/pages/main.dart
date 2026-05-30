import 'package:chatbot/core/ui/theme/app_colors.dart';
import 'package:chatbot/features/chatbot/domain/entities/message_model.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<MessageModel> messages = [];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add(MessageModel(text: _controller.text, sender: 'user', sendTimeStamp: DateTime.now()));

      // Resposta fake do bot (placeholder)
      messages.add(MessageModel(text: 'Resposta do bot (simulada)', sender: 'bot', sendTimeStamp: DateTime.now()));
    });

    _controller.clear();
  }

  Widget buildMessage(MessageModel message) {
    bool isUser = message.sender == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Color(0xFF3A5DA2) : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text ?? '',
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: const Text('ChatBot', style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.p04,  
        actions: [
          Icon(Icons.more_vert, color: Colors.white,)
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/image1.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return buildMessage(messages[index]);
                  },
                ),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
