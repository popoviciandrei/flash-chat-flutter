import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';

final Firestore _firestore = Firestore.instance;
FirebaseUser loggedInuser;

class ChatScreen extends StatefulWidget {
  static String route = '/chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

const kMessagesCollection = 'messages';

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText;
  String name;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInuser = user;
        setState(() {
          name = loggedInuser.email;
        });
      }
    } catch (e) {
      // @TODO implement a nicer way to handle exceptions
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              }),
        ],
        title: Text('⚡️Chat - $name'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      // Input field for a new chat message
                      controller: messageTextController,
                      onChanged: (value) => messageText = value,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      try {
                        messageTextController.clear();
                        _firestore.collection(kMessagesCollection).add({
                          'sender': loggedInuser.email,
                          'text': messageText
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  /**
   * Check if email is the current user email
   */
  bool isCurrentUser(email) {
    return email == loggedInuser.email;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection(kMessagesCollection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        messages.forEach((message) {
          messageBubbles.add(
            MessageBubble(
              message: message.data['text'],
              sender: message.data['sender'],
              isCurrentUser: isCurrentUser(message.data['sender']),
            ),
          );
        });
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {@required this.message,
      @required this.sender,
      this.isCurrentUser = false});
  final String message;
  final String sender;
  final bool isCurrentUser;

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.w100 : FontWeight.bold,
                fontSize: 12.0,
                color: Colors.black54),
          ),
          Material(
            borderRadius: BorderRadius.circular(30.0),
            elevation: 5.0,
            color: Colors.lightBlueAccent,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
