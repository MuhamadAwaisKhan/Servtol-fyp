import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MessageScreen extends StatefulWidget {
  final String chatWithId;
  final String chatWithName;
  final String? chatWithPicUrl;

  MessageScreen({
    required this.chatWithId,
    required this.chatWithName,
    this.chatWithPicUrl,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  void _initializeConversation() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _conversationId = _initializeConversationId(currentUser.uid, widget.chatWithId);
    }
  }

  String _initializeConversationId(String userId, String otherUserId) {
    return userId.compareTo(otherUserId) < 0 ? '$userId\_$otherUserId' : '$otherUserId\_$userId';
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _conversationId == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messageData = {
      'senderId': currentUser.uid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    _firestore
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .add(messageData);

    _firestore.collection('conversations').doc(_conversationId).set({
      'userId': currentUser.uid == widget.chatWithId ? currentUser.uid : widget.chatWithId,
      'providerId': currentUser.uid == widget.chatWithId ? widget.chatWithId : currentUser.uid,
      'lastMessage': message,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _messageController.clear();
  }

  Widget _buildMessageList() {
    if (_conversationId == null) return Center(child: CircularProgressIndicator());

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages yet"));
        }

        final messages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var messageData = messages[index];
            bool isSentByUser = messageData['senderId'] == _auth.currentUser!.uid;

            return Align(
              alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: isSentByUser ? Colors.blue : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomLeft: isSentByUser ? Radius.circular(12) : Radius.circular(0),
                    bottomRight: isSentByUser ? Radius.circular(0) : Radius.circular(12),
                  ),
                ),
                child: Text(
                  messageData['message'],
                  style: TextStyle(
                    color: isSentByUser ? Colors.white : Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatWithPicUrl ?? 'https://example.com/default_pic.png'),
            ),
            SizedBox(width: 10),
            Text(
              widget.chatWithName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
