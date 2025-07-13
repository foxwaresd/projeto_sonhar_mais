import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:go_router/go_router.dart'; // Import go_router for navigation back

import '../../../core/theme/app_colors.dart'; // Ensure this path is correct
import '../provider/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _logoUrl; // To store the fetched logo URL
  bool _fetchingLogo = true; // To manage the loading state for the logo

  @override
  void initState() {
    super.initState();
    _fetchLogoUrl(); // Fetch the logo when the page initializes
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
      debugPrint('Erro ao buscar URL da logo para ForgotPasswordPage: $e');
      // Optionally set an error message to display
    } finally {
      setState(() {
        _fetchingLogo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Widget to display the logo or a placeholder
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
        Icons.business, // Default placeholder if no logo is found
        color: Colors.white70,
        size: 60,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary, // Primary background color
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align to top (or center based on overall preference)
            children: [
              // Logo display area
              Container(
                padding: const EdgeInsets.all(20),
                child: logoDisplayWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 350, // Slightly adjusted height for content
                  width: 500,
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
                        const Text(
                          "Recuperar Senha",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Informe seu e-mail para receber um link de recuperação de senha.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: () async {
                            try {
                              await authProvider.resetPassword(
                                  _emailController.text.trim());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Email de recuperação enviado! Verifique sua caixa de entrada.'),
                                ),
                              );
                              // You might want to navigate back to login after sending email
                              context.go('/login'); // Using go_router to go back
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Erro ao enviar email: ${e.toString()}')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary, // Button color
                            foregroundColor: Colors.white, // Text color
                            minimumSize: const Size(double.infinity, 50), // Full width button
                          ),
                          child: const Text('Enviar Link',
                              style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Voltar para o Login',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
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