import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for logo fetching
import 'package:projeto_sonhar_mais/core/theme/app_colors.dart';
import '../chat_controller.dart'; // Assuming chat_controller.dart is for profile completion
import '../chat_screen.dart'; // Assuming chat_screen.dart is where the profile completion happens

class OnboardingUserForm extends StatefulWidget {
  final String formularioId;
  final String targetCollectionName;

  const OnboardingUserForm({Key? key, required this.formularioId, required this.targetCollectionName}) : super(key: key);

  @override
  State<OnboardingUserForm> createState() => _OnboardingUserFormState();
}

class _OnboardingUserFormState extends State<OnboardingUserForm> {
  String? _logoUrl;
  bool _fetchingLogo = true;

  @override
  void initState() {
    super.initState();
    _fetchLogoUrl();
  }

  Future<void> _fetchLogoUrl() async {
    setState(() {
      _fetchingLogo = true;
    });
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('configuracoes')
          .doc('logo')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data.containsKey('url') && data['url'] is String) {
          setState(() {
            _logoUrl = data['url'];
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar URL da logo para OnboardingUserForm: $e');
    } finally {
      setState(() {
        _fetchingLogo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the text based on targetCollectionName
    String welcomeText = '';
    String descriptionText1 = '';
    String descriptionText2 = '';
    String buttonText = 'Iniciar Pareamento Agora'; // Default button text

    if (widget.targetCollectionName == 'doadoras') {
      welcomeText = "Bem-vinda à Sonhar+";
      descriptionText1 = "Para nos ajudar a te conhecer melhor, precisamos que nos conte um pouco sobre você.";
      descriptionText2 = "Para um cadastro completo, precisaremos de sua foto, documentos de identificação, e algumas informações sobre sua saúde e a de sua família. Tudo será tratado com a máxima confidencialidade!";
      buttonText = "Iniciar Perfil de Doadora";
    } else { // Default or 'receptora'
      welcomeText = "Bem-vinda à Sonhar Mais!";
      descriptionText1 = "Para encontrarmos o pareamento ideal, precisamos que nos conte um pouco mais sobre você.";
      descriptionText2 = "Para um cadastro completo, precisaremos de sua foto, documentos de identificação, algumas informações sobre suas características físicas e as de seu cônjuge (caso tenha), e fotos suas desde a sua primeira infância até a fase atual. Tudo será tratado com a máxima confidencialidade!";
      buttonText = "Iniciar Pareamento Agora";
    }


    Widget logoDisplayWidget;
    if (_fetchingLogo) {
      logoDisplayWidget = const CircularProgressIndicator(color: Colors.white);
    } else if (_logoUrl != null && _logoUrl!.isNotEmpty) {
      logoDisplayWidget = Image.network(
        _logoUrl!,
        height: 120, // Consistent height with login page
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image,
            color: Colors.white70,
            size: 60,
          );
        },
      );
    } else {
      logoDisplayWidget = const Icon(
        Icons.business,
        color: Colors.white70,
        size: 60,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary, // Primary background color
      body: Center( // Center the whole scrollable content
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to top
            children: [
              // Logo display area
              Container(
                padding: const EdgeInsets.all(20),
                child: logoDisplayWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: 500, // Consistent width with login page
                  decoration: BoxDecoration(
                    color: AppColors.background, // Background color for the form container
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Center column content
                      children: [
                        const SizedBox(height: 20), // Spacing from the top of the card
                        Text( // Use dynamic welcomeText
                          welcomeText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text( // Use dynamic descriptionText1
                          descriptionText1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text( // Use dynamic descriptionText2
                          descriptionText2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          child: Text(buttonText), // Use dynamic buttonText
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                      create: (context) => ChatController(
                                        formularioId: widget.formularioId,
                                        targetCollectionName: widget.targetCollectionName,
                                      ),
                                    ),
                                  ],
                                  child: const ChatScreen(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}