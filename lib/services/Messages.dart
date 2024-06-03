import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final ScrollController scrollController;
  const MessagesScreen({Key? key, required this.messages, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(messages[index]['message']),
                    if (messages[index]['imageUrl'] != null)
                      Image.network(
                        messages[index]['imageUrl'],
                        width: 100, // Adjust the width as needed
                        height: 100, // Adjust the height as needed
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}