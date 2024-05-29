import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'Messages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures binding is initialized before calling Firebase.initializeApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase connection established'); // Print confirmation message
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMBot',
      theme: ThemeData(brightness: Brightness.dark),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        title: Text('AMBot'),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: MessagesScreen(messages: messages)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: Colors.deepPurple,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage(_controller.text);
                      _controller.clear();
                    },
                    icon: Icon(Icons.send),
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
      print('Message is empty');
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
      print('Error: $e');
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
                      ? Colors.grey.shade800
                      : Colors.grey.shade900.withOpacity(0.8),
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
