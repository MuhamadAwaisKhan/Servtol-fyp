import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  void _updateTyping(bool isTyping) {
    _firestore.collection('conversations').doc(_conversationId).set({
      'typing': {widget.chatWithId: isTyping},
    }, SetOptions(merge: true));
  }
  void addMessage(DocumentSnapshot message) {
    _listKey.currentState?.insertItem(0);
  }
  @override
  void initState() {
    super.initState();
    _initializeConversation();
    _messageController.addListener(() {
      _updateTyping(_messageController.text.isNotEmpty);
    });  }

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
      File compressed = await compressImage(File(pickedFile.path)) ?? File(pickedFile.path);
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
      };

      // Add message to Firestore
      await _firestore
          .collection('conversations')
          .doc(_conversationId)
          .collection('messages')
          .add(messageData);

      // Update or set conversation metadata
      await _firestore.collection('conversations').doc(_conversationId).set({
        'participants': [currentUser.uid, widget.chatWithId],
        'lastMessage': imageUrl != null ? '[Image]' : messageContent,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _messageController.clear();
        _previewImage = null;
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Future<void> _selectImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //
  //   if (pickedFile != null) {
  //     setState(() {
  //       _previewImage = File(pickedFile.path);
  //     });
  //   }
  // }

  void _clearPreview() {
    setState(() {
      _previewImage = null;
    });
  }

  Future<void> _uploadAndSendImage() async {
    if (_previewImage == null || _conversationId == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('conversations/$_conversationId/$fileName');

    try {
      final uploadTask = await storageRef.putFile(_previewImage!);
      final imageUrl = await uploadTask.ref.getDownloadURL();
      _sendMessage(imageUrl: imageUrl);
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Widget _buildPreviewImage() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              _previewImage!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.close, color: Colors.red),
                onPressed: _clearPreview,
              ),
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.check, color: Colors.blue),
                onPressed: _uploadAndSendImage,
              ),
            ],
          ),
        ],
      ),
    );
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
        .where('seenBy', arrayContains: currentUser.uid)
        .get();

    for (var doc in unseenMessages.docs) {
      await doc.reference.update({
        'seenBy': FieldValue.arrayUnion([currentUser.uid]),
      });
    }
  }

  Widget _buildMessageInput() {
    return Column(
      children: [
        if (_previewImage != null) _buildPreviewImage(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.image, color: Colors.blue),
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
              ),
              SizedBox(width: 5),
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
        )
      ],
    );
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
            .orderBy('sentAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
    if (!snapshot.hasData) return Container();
    if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
    print("Error loading messages: ${snapshot.error}");
    return Center(child: Text("Error: ${snapshot.error}"));
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    return const Center(child: Text("No messages yet"));
    }
    final typingData = snapshot.data?.get('typing') as Map<String, dynamic>? ?? {};
    final otherUserTyping = typingData[widget.chatWithId] ?? false;

    if (otherUserTyping) {
    return const Text(
    'User is typing...',
    style: TextStyle(fontSize: 12, color: Colors.grey),
    );
    }
          final messages = snapshot.data!.docs;

          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final messageData = messages[index].data() as Map<String, dynamic>;
              final isSentByUser =
                  messageData['senderId'] == _auth.currentUser!.uid;
              final messageContent =
                  messageData['messageContent'] ?? '[Message missing]';
              final messageType = messageData['messageType'] ?? 'text';

              // Mark message as seen if not sent by user
              if (!isSentByUser && !(messageData['read'] ?? false)) {
                messages[index].reference.update({'read': true});
              }

              return GestureDetector(
                onLongPress: () {
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
                              _messageController.text =
                              "Replying to: $messageContent";
                            },
                          ),
                          if (isSentByUser)
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () async {
                                try {
                                  await messages[index].reference.delete();
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
                },
                child: Align(
                  alignment:
                  isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
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
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.red),
                                );
                              },
                            ),
                          )
                        else
                          Text(
                            'Unsupported message type',
                            style: TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('h:mm a').format(
                            (messageData['sentAt'] as Timestamp).toDate(),
                          ),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Helper function to validate a URL
  bool _isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  void _previewImageDialog(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow closing by tapping outside
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context), // Close dialog on tap outside
          child: Container(
            color: Colors.black.withOpacity(0.8), // Dark background
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    panEnabled: true, // Allow panning
                    boundaryMargin: EdgeInsets.all(20), // Margin around the image
                    minScale: 0.1, // Minimum zoom level
                    maxScale: 4.0, // Maximum zoom level
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatWithPicUrl ??
                  'https://example.com/default_pic.png'),
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
      backgroundColor: AppColors.background,
      body: Column(
        children: [

          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
