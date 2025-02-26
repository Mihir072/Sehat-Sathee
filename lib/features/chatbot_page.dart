import 'dart:convert';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sehatsathi/util/colors.dart';

class ChatBotPage extends StatefulWidget {
  final String initialText;
  const ChatBotPage({super.key, required this.initialText});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  ChatUser myself = ChatUser(id: '1', firstName: 'Mihir');
  ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  final TextEditingController _controller = TextEditingController();

  final oururl =
      'https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=AIzaSyBUwE0gGDgr0HQGiy0pvD-UA-C7p_EINXY';

  final header = {'Content-Type': 'application/json'};

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText.isNotEmpty
        ? widget.initialText
        : "Enter a disease name to get a diet recommendation.";
  }

  getDietRecommendation(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    String disease = m.text.trim();

    var data = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "This is an medical report of patient $disease. Provide a detailed explaination of this report."
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

        // Remove bold headings (e.g., **Heading**) and unwanted symbols
        botResponse = botResponse.replaceAll(RegExp(r'\*\*(.*?)\*\*'), '');
        botResponse = botResponse.replaceAll(RegExp(r'#\s*(.*?)\n'), '');
        botResponse = botResponse.replaceAll(RegExp(r'[\*\_\-]+'), '');

        ChatMessage m1 = ChatMessage(
          text: botResponse.trim(), // Trim spaces from final output
          user: bot,
          createdAt: DateTime.now(),
        );

        allMessages.insert(0, m1);
      } else {
        print("Error: ${value.body}");
      }
    }).catchError((e) {
      print("Exception: $e");
    });

    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "AI Patient's Report",
          style: GoogleFonts.josefinSans(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: maingreen,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 10),
        child: DashChat(
          typingUsers: typing,
          currentUser: myself,
          onSend: (ChatMessage m) {
            getDietRecommendation(m);
          },
          messages: allMessages,
          messageOptions: MessageOptions(
            currentUserContainerColor: Colors.grey.shade800,
            currentUserTextColor: Colors.white,
            avatarBuilder: yourAvatarBuilder,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            textController: _controller,
            cursorStyle: const CursorStyle(color: Colors.black),
            inputDecoration: InputDecoration(
              hintText: 'Enter a mediacl report...',
              hintStyle: TextStyle(color: Colors.grey[600]),
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
