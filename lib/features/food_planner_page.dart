import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sehatsathi/util/colors.dart';

class FoodPlannerPage extends StatefulWidget {
  const FoodPlannerPage({super.key});

  @override
  State<FoodPlannerPage> createState() => _FoodPlannerPageState();
}

class _FoodPlannerPageState extends State<FoodPlannerPage> {
  ChatUser myself = ChatUser(id: '1', firstName: 'User');
  ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  final oururl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=AIzaSyBUwE0gGDgr0HQGiy0pvD-UA-C7p_EINXY';
  final header = {'Content-Type': 'application/json'};

  getDietRecommendation(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    String disease = m.text;

    var data = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "I am suffering from $disease. Provide a detailed diet plan and recommended foods to overcome this disease. Include meal suggestions, nutrients, and any foods to avoid."
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(oururl),
        headers: header,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        String botResponse =
            result['candidates'][0]['content']['parts'][0]['text'];

        allMessages.insert(
          0,
          ChatMessage(text: botResponse, user: bot, createdAt: DateTime.now()),
        );
      } else {
        allMessages.insert(
          0,
          ChatMessage(
              text: "Error occurred while fetching recommendations.",
              user: bot,
              createdAt: DateTime.now()),
        );
      }
    } catch (e) {
      allMessages.insert(
        0,
        ChatMessage(
            text: "An error occurred: $e",
            user: bot,
            createdAt: DateTime.now()),
      );
    }

    typing.remove(bot);
    setState(() {});
  }

  TextSpan formatText(String text) {
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in boldPattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('AI Diet Planner',
            style: GoogleFonts.josefinSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: maingreen,
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/dietimg.webp'),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 10),
          child: DashChat(
            typingUsers: typing,
            currentUser: myself,
            onSend: (ChatMessage m) {
              getDietRecommendation(m);
            },
            messages: allMessages,
            messageOptions: MessageOptions(
              avatarBuilder: yourAvatarBuilder,
              messageTextBuilder: (message, previousMessage, nextMessage) {
                return Text.rich(
                  formatText(message.text),
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
            inputOptions: InputOptions(
              alwaysShowSend: true,
              inputDecoration: InputDecoration(
                hintText: 'Enter a disease name...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget yourAvatarBuilder(
      ChatUser user, Function? onAvatarTap, Function? onAvatarLongPress) {
    return const CircleAvatar(
      backgroundImage: NetworkImage(
          'https://cdn-icons-png.flaticon.com/128/4751/4751166.png'),
      radius: 15,
    );
  }
}
