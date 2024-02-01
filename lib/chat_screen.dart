import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chatbot/message.dart';
import 'dart:convert';
// import 'package:chatbot/classifier.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
 
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
 
class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  bool isTyping = false;
  List<Map<String, dynamic>> conversationHistory = [];

  // List<String> _labels = [];
  // late Classifier _classifier;

  // void loadLabels() async {
  //   try {
  //     // Load labels from the file
  //     String labelsContent = await rootBundle.loadString('assets/labels.txt');
  //     _labels = LineSplitter.split(labelsContent).toList();
  //   } catch (e) {
  //     print('Error loading labels: $e');
  //   }
  // }
  // @override
  //  void initState() {
  //   super.initState();
  //   _classifier = Classifier();
  // }

  void sendMsg() async {
  String text = controller.text;
  String apiKey = "***********************"; //replace with your api key
  controller.clear();
  try {
    if (text.isNotEmpty) {
      setState(() {
        msgs.insert(0, Message(true, text));
        isTyping = true;
      });
      scrollController.animateTo(0.0,
          duration: const Duration(seconds: 1), curve: Curves.easeOut);
      //detect emotion
      // final prediction = _classifier.classify(text);
      // print('Label: $prediction');
      // Make POST request to Hugging Face API
      final response = await http.post(Uri.parse("https://api-inference.huggingface.co/models/Njambi-M/gpt2-finetuned"),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json"
          },
          body: jsonEncode({"inputs": text}));
      
      // Check status code and update message list
      // Add this before checking the status code
      print('Response: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var bresponse = json[0]['generated_text'].split('\n')[1].replaceAll('[a]', '').replaceAll('[q]', '').trim();
        setState(() {
          isTyping = false;
          msgs.insert(
              0,
              Message(
                  false,
                  bresponse.toString().trimLeft().trimRight()));
        });
        scrollController.animateTo(0.0,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to send message, please try again!")));
      }
    }
  } on Exception {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Some error occurred, please try again!")));
  }
}
// void sendMsg() async {
//   String text = controller.text;
//   String apiKey = "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";
//   controller.clear();

//   try {
//     if (text.isNotEmpty) {
//       setState(() {
//         msgs.insert(0, Message(true, text));
//         isTyping = true;
//       });

//       // Concatenate the conversation history with the new message
//       String inputTextWithContext = conversationHistory.map((msg) => msg['text']).join(' ') + '.' + text;

//       // Make POST request to Hugging Face API
//       final response = await http.post(
//         Uri.parse("https://api-inference.huggingface.co/models/Njambi-M/gpt2-finetuned"),
//         headers: {
//           "Authorization": "Bearer $apiKey",
//           "Content-Type": "application/json"
//         },
//         body: jsonEncode({"inputs": inputTextWithContext}),
//       );
//       print('Response: ${response.statusCode}');
//       print('Body: ${response.body}');
//       if (response.statusCode == 200) {
//         var json = jsonDecode(response.body);
//         var bresponse = json[0]['generated_text'].split('\n')[1].replaceAll('[a]', '').replaceAll('[q]', '').trim();

//         setState(() {
//           isTyping = false;
//           msgs.insert(0, Message(false, bresponse.toString().trimLeft().trimRight()));
//         });

//         // Update conversation history with the new messages
//         conversationHistory.add({'role': 'user', 'text': text});
//         conversationHistory.add({'role': 'bot', 'text': bresponse.toString().trimLeft().trimRight()});

//         scrollController.animateTo(0.0,
//             duration: const Duration(seconds: 1), curve: Curves.easeOut);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//             content: Text("Failed to send message, please try again!")));
//       }
//     }
//   } on Exception {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text("Some error occurred, please try again!")));
//   }
// }


  @override
  Widget build(BuildContext context) {

   return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Bot"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: msgs.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isTyping && index == 0
                          ? Column(
                              children: [
                                BubbleNormal(
                                  text: msgs[0].msg,
                                  isSender: true,
                                  color: Colors.blue.shade100,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Typing...")),
                                )
                              ],
                            )
                          : BubbleNormal(
                              text: msgs[index].msg,
                              isSender: msgs[index].isSender,
                              color: msgs[index].isSender
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade200,
                            ));
                }),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          sendMsg();
                        },
                        textInputAction: TextInputAction.send,
                        showCursor: true,
                        decoration: const InputDecoration(
                            border: InputBorder.none, hintText: "Enter text"),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  sendMsg();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              )
            ],
          ),
        ],
      ),
    );
  }
}

