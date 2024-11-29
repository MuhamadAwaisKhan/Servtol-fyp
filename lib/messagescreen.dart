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
    _updateOnlineStatus(
        'Online'); // Set status to Online when the user enters the chat
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
      // Compress image before displaying it
      File compressed =
          await compressImage(File(pickedFile.path)) ?? File(pickedFile.path);
      setState(() {
        _previewImage = compressed;
      });
    }
  }

  Widget _buildImagePreview() {
    if (_previewImage != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _previewImage!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _previewImage = null; // Cancel the image selection
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text("Cancel"),
                ),
                SizedBox(width: 20),
                // Send button
                TextButton(
                  onPressed: () async {
                    await _sendImageMessage(); // Send the image
                    setState(() {
                      _previewImage = null; // Reset after sending
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    textStyle: TextStyle(fontSize: 16),
                  ),
                  child: Text("Send"),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return SizedBox.shrink(); // If no image is selected, return empty widget
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
        'replyTo': _replyingToMessage,
        'replyToType': _replyingToMessage != null && _replyingToMessage!.startsWith('https')
            ? 'image'
            : 'text',
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
        // 'readBy': FieldValue.arrayRemove([currentUser.uid]), // Remove sender from readBy
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

    try {
      await _firestore.collection('conversations').doc(_conversationId).update({
        'typing.${currentUser.uid}': isTyping,
      });
    } catch (e) {
      print("Error updating typing state: $e");
    }
  }

  void _markMessagesAsSeen() async {
    if (_conversationId == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Fetch the conversation document to get the current 'readBy' array
      final conversationDoc = await _firestore.collection('conversations').doc(_conversationId).get();
      final readBy = List<String>.from(conversationDoc.data()?['readBy'] ?? []);

      // Only update if the current user's ID is not already in 'readBy'
      if (!readBy.contains(currentUser.uid)) {
        await _firestore.collection('conversations').doc(_conversationId).update({
          'readBy': FieldValue.arrayUnion([currentUser.uid]),
        });
      }
    } catch (e) {
      print("Error updating read receipts: $e");
    }
  }  // Helper to compare if two dates are the same
  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<String?> _getConversationId() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      return _generateConversationId(currentUser.uid, widget.chatWithId);
    }
    return null;
  }

  Widget _buildMessageList() {
    return Expanded(
        child: FutureBuilder<String?>(
            future: _getConversationId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              _conversationId = snapshot.data;

              if (_conversationId == null) {
                return const Center(child: Text('No conversation found.'));
              }

              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('conversations')
                    .doc(_conversationId)
                    .collection('messages')
                    .orderBy('sentAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final messages = snapshot.data!.docs;

                  // Mark messages as seen
                  _markMessagesAsSeen();
                  // Render messages
                  List<Widget> messageWidgets = [];
                  String? lastDateLabel;

                  for (var i = 0; i < messages.length; i++) {
                    final messageData =
                    messages[i].data() as Map<String, dynamic>;
                    final isSentByUser =
                        messageData['senderId'] == _auth.currentUser!.uid;
                    final messageContent =
                        messageData['messageContent'] ?? '[Message missing]';
                    final messageType = messageData['messageType'] ?? 'text';
                    // final replyTo = messageData['replyTo'];
                    final timestamp = messageData['sentAt'];
                    final isRead =
                        messageData['readBy'] ?? false; // Get the read status
                    DateTime? messageDate;

                    if (timestamp != null && timestamp is Timestamp) {
                      messageDate = timestamp.toDate();
                    } else {
                      // Handle the case where the timestamp is null (optional default value)
                      messageDate =
                          DateTime.now(); // or any other default value
                    }
                    final replyTo = messageData['replyTo'];
                    final replyToType = messageData['replyToType'] ?? 'text'; // Get reply type

                    final localMessageDate = messageDate.toLocal();
                    final now = DateTime.now();
                    if (replyTo != null) {
                      if (replyTo.startsWith('https'))
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Replying with an image:',
                              style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Image.network(
                              replyTo,
                              height: 100,
                              // Adjust the height as needed
                              width: 100,
                              // Adjust the width as needed
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return const Text(
                                  'Error loading image',
                                  style: TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ],
                        );

                    } else
                      Text(
                        'Replying to: $replyTo',
                        style: const TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    // Determine date label
                    String dateLabel;
                    if (isSameDate(localMessageDate, now)) {
                      dateLabel = "Today";
                    } else if (isSameDate(
                        localMessageDate, now.subtract(Duration(days: 1)))) {
                      dateLabel = "Yesterday";
                    } else {
                      dateLabel =
                          DateFormat('MMMM d, yyyy').format(localMessageDate);
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
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  0.3, // Adjust the multiplier as needed
                            ),
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                              isSentByUser ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Handle the `replyTo` display logic
                                if (replyTo != null)
                                  if (replyTo.startsWith('https'))
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Replying with an image:',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        Image.network(
                                          replyTo,
                                          height: 100,
                                          // Adjust the height as needed
                                          width: 100,
                                          // Adjust the width as needed
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Text(
                                              'Error loading image',
                                              style: TextStyle(fontSize: 10),
                                            );
                                          },
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      'Replying to: $replyTo',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),

                                // Handle message content display logic
                                if (messageType == 'text')
                                  Text(
                                    messageContent,
                                    style: TextStyle(
                                      color: isSentByUser
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  )
                                else if (messageType == 'image')
                                  GestureDetector(
                                    onTap: () =>
                                        _previewImageDialog(messageContent),
                                    child: Image.network(
                                      messageContent,
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Text(
                                          'Error loading image',
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

                                // Display the message timestamp
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateFormat('h:mm a')
                                          .format(localMessageDate),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    if (isSentByUser)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: StreamBuilder<DocumentSnapshot>(
                                          stream: _firestore.collection('conversations').doc(_conversationId).snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              final data = snapshot.data!.data() as Map<String, dynamic>?;
                                              final readBy = List<String>.from(data?['readBy'] ?? []);

                                              // Check if the recipient's ID is in the 'readBy' array
                                              bool isRead = readBy.contains(widget.chatWithId);

                                              return Icon(
                                                isRead ? Icons.done_all : Icons.done,
                                                size: 15,
                                                color: isRead ? Colors.amberAccent : Colors.black,
                                              );
                                            }
                                            return Icon(Icons.done, size: 15); // Default to one tick while loading
                                          },
                                        ),
                                      ),

                                  ],
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
              );
            }));
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Get a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('message_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the image to Firebase Storage
      final uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() => {});

      // Get the image URL after uploading
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _sendImageMessage() async {
    if (_previewImage == null) return;

    final imageUrl = await _uploadImage(_previewImage!);
    if (imageUrl != null) {
      _sendMessage(imageUrl: imageUrl);
    }
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
                icon: const FaIcon(FontAwesomeIcons.image,
                    color: Colors.lightBlue),
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
                    onChanged: (text) {
                      _updateTypingState(text
                          .isNotEmpty); // Update typing state on text change
                    },
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
        ),
        // Add image preview above the input field
        if (_previewImage != null) _buildImagePreview(),
      ],
    );
  }

  bool isCurrentUserCustomer() {
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.uid.startsWith('C')) {
      return true; // It's a customer
    } else if (currentUser != null && currentUser.uid.startsWith('P')) {
      return false; // It's a provider
    }
    return false; // Default to false if the UID doesn't match either pattern
  }

  void _updateOnlineStatus(String status) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // Determine the correct collection based on the current user's ID
        final collectionName = isCurrentUserCustomer() ? 'customer' : 'provider';

        // Get a reference to the user's document
        final userDocRef = _firestore.collection(collectionName).doc(currentUser.uid);

        // Use set() with merge: true to update only the status field
        await userDocRef.set({
          'status': status,
        }, SetOptions(merge: true));

      } catch (e) {
        print("Error updating online status: $e");
      }
    } else {
      print("Current user is null in _updateOnlineStatus");
    }
  }
  void dispose() {
    _updateOnlineStatus(
        'Offline'); // Set status to Offline when the user leaves the chat
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Row(
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
            Expanded( // Ensures content fits in the remaining space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatWithName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Avoids overflow
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection(widget.chatWithId.startsWith('C') ? 'customer' : 'provider')
                        .doc(widget.chatWithId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.data() != null) {
                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        final userStatus = userData['status'] ?? 'Offline';
                        return Text(
                          userStatus,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('conversations')
                        .doc(_conversationId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data?.data() != null) {
                        final conversationData = snapshot.data!.data() as Map<String, dynamic>;

                        // Safely access the 'typing' field and its contents
                        final typingData = conversationData['typing'] as Map<String, dynamic>?;

                        if (typingData != null && typingData[widget.chatWithId] == true) {
                          return Text('${widget.chatWithName} is typing...');
                        }
                      }

                      // Return an empty widget or placeholder when there's no typing indicator
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
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