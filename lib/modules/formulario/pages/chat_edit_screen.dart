import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/theme/app_colors.dart';

class EditFormResponsePage extends StatefulWidget {
  final String formularioId;

  const EditFormResponsePage({Key? key, required this.formularioId}) : super(key: key);

  @override
  _EditFormResponsePageState createState() => _EditFormResponsePageState();
}

class _EditFormResponsePageState extends State<EditFormResponsePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic> existingResponses = {};
  List<Map<String, dynamic>> perguntas = [];
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, List<String>> _selectedOptions = {};
  final Map<String, String> _selectedImages = {};
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      _userId = _auth.currentUser?.uid;
      if (_userId == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não autenticado.')));
        return;
      }

      final perguntasSnapshot = await _firestore
          .collection('perguntas')
          .where('ativa', isEqualTo: true)
          .where('formularioId', isEqualTo: widget.formularioId)
          .orderBy('ordem')
          .get();

      perguntas = perguntasSnapshot.docs.map((doc) => {
        'id': doc.id,
        'texto': doc['texto'],
        'campoFirebase': doc['campoFirebase'],
        'tipo': doc['tipo'],
        'opcoes': (doc['opcoes'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      }).toList();

      final userResponseSnapshot = await _firestore.collection('meuuserform').doc(_userId).get();

      if (userResponseSnapshot.exists && userResponseSnapshot.data() != null) {
        existingResponses = userResponseSnapshot.data() as Map<String, dynamic>;
      }

      for (var pergunta in perguntas) {
        final campo = pergunta['campoFirebase'];
        final resposta = existingResponses[campo];

        if (resposta != null) {
          if (pergunta['tipo'] == 'multiSelecao') {
            _selectedOptions[campo] = (resposta as String).split(', ');
          } else if (pergunta['tipo'] == 'uploadFoto') {
            _selectedImages[campo] = resposta as String? ?? '';
          } else {
            _controllers[campo] = TextEditingController(text: resposta);
          }
        } else {
          _controllers[campo] = TextEditingController();
          _selectedOptions[campo] = [];
          if (pergunta['tipo'] == 'uploadFoto') {
            _selectedImages[campo] = '';
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print("Erro ao carregar dados: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selecionarImagem(String campo) async {
    final mediaInfo = await ImagePickerWeb.getImageInfo;
    if (mediaInfo != null && mediaInfo.data != null) {
      final Uint8List bytes = mediaInfo.data!;
      final String fileName = mediaInfo.fileName ?? 'imagem.jpg';

      final ref = FirebaseStorage.instance.ref().child('uploads/$_userId/$fileName');
      final uploadTask = await ref.putData(bytes);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _selectedImages[campo] = imageUrl;
      });
    }
  }

  Future<void> _saveEditedResponses() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar: Usuário não identificado.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedResponses = <String, dynamic>{};

      for (var pergunta in perguntas) {
        final campo = pergunta['campoFirebase'];
        if (pergunta['tipo'] == 'multiSelecao') {
          updatedResponses[campo] = _selectedOptions[campo]?.join(', ');
        } else if (pergunta['tipo'] == 'uploadFoto') {
          updatedResponses[campo] = _selectedImages[campo];
        } else {
          updatedResponses[campo] = _controllers[campo]?.text;
        }
      }

      await _firestore.collection('meuuserform').doc(_userId).update(updatedResponses);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Respostas atualizadas com sucesso!')));
      Navigator.pop(context);
    } catch (e) {
      print("Erro ao salvar edições: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao atualizar as respostas.')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildFormFields() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: perguntas.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final pergunta = perguntas[index];
        final campo = pergunta['campoFirebase'];
        final texto = pergunta['texto'];
        final tipo = pergunta['tipo'];
        final opcoes = pergunta['opcoes'] as List<Map<String, dynamic>>;

        if (tipo == 'texto' || tipo == 'email' || tipo == 'numero') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _controllers[campo],
              decoration: InputDecoration(labelText: texto),
              keyboardType: tipo == 'email'
                  ? TextInputType.emailAddress
                  : tipo == 'numero'
                  ? TextInputType.number
                  : TextInputType.text,
            ),
          );
        } else if (tipo == 'radio' || tipo == 'opcoesImagem') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
                ...opcoes.map((opcao) {
                  final opcaoTexto = opcao['texto'] as String;
                  return RadioListTile<String>(
                    title: Text(opcaoTexto),
                    value: opcaoTexto,
                    groupValue: _controllers[campo]?.text,
                    onChanged: (value) {
                      setState(() => _controllers[campo]?.text = value!);
                    },
                  );
                }),
              ],
            ),
          );
        } else if (tipo == 'multiSelecao') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
                ...opcoes.map((opcao) {
                  final opcaoTexto = opcao['texto'] as String;
                  return CheckboxListTile(
                    title: Text(opcaoTexto),
                    value: _selectedOptions[campo]?.contains(opcaoTexto) ?? false,
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _selectedOptions[campo]?.add(opcaoTexto);
                        } else {
                          _selectedOptions[campo]?.remove(opcaoTexto);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          );
        } else if (tipo == 'uploadFoto') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selecionarImagem(campo),
                  child: _selectedImages[campo] != null && _selectedImages[campo]!.isNotEmpty
                      ? Image.network(_selectedImages[campo]!, height: 150)
                      : Container(
                    height: 150,
                    width: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.add_a_photo, size: 50),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Editar Respostas',
          style: TextStyle(color: AppColors.primary),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.primary),),
      body: _buildFormFields(),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveEditedResponses,
        child: const Icon(Icons.save),
      ),
    );
  }
}
