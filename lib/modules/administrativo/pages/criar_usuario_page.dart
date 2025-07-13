import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CriarUsuarioPage extends StatefulWidget {
  const CriarUsuarioPage({super.key});

  @override
  State<CriarUsuarioPage> createState() => _CriarUsuarioPageState();
}

class _CriarUsuarioPageState extends State<CriarUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _updatePasswordController = TextEditingController(); // Controller para nova senha
  final _auth = FirebaseAuth.instance;
  final _functions = FirebaseFunctions.instance; // Instância para Cloud Functions

  bool _loading = false;
  String? _errorMessage;
  List<UserRecordData> _users = []; // Lista para armazenar os usuários
  UserRecordData? _selectedUser; // Usuário selecionado para edição

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Carrega os usuários ao iniciar a tela
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _updatePasswordController.dispose();
    super.dispose();
  }

  // --- Funções de Gerenciamento de Usuários (via Cloud Functions quando necessário) ---

  // Criar Usuário (ainda usa o SDK local, pois é permitido)
  void _criarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário criado com sucesso: ${userCredential.user?.email}')),
      );

      _emailController.clear();
      _senhaController.clear();
      _fetchUsers(); // Atualiza a lista após criar
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'A senha é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'Esse email já está em uso.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'Email inválido.';
      } else {
        _errorMessage = 'Erro ao criar usuário: ${e.message}';
      }
      setState(() {});
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado ao criar usuário: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Listar Usuários (chamando Cloud Function 'listUsers')
  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final HttpsCallable callable = _functions.httpsCallable('listUsers');
      final result = await callable.call(); // Chama a função do Firebase
      final List<dynamic> usersData = result.data['users']; // Obtém a lista de usuários do resultado
      setState(() {
        _users = usersData.map((data) => UserRecordData.fromJson(data)).toList();
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _errorMessage = 'Erro ao listar usuários: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado ao listar usuários: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Alterar Senha de um Usuário Específico (chamando Cloud Function 'updateUserPassword')
  Future<void> _updatePassword(String uid, String newPassword) async {
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A nova senha deve ter ao menos 6 caracteres.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final HttpsCallable callable = _functions.httpsCallable('updateUserPassword');
      await callable.call({'uid': uid, 'newPassword': newPassword}); // Envia UID e nova senha

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha do usuário $uid atualizada com sucesso!')),
      );
      _updatePasswordController.clear();
      setState(() {
        _selectedUser = null; // Limpa a seleção após a atualização
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _errorMessage = 'Erro ao alterar senha: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado ao alterar senha: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Excluir Usuário (chamando Cloud Function 'deleteUser')
  Future<void> _deleteUser(String uid) async {
    // Confirmação antes de excluir
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir o usuário ?'), // Exibe email se disponível
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final HttpsCallable callable = _functions.httpsCallable('deleteUser');
      await callable.call({'uid': uid}); // Envia o UID do usuário a ser excluído

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuário $uid excluído com sucesso!')),
      );
      _fetchUsers(); // Atualiza a lista após excluir
      setState(() {
        _selectedUser = null; // Limpa a seleção após a exclusão
      });
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _errorMessage = 'Erro ao excluir usuário: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado ao excluir usuário: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Criar Novo Usuário', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || !v.contains('@') || v.isEmpty) ? 'Email inválido' : null,
                ),
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6) ? 'Senha deve ter ao menos 6 caracteres' : null,
                ),
                const SizedBox(height: 16),
                _loading && _selectedUser == null // Mostra o loader apenas para criação
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _criarUsuario,
                  child: const Text('Criar Usuário'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text('Gerenciar Usuários Existentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _loading && _selectedUser == null // Mostra o loader para a lista ou para atualização de senha
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
              ? const Center(child: Text('Nenhum usuário encontrado.'))
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user.email ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('UID: ${user.uid}'),
                        Text('Criado em: ${DateTime.parse(user.creationTime!).toLocal().toString().split('.')[0]}'),
                      if (user.lastSignInTime != null)
                        Text('Último Login: ${DateTime.parse(user.lastSignInTime!).toLocal().toString().split('.')[0]}'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedUser = user;
                                _updatePasswordController.clear(); // Limpa o campo ao selecionar
                              });
                            },
                            child: const Text('Alterar Senha'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _deleteUser(user.uid),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                      if (_selectedUser?.uid == user.uid) // Exibe campos de alteração de senha se selecionado
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _updatePasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'Nova Senha',
                                  hintText: 'Mínimo 6 caracteres',
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _loading && _selectedUser?.uid == user.uid
                                    ? null // Desabilita o botão enquanto este usuário está carregando
                                    : () => _updatePassword(user.uid, _updatePasswordController.text),
                                child: _loading && _selectedUser?.uid == user.uid
                                    ? const CircularProgressIndicator.adaptive()
                                    : const Text('Confirmar Nova Senha'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedUser = null; // Cancela a alteração
                                    _updatePasswordController.clear();
                                  });
                                },
                                child: const Text('Cancelar'),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Classe auxiliar para mapear dados do usuário retornados pela Cloud Function
// Os campos são todos opcionais caso a Cloud Function não os retorne.
class UserRecordData {
  final String uid;
  final String? email;
  final String? creationTime;
  final String? lastSignInTime;

  UserRecordData({
    required this.uid,
    this.email,
    this.creationTime,
    this.lastSignInTime,
  });

  factory UserRecordData.fromJson(Map<String, dynamic> json) {
    return UserRecordData(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      creationTime: json['creationTime'] as String?, // Firebase Functions retorna como string
      lastSignInTime: json['lastSignInTime'] as String?, // Firebase Functions retorna como string
    );
  }
}