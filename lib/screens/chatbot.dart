import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<ChatbotScreen> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile(path: 'assets/dialog_flow_auth.json').then((instance) {
      setState(() {
        dialogFlowtter = instance;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RCBot'),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: MessagesScreen(messages: messages)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.brown,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) {
      _showAlertDialog(context, 'Empty Message', 'Please type in a message first.');
      return;
    }

    setState(() {
      addMessage(text, true);
    });

    try {
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: QueryInput(text: TextInput(text: text)),
      );

      if (response.message == null) return;

      setState(() {
        addMessage(response.message!.text!.text![0]);
      });
    } catch (e) {
      _showAlertDialog(context, 'Something Went Wrong', 'Error: : $e');
    }
  }

  void addMessage(String message, [bool isUserMessage = false]) {
    setState(() {
      messages.add({'message': message, 'isUserMessage': isUserMessage});
    });
  }
}

class MessagesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  const MessagesScreen({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.separated(
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: messages[index]['isUserMessage']
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(
                      messages[index]['isUserMessage'] ? 0 : 20,
                    ),
                    topLeft: Radius.circular(
                      messages[index]['isUserMessage'] ? 20 : 0,
                    ),
                  ),
                  color: messages[index]['isUserMessage']
                      ? Colors.brown
                      : Colors.brown.shade900.withOpacity(0.8),
                ),
                constraints: BoxConstraints(maxWidth: w * 2 / 3),
                child: Text(messages[index]['message']),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, i) => Padding(padding: EdgeInsets.only(top: 10)),
      itemCount: messages.length,
    );
  }
}
void _showAlertDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
