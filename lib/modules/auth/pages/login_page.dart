import 'package:flutter/material.dart';
import 'package:projeto_sonhar_mais/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../provider/auth_provider.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _logoUrl;
  bool _fetchingLogo = true;

  bool _obscureText = true;

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
      debugPrint('Erro ao buscar URL da logo para LoginPage: $e');
    } finally {
      setState(() {
        _fetchingLogo = false;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
      backgroundColor: AppColors.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: logoDisplayWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 400,
                  width: 500,
                  decoration: BoxDecoration(
                    color: AppColors.background,
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
                        const Text(
                          "Login",
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.primary,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: () async {
                            try {
                              await authProvider.login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro de login: ${e.toString()}'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Entrar', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Esqueci a senha',
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