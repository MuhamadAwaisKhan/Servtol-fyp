import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:servtol/util/AppColors.dart';

class MessageScreen extends StatefulWidget {
  final String chatWithId;
  final String chatWithName;
  final String? chatWithPicUrl;

  const MessageScreen({
    Key? key,
    required this.chatWithId,
    required this.chatWithName,
    this.chatWithPicUrl,
  }) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _previewImage;
  String? _conversationId;
  String? _replyingToMessage;
  final ScrollController _scrollController = ScrollController();
  bool _isUserAtBottom = true;

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent - 50) {
      _isUserAtBottom = true;
    } else {
      _isUserAtBottom = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeConversation();
    _messageController.addListener(() {
      _updateTypingState(_messageController.text.isNotEmpty);
      _scrollController.addListener(_scrollListener);
    });
  }

  void _initializeConversation() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final conversationId =
          _generateConversationId(currentUser.uid, widget.chatWithId);
      setState(() {
        _conversationId = conversationId;
      });
    }
  }

  Future<File?> compressImage(File file) async {
    final targetPath = file.path.replaceFirst('.jpg', '_compressed.jpg');
    return await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File compressed =
          await compressImage(File(pickedFile.path)) ?? File(pickedFile.path);
      setState(() {
        _previewImage = compressed;
      });
    }
  }

  String _generateConversationId(String userId, String otherUserId) {
    return userId.compareTo(otherUserId) < 0
        ? '$userId\_$otherUserId'
        : '$otherUserId\_$userId';
  }

  void _sendMessage({String? imageUrl}) async {
    final messageContent = imageUrl ?? _messageController.text.trim();
    if (messageContent.isEmpty || _conversationId == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final messageData = {
        'messageContent': messageContent,
        'messageType': imageUrl != null ? 'image' : 'text',
        'senderId': currentUser.uid,
        'sentAt': FieldValue.serverTimestamp(),
        'read': false,
        'replyTo': _replyingToMessage,
      };

      await _firestore
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .add(messageData);

      await _firestore.collection('conversations').doc(_conversationId).set({
        'participants': [currentUser.uid, widget.chatWithId],
        'lastMessage': imageUrl != null ? '[Image]' : messageContent,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _messageController.clear();
        _previewImage = null;
        _replyingToMessage = null;
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  void _updateTypingState(bool isTyping) async {
    if (_conversationId == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _firestore.collection('conversations').doc(_conversationId).update({
      'typing.${currentUser.uid}': isTyping,
    });
  }

  void _markMessagesAsSeen() async {
    if (_conversationId == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messagesRef = _firestore
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages');

    final unseenMessages = await messagesRef
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: currentUser.uid)
        .get();

    for (var doc in unseenMessages.docs) {
      await doc.reference.update({'read': true});
    }
  }

  // Helper to compare if two dates are the same
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildMessageList() {
    if (_conversationId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('conversations')
            .doc(_conversationId)
            .collection('messages')
            .orderBy('sentAt', descending: false) // Oldest to newest
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final messages = snapshot.data!.docs;

          // Mark messages as seen
          _markMessagesAsSeen();

          // Render messages
          List<Widget> messageWidgets = [];
          String? lastDateLabel;

          for (var i = 0; i < messages.length; i++) {
            final messageData = messages[i].data() as Map<String, dynamic>;
            final isSentByUser =
                messageData['senderId'] == _auth.currentUser!.uid;
            final messageContent =
                messageData['messageContent'] ?? '[Message missing]';
            final messageType = messageData['messageType'] ?? 'text';
            final replyTo = messageData['replyTo'];
            final timestamp = messageData['sentAt'] as Timestamp;
            final messageDate = timestamp.toDate();

            final localMessageDate = messageDate.toLocal();
            final now = DateTime.now();

            // Determine date label
            String dateLabel;
            if (isSameDate(localMessageDate, now)) {
              dateLabel = "Today";
            } else if (isSameDate(
                localMessageDate, now.subtract(Duration(days: 1)))) {
              dateLabel = "Yesterday";
            } else {
              dateLabel = DateFormat('MMMM d, yyyy').format(localMessageDate);
            }

            if (lastDateLabel != dateLabel) {
              messageWidgets.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
              lastDateLabel = dateLabel;
            }

            // Add the message widget
            messageWidgets.add(
              GestureDetector(
                onLongPress: () {
                  _handleMessageLongPress(
                    context,
                    messages[i],
                    messageContent,
                    isSentByUser,
                  );
                },
                child: Align(
                  alignment: isSentByUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSentByUser ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (replyTo != null)
                          Text(
                            'Replying to: $replyTo',
                            style: const TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        if (messageType == 'text')
                          Text(
                            messageContent,
                            style: TextStyle(
                              color: isSentByUser ? Colors.white : Colors.black,
                            ),
                          )
                        else if (messageType == 'image')
                          GestureDetector(
                            onTap: () => _previewImageDialog(messageContent),
                            child: Image.network(
                              messageContent,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Text(
                            'Unsupported message type',
                            style: TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('h:mm a').format(localMessageDate),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
          });

          return ListView(
            controller: _scrollController,
            children: messageWidgets,
          );
        },
      ),
    );
  }

// Handle message long press actions (with delete option)
  void _handleMessageLongPress(BuildContext context, QueryDocumentSnapshot doc,
      String messageContent, bool isSentByUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Options'),
          actions: [
            TextButton(
              child: const Text('Reply'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _replyingToMessage = messageContent;
                });
              },
            ),
            if (isSentByUser)
              TextButton(
                child: const Text('Delete'),
                onPressed: () async {
                  try {
                    await doc.reference.delete();
                    Navigator.of(context).pop();
                  } catch (e) {
                    print("Error deleting message: $e");
                    Navigator.of(context).pop();
                  }
                },
              ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _previewImageDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow closing by tapping outside
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          // Close dialog on tap outside
          child: Container(
            color: Colors.black.withOpacity(0.8), // Dark background
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    // Allow panning
                    boundaryMargin: EdgeInsets.all(20),
                    // Margin around the image
                    minScale: 0.1,
                    // Minimum zoom level
                    maxScale: 4.0,
                    // Maximum zoom level
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context), // Close dialog
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Column(
      children: [
        if (_replyingToMessage != null)
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Replying to: $_replyingToMessage',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _replyingToMessage = null;
                    });
                  },
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.image, color: Colors.lightBlue),
                onPressed: _selectImage,
              ),
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
              ),              SizedBox(width: 5),

              CircleAvatar(
                backgroundColor: Colors.blue,
                child: IconButton(
                  icon: FaIcon(FontAwesomeIcons.paperPlane,
                      color: Colors.white, size: 18),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.chatWithPicUrl != null
                  ? NetworkImage(widget.chatWithPicUrl!)
                  : null,
              child: widget.chatWithPicUrl == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatWithName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(
                        widget.chatWithId,
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.data() is Map<String, dynamic>) {
                      final userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      return Text(
                        userData['status'] ?? 'Offline',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildMessageList(),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
