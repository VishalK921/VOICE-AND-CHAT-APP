import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_app/openai_service.dart';
import 'package:voice_app/pallets.dart';
import 'package:voice_app/feature_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  @override
  void initState() {
    super.initState();
    initSpeechToText();
    // initTextToSpeech();
  }

  // Future<void> initTextToSpeech() async{
  //   await flutterTts.setSharedInstance(true);
  //   setState(() {

  //   });
  // }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title:const Text('AI'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/images/virtualAssistant.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: generatedImageUrl==null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20)
                      .copyWith(top: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent==null?"Good Morning, How are you feeling today?":generatedContent!,
                      style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize:generatedContent==null? 25:18,
                        fontFamily: 'Cera Pro',
                      ),
                    ),
                  ),
                ),
              ),
              if(generatedImageUrl!=null)Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  child: Image.network(generatedImageUrl!),
                borderRadius: BorderRadius.circular(20),
                ),
              ),
              Visibility(
                visible: generatedContent==null && generatedImageUrl==null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(
                    top: 20,
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Here are some suggestions for you",
                    style: TextStyle(
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontFamily: 'Cera Pro',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
               Visibility(
                visible: generatedContent==null && generatedImageUrl==null,
                 child: Column(
                  children: [
                    FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: "Chat GPT",
                      descriptionText: "Chat with a GPT-3 powered chatbot",
                    ),
                    FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: "Dall-E",
                      descriptionText: "get inspired by Dall-E's creations",
                    ),
                    FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: "Smart Voice Assistant",
                      descriptionText: "get the best voice assistant experience",
                    ),
                  ],
                             ),
               ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if(speech.contains('https')){
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {
                });
              }
              else{
                generatedContent = speech;
                generatedImageUrl = null;
                setState(() {
                  
                });
                await systemSpeak(speech);
              }
              
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child:Icon(
            speechToText.isListening
                ? Icons.stop
                : Icons.mic,
          ),
          backgroundColor: Pallete.firstSuggestionBoxColor,
        ));
  }
}
