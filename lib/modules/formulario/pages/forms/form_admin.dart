import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../chat_admin_screen.dart'; // Assumindo que este é o caminho correto para ChatAdminScreen
import 'package:uuid/uuid.dart';
import 'form_model.dart'; // ESTE IMPORT É CRUCIAL E DEVE APONTAR PARA O ÚNICO LOCAL DA CLASSE FORMULARIO

class FormulariosScreen extends StatefulWidget {
  const FormulariosScreen({super.key});

  @override
  _FormulariosScreenState createState() => _FormulariosScreenState();
}

class _FormulariosScreenState extends State<FormulariosScreen> {
  List<String> emailsPermitidos = [];
  List<String> emailsSelecionados = [];
  List<Formulario> formularios = [];
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _collectionNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarFormularios();
    _carregarEmailsPermitidos();
  }

  void _carregarEmailsPermitidos() async {
    try {
      final snapshot = await _firestore.collection('emailsPermitidos').get();
      setState(() {
        emailsPermitidos = snapshot.docs
            .map((doc) => doc['email'].toString())
            .where((email) => email != 'null')
            .toList();
      });
    } catch (e) {
      print("Erro ao carregar emails permitidos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao carregar emails permitidos.")),
      );
    }
  }

  void _carregarFormularios() async {
    try {
      final snapshot = await _firestore.collection('formularios').get();
      setState(() {
        formularios = snapshot.docs.map((doc) => Formulario(
          id: doc.id,
          nome: doc['nome'],
          emails: List<String>.from(doc['emails'] ?? []),
          collectionName: doc['collectionName'] as String,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao carregar formulários: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao carregar formulários.")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _criarFormulario({Formulario? formularioParaEditar}) async {
    if (formularioParaEditar != null) {
      _nomeController.text = formularioParaEditar.nome;
      _collectionNameController.text = formularioParaEditar.collectionName;
      emailsSelecionados = List.from(formularioParaEditar.emails);
    } else {
      _nomeController.clear();
      _collectionNameController.clear();
      emailsSelecionados.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(formularioParaEditar == null ? 'Novo Formulário' : 'Editar Formulário'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome do Formulário'),
                  ),
                  TextField(
                    controller: _collectionNameController,
                    decoration: const InputDecoration(labelText: 'Nome da Coleção para Salvar Dados'),
                  ),
                  if (emailsPermitidos.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  emailsSelecionados = List.from(emailsPermitidos);
                                });
                              },
                              child: const Text('Selecionar Todos'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  emailsSelecionados.clear();
                                });
                              },
                              child: const Text('Desmarcar Todos'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 300,
                          width: 300,
                          child: ListView.builder(
                            itemCount: emailsPermitidos.length,
                            itemBuilder: (context, index) {
                              final email = emailsPermitidos[index];
                              return CheckboxListTile(
                                title: Text(email),
                                value: emailsSelecionados.contains(email),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      emailsSelecionados.add(email);
                                    } else {
                                      emailsSelecionados.remove(email);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nome = _nomeController.text;
                    final collectionName = _collectionNameController.text;
                    if (nome.isNotEmpty && collectionName.isNotEmpty) {
                      final formulario = formularioParaEditar != null
                          ? formularioParaEditar.copyWith(
                        nome: nome,
                        emails: emailsSelecionados,
                        collectionName: collectionName,
                      )
                          : Formulario(
                        id: const Uuid().v4(),
                        nome: nome,
                        emails: emailsSelecionados,
                        collectionName: collectionName,
                      );

                      try {
                        await _firestore.collection('formularios').doc(formulario.id).set({
                          'nome': formulario.nome,
                          'emails': formulario.emails,
                          'collectionName': formulario.collectionName,
                        });
                        _carregarFormularios();
                        Navigator.pop(context);
                      } catch (e) {
                        print("Erro ao salvar/editar formulario: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Erro ao salvar/editar formulario.")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Por favor, preencha o nome do formulário e o nome da coleção.")),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Formulário de Cadastro",)
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: formularios.length,
        itemBuilder: (context, index) {
          final formulario = formularios[index];
          return Card(
            child: ListTile(
              title: Text(formulario.nome),
              subtitle: Text('Coleção para dados: ${formulario.collectionName}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _criarFormulario(formularioParaEditar: formulario),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatAdminScreen(
                      formulario: formulario,
                      collectionName: formulario.collectionName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _criarFormulario,
        child: const Icon(Icons.add),
      ),
    );
  }
}