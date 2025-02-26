import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sehatsathi/util/colors.dart';

class HealthRecommendationScreen extends StatefulWidget {
  const HealthRecommendationScreen({super.key});

  @override
  State<HealthRecommendationScreen> createState() =>
      _HealthRecommendationScreenState();
}

class _HealthRecommendationScreenState
    extends State<HealthRecommendationScreen> {
  ChatUser myself = ChatUser(id: '1', firstName: 'User');
  ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];

  final oururl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=AIzaSyBUwE0gGDgr0HQGiy0pvD-UA-C7p_EINXY';
  final header = {'Content-Type': 'application/json'};

  String? symptoms;
  String? age;
  String? gender;
  String? height;
  String? weight;

  getdata(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    if (symptoms == null) {
      symptoms = m.text;
      allMessages.insert(
          0,
          ChatMessage(
              text: "Enter your age:", user: bot, createdAt: DateTime.now()));
    } else if (age == null) {
      age = m.text;
      allMessages.insert(
          0,
          ChatMessage(
              text: "Enter your gender (Male/Female/Other):",
              user: bot,
              createdAt: DateTime.now()));
    } else if (gender == null) {
      gender = m.text;
      allMessages.insert(
          0,
          ChatMessage(
              text: "Enter your height (in cm):",
              user: bot,
              createdAt: DateTime.now()));
    } else if (height == null) {
      height = m.text;
      allMessages.insert(
          0,
          ChatMessage(
              text: "Enter your weight (in kg):",
              user: bot,
              createdAt: DateTime.now()));
    } else if (weight == null) {
      weight = m.text;
      sendToGemini();
    }
    typing.remove(bot);
    setState(() {});
  }

  sendToGemini() async {
    var data = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "I have the following symptoms: $symptoms. My age is $age, gender is $gender, height is $height cm, and weight is $weight kg. Provide health recommendations."
            }
          ]
        }
      ]
    };

    await http
        .post(Uri.parse(oururl), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        String botResponse =
            result['candidates'][0]['content']['parts'][0]['text'];
        allMessages.insert(
            0,
            ChatMessage(
                text: botResponse, user: bot, createdAt: DateTime.now()));
      } else {
        allMessages.insert(
            0,
            ChatMessage(
                text: "Error occurred while fetching recommendations.",
                user: bot,
                createdAt: DateTime.now()));
      }
    }).catchError((e) {
      allMessages.insert(
          0,
          ChatMessage(
              text: "An error occurred: $e",
              user: bot,
              createdAt: DateTime.now()));
    });

    symptoms = age = gender = height = weight = null;
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
        title: Text('AI Health Recommendation',
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
                image: AssetImage('assets/images/health.webp'),
                fit: BoxFit.cover)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 10),
          child: DashChat(
            typingUsers: typing,
            currentUser: myself,
            onSend: (ChatMessage m) {
              getdata(m);
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
                hintText: 'Enter symptoms...',
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
