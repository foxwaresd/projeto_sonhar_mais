import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto_sonhar_mais/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart'; // Import go_router for navigation

class ConclusionUserForm extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  // NEW: Add targetCollectionName to ConclusionUserForm
  final String targetCollectionName;

  const ConclusionUserForm({
    Key? key,
    required this.scaffoldKey,
    required this.targetCollectionName, // Initialize the new field
  }) : super(key: key);

  @override
  State<ConclusionUserForm> createState() => _ConclusionUserFormState();
}

class _ConclusionUserFormState extends State<ConclusionUserForm> {

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
      debugPrint('Erro ao buscar URL da logo para ConclusionUserForm: $e');
    } finally {
      setState(() {
        _fetchingLogo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the text based on targetCollectionName
    String conclusionTitle = '';
    String conclusionText1 = '';
    String conclusionText2 = '';

    if (widget.targetCollectionName == 'doadoras') {
      conclusionTitle = "Parabéns, Doadora!";
      conclusionText1 = "Seu perfil de doadora está completo! Agradecemos por compartilhar suas informações e por contribuir com a Sonhar+.";
      conclusionText2 = "Sua participação é fundamental para ajudarmos outras pessoas a realizarem seus sonhos. Aguarde o contato da nossa equipe.";
    } else { // Default or 'receptora'
      conclusionTitle = "Parabéns!";
      conclusionText1 = "Seu perfil de receptora está completo! Agora temos as informações necessárias para encontrar o pareamento ideal que atenda às suas expectativas.";
      conclusionText2 = "Aguarde o contato da nossa equipe. Estamos prontos para dar o próximo passo em sua jornada na Sonhar Mais.";
    }

    Widget logoDisplayWidget;
    if (_fetchingLogo) {
      logoDisplayWidget = const CircularProgressIndicator(color: Colors.white);
    } else if (_logoUrl != null && _logoUrl!.isNotEmpty) {
      logoDisplayWidget = Image.network(
        _logoUrl!,
        height: 120,
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
      backgroundColor: AppColors.primary, // Apply primary background color
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20), // Spacing from top of card
                        Text( // Use dynamic conclusionTitle
                          conclusionTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 20), // Adjusted spacing
                        Text( // Use dynamic conclusionText1
                          conclusionText1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text( // Use dynamic conclusionText2
                          conclusionText2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),
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