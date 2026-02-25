import 'package:flutter/material.dart';
import '../chat_screen.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String lastName;
  final String timeStamp;
  final String receiverName; // শুধু দেখানোর জন্য
  final String receiverId;   // ChatScreen-এ পাঠানোর জন্য

  const ChatTile({
    super.key,
    required this.chatId,
    required this.lastName,
    required this.timeStamp,
    required this.receiverName,
    required this.receiverId,
  });

  @override
  Widget build(BuildContext context) {
    String firstLetter =
    receiverName.isNotEmpty ? receiverName[0].toUpperCase() : "?";

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.blue,
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        receiverName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        lastName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        timeStamp,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              receivedId: receiverId,
            ),
          ),
        );
      },
    );
  }
}