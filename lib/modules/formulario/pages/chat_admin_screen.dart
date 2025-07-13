import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';
import 'package:file_saver/file_saver.dart'; // Import for file_saver
import '../../../core/theme/app_colors.dart';
import 'chat_controller.dart';
import 'chat_screen.dart';
import 'package:excel/excel.dart';
import 'forms/form_model.dart';

enum RespostaTipo {
  texto,
  opcoesImagem,
  radio,
  multiSelecao,
  uploadFoto,
  uploadFotoFase,
  aeroporto,
  assinatura,
  uploadArquivo,
}

class Option {
  final String label;
  final String imageUrl;

  Option(this.label, this.imageUrl);
}

class ChatAdminScreen extends StatefulWidget {
  final Formulario formulario;
  // NEW: Add collectionName to the constructor
  final String collectionName; // This comes from FormulariosScreen

  const ChatAdminScreen({
    super.key,
    required this.formulario,
    required this.collectionName, // Initialize the new field
  });

  @override
  _ChatAdminScreenState createState() => _ChatAdminScreenState();
}

class _ChatAdminScreenState extends State<ChatAdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> perguntas = [];

  @override
  void initState() {
    super.initState();
    _loadPerguntas();
  }

  void _loadPerguntas() async {
    try {
      var snapshot = await _firestore
          .collection('perguntas')
          .where('formularioId', isEqualTo: widget.formulario.id)
          .orderBy('ordem')
          .get();
      setState(() {
        perguntas = snapshot.docs;
      });
    } catch (e) {
      print("Erro ao carregar perguntas: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao carregar perguntas.")),
      );
    }
  }

  void _updateOrder() async {
    try {
      for (int i = 0; i < perguntas.length; i++) {
        await _firestore.collection('perguntas').doc(perguntas[i].id).update(
            {'ordem': i + 1});
      }
      _loadPerguntas();
    } catch (e) {
      print("Erro ao atualizar ordem: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao atualizar ordem.")),
      );
    }
  }

  Future<void> _uploadPlanilha() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      try {
        var file = result.files.first.bytes;
        var excel = Excel.decodeBytes(file!);

        var table = excel.tables.keys.first;
        var sheet = excel.tables[table];

        if (sheet != null) {
          for (int row = 1; row < sheet.maxRows; row++) {
            var rowData = sheet.rows[row];

            if (rowData.length >= 5) { // Agora esperamos 5 colunas
              String texto = rowData[0]?.value?.toString() ?? '';
              String campoFirebase = rowData[1]?.value?.toString() ?? '';
              String tipo = rowData[2]?.value?.toString() ?? 'texto';
              String opcoesString = rowData[3]?.value?.toString() ?? '';
              int ordem = int.tryParse(rowData[4]?.value?.toString() ?? '0') ?? 0; // Nova coluna de ordem

              List<Option> opcoes = [];
              // Only parse options if the type supports them
              if (tipo == 'opcoesImagem' || tipo == 'radio' || tipo == 'multiSelecao' || tipo == 'aeroporto') {
                var opcoesList = opcoesString.split(',');
                for (var opcao in opcoesList) {
                  var parts = opcao.split(':');
                  if (parts.length == 2) {
                    opcoes.add(Option(parts[0].trim(), parts[1].trim()));
                  } else {
                    opcoes.add(Option(opcao.trim(), ''));
                  }
                }
              }

              await _firestore.collection('perguntas').add({
                'texto': texto,
                'campoFirebase': campoFirebase,
                'tipo': tipo,
                'opcoes': opcoes.map((o) => {'label': o.label, 'imageUrl': o.imageUrl}).toList(),
                'ordem': ordem, // Usando a ordem da planilha
                'ativa': true,
                'formularioId': widget.formulario.id,
              });
            }
          }
          _loadPerguntas();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Perguntas importadas com sucesso.")),
          );
        }
      } catch (e) {
        print("Erro ao processar planilha: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao processar planilha.")),
        );
      }
    }
  }

  Future<String?> _selecionarImagemParaOpcao() async {
    try {
      final Uint8List? bytes = await ImagePickerWeb.getImageAsBytes();
      if (bytes == null) return null;

      final ref = FirebaseStorage.instance.ref().child('opcoes/${DateTime
          .now()
          .millisecondsSinceEpoch}.png');
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Erro ao selecionar imagem: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao selecionar imagem.")),
      );
      return null;
    }
  }

  Future<Option?> _adicionarOpcao(RespostaTipo tipo) async {
    TextEditingController labelController = TextEditingController();
    String? imageUrl;

    return await showDialog<Option>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Adicionar Opção"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                        hintText: "Texto da opção"),
                  ),
                  if (tipo == RespostaTipo.opcoesImagem) ...[
                    const SizedBox(height: 10),
                    imageUrl != null
                        ? Image.network(
                        imageUrl!, width: 100, height: 100, fit: BoxFit.cover)
                        : const SizedBox.shrink(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text("Escolher Imagem"),
                      onPressed: () async {
                        final url = await _selecionarImagemParaOpcao();
                        if (url != null) {
                          setState(() {
                            imageUrl = url;
                          });
                        }
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (labelController.text.isNotEmpty) {
                      Navigator.pop(context, Option(labelController.text,
                          imageUrl ?? ''));
                    }
                  },
                  child: const Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _adicionarPergunta() async {
    TextEditingController perguntaController = TextEditingController();
    TextEditingController campoFirebaseController = TextEditingController();
    List<Option> opcoes = [];
    RespostaTipo tipoSelecionado = RespostaTipo.texto;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Nova Pergunta"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: perguntaController,
                    decoration: const InputDecoration(
                        hintText: "Digite a pergunta..."),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: campoFirebaseController,
                    decoration: const InputDecoration(
                        hintText: "Nome do campo no Firebase (ex: nome_completo)"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<RespostaTipo>(
                    value: tipoSelecionado,
                    onChanged: (RespostaTipo? newValue) {
                      setState(() {
                        tipoSelecionado = newValue!;
                        // Clear options if switching to a type that doesn't use them
                        if (newValue != RespostaTipo.opcoesImagem &&
                            newValue != RespostaTipo.radio &&
                            newValue != RespostaTipo.multiSelecao &&
                            newValue != RespostaTipo.aeroporto) {
                          opcoes.clear();
                        }
                      });
                    },
                    items: RespostaTipo.values.map<
                        DropdownMenuItem<RespostaTipo>>((RespostaTipo value) {
                      return DropdownMenuItem<RespostaTipo>(
                        value: value,
                        child: Text(value
                            .toString()
                            .split('.')
                            .last),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  // Conditionally show options input
                  if (tipoSelecionado == RespostaTipo.opcoesImagem ||
                      tipoSelecionado == RespostaTipo.radio ||
                      tipoSelecionado == RespostaTipo.aeroporto ||
                      tipoSelecionado == RespostaTipo.multiSelecao)
                    ...[
                      const Text("Opções:"),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Column(
                            children: opcoes.map((opcao) =>
                                ListTile(
                                  leading: tipoSelecionado ==
                                      RespostaTipo.opcoesImagem ? Image.network(
                                      opcao.imageUrl, width: 40,
                                      height: 40,
                                      fit: BoxFit.cover) : null,
                                  title: Text(opcao.label),
                                  trailing: IconButton(
                                    icon: const Icon(
                                        Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        opcoes.remove(opcao);
                                      });
                                    },
                                  ),
                                )).toList(),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar Opção"),
                        onPressed: () async {
                          final novaOpcao = await _adicionarOpcao(
                              tipoSelecionado);
                          if (novaOpcao != null) {
                            setState(() {
                              opcoes.add(novaOpcao);
                            });
                          }
                        },
                      ),
                    ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (perguntaController.text.isNotEmpty &&
                        campoFirebaseController.text.isNotEmpty) {
                      try {
                        await _firestore.collection('perguntas').add({
                          'texto': perguntaController.text,
                          'campoFirebase': campoFirebaseController.text,
                          'opcoes': opcoes.map((o) =>
                          {
                            'label': o.label,
                            'imageUrl': o.imageUrl
                          }).toList(),
                          'tipo': tipoSelecionado
                              .toString()
                              .split('.')
                              .last,
                          'ordem': perguntas.length,
                          'ativa': true,
                          'formularioId': widget.formulario.id,
                        });
                        _loadPerguntas();
                        Navigator.pop(context);
                      } catch (e) {
                        print("Erro ao adicionar pergunta: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Erro ao adicionar pergunta.")),
                        );
                      }
                    }
                  },
                  child: const Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editarPergunta(DocumentSnapshot doc) {
    TextEditingController perguntaController = TextEditingController(
        text: doc['texto']);
    TextEditingController campoFirebaseController = TextEditingController(
        text: doc['campoFirebase']);
    List<Option> opcoes = (doc['opcoes'] as List).map((opcao) {
      return Option(opcao['label'], opcao['imageUrl']);
    }).toList();
    RespostaTipo tipoSelecionado = RespostaTipo.values.firstWhere((e) =>
    e
        .toString()
        .split('.')
        .last == doc['tipo']);
    bool ativa = doc['ativa'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Editar Pergunta"),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: const Text("Confirmar Exclusão"),
                                  content: const Text(
                                      "Deseja realmente excluir esta pergunta?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancelar"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await _firestore.collection(
                                              'perguntas').doc(doc.id).delete();
                                          _loadPerguntas();
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        } catch (e) {
                                          print("Erro ao excluir pergunta: $e");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(content: Text(
                                                "Erro ao excluir pergunta.")),
                                          );
                                        }
                                      },
                                      child: const Text("Excluir"),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                      const SizedBox(width: 5),
                      Switch(
                        value: ativa,
                        onChanged: (bool newValue) {
                          setState(() {
                            ativa = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: perguntaController,
                    decoration: const InputDecoration(
                        hintText: "Digite a pergunta..."),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: campoFirebaseController,
                    decoration: const InputDecoration(
                        hintText: "Nome do campo no Firebase (ex: nome_completo)"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<RespostaTipo>(
                    value: tipoSelecionado,
                    onChanged: (RespostaTipo? newValue) {
                      setState(() {
                        tipoSelecionado = newValue!;
                        // Clear options if switching to a type that doesn't use them
                        if (newValue != RespostaTipo.opcoesImagem &&
                            newValue != RespostaTipo.radio &&
                            newValue != RespostaTipo.multiSelecao &&
                            newValue != RespostaTipo.aeroporto) {
                          opcoes.clear();
                        }
                      });
                    },
                    items: RespostaTipo.values.map<
                        DropdownMenuItem<RespostaTipo>>((RespostaTipo value) {
                      return DropdownMenuItem<RespostaTipo>(
                        value: value,
                        child: Text(value
                            .toString()
                            .split('.')
                            .last),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  // Conditionally show options input
                  if (tipoSelecionado == RespostaTipo.opcoesImagem ||
                      tipoSelecionado == RespostaTipo.radio ||
                      tipoSelecionado == RespostaTipo.multiSelecao ||
                      tipoSelecionado == RespostaTipo.aeroporto)
                    ...[
                      const Text("Opções:"),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Column(
                            children: opcoes.map((opcao) =>
                                ListTile(
                                  leading: tipoSelecionado ==
                                      RespostaTipo.opcoesImagem ? Image.network(
                                      opcao.imageUrl, width: 40,
                                      height: 40,
                                      fit: BoxFit.cover) : null,
                                  title: Text(opcao.label),
                                  trailing: IconButton(
                                    icon: const Icon(
                                        Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        opcoes.remove(opcao);
                                      });
                                    },
                                  ),
                                )).toList(),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Adicionar Opção"),
                        onPressed: () async {
                          final novaOpcao = await _adicionarOpcao(
                              tipoSelecionado);
                          if (novaOpcao != null) {
                            setState(() {
                              opcoes.add(novaOpcao);
                            });
                          }
                        },
                      ),
                    ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (perguntaController.text.isNotEmpty &&
                        campoFirebaseController.text.isNotEmpty) {
                      try {
                        await _firestore.collection('perguntas')
                            .doc(doc.id)
                            .update({
                          'texto': perguntaController.text,
                          'campoFirebase': campoFirebaseController.text,
                          'opcoes': opcoes.map((o) =>
                          {
                            'label': o.label,
                            'imageUrl': o.imageUrl
                          }).toList(),
                          'tipo': tipoSelecionado
                              .toString()
                              .split('.')
                              .last,
                          'ativa': ativa,
                          'formularioId': widget.formulario.id,
                        });
                        _loadPerguntas();
                        Navigator.pop(context);
                      } catch (e) {
                        print("Erro ao editar pergunta: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Erro ao editar pergunta.")),
                        );
                      }
                    }
                  },
                  child: const Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- NEW: Method to copy questions from another form ---
  Future<void> _copyPerguntas() async {
    try {
      // 1. Fetch all available forms (excluding the current one)
      final formsSnapshot = await _firestore.collection('formularios')
          .where(FieldPath.documentId, isNotEqualTo: widget.formulario.id)
          .get();

      if (formsSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nenhum outro formulário encontrado para copiar perguntas.")),
        );
        return;
      }

      // 2. Show a dialog to let the user select a form
      final selectedForm = await showDialog<DocumentSnapshot>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Copiar Perguntas De:"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: formsSnapshot.docs.length,
                itemBuilder: (context, index) {
                  final formDoc = formsSnapshot.docs[index];
                  final formName = formDoc['nome'] ?? 'Formulário Sem Nome';
                  return ListTile(
                    title: Text(formName),
                    onTap: () => Navigator.pop(context, formDoc),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
            ],
          );
        },
      );

      if (selectedForm == null) {
        return; // User cancelled selection
      }

      // 3. Fetch questions from the selected form
      final questionsToCopySnapshot = await _firestore.collection('perguntas')
          .where('formularioId', isEqualTo: selectedForm.id)
          .orderBy('ordem')
          .get();

      if (questionsToCopySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("O formulário '${selectedForm['nome']}' não possui perguntas para copiar.")),
        );
        return;
      }

      // 4. Copy each question to the current form
      for (var questionDoc in questionsToCopySnapshot.docs) {
        final data = questionDoc.data() as Map<String, dynamic>;
        // Create a new map to modify and then add to Firestore
        final newQuestionData = Map<String, dynamic>.from(data);

        // Update the formularioId to the current form's ID
        newQuestionData['formularioId'] = widget.formulario.id;

        // Ensure 'ordem' is set correctly for the new questions in the current form
        // You might want to adjust this logic if you have a specific ordering strategy
        newQuestionData['ordem'] = perguntas.length + 1; // Append to the end

        await _firestore.collection('perguntas').add(newQuestionData);
      }

      _loadPerguntas(); // Reload questions to show the newly copied ones
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Perguntas copiadas com sucesso!")),
      );
    } catch (e) {
      print("Erro ao copiar perguntas: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao copiar perguntas.")),
      );
    }
  }

  // --- NEW: Method to download questions as an Excel file ---
  Future<void> _downloadPlanilha() async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Perguntas'];

      // Adiciona linha de cabeçalho
      sheetObject.appendRow([
        // Corrected: Use TextCellValue for string headers
        TextCellValue('Texto'),
        TextCellValue('Campo Firebase'),
        TextCellValue('Tipo'),
        TextCellValue('Opções'),
        TextCellValue('Ordem'),
      ]);

      // Adiciona linhas com os dados
      for (var pergunta in perguntas) {
        String texto = pergunta['texto'] ?? '';
        String campoFirebase = pergunta['campoFirebase'] ?? '';
        String tipo = pergunta['tipo'] ?? '';
        List<dynamic> rawOptions = pergunta['opcoes'] ?? [];

        String opcoesString = rawOptions.map((o) {
          String label = o['label'] ?? '';
          String imageUrl = o['imageUrl'] ?? '';
          return imageUrl.isNotEmpty ? '$label:$imageUrl' : label;
        }).join(',');

        int ordem = pergunta['ordem'] ?? 0;

        // Adiciona a linha com os dados, using specific CellValue subtypes
        sheetObject.appendRow([
          TextCellValue(texto),
          TextCellValue(campoFirebase),
          TextCellValue(tipo),
          TextCellValue(opcoesString),
          IntCellValue(ordem), // Corrected: Use IntCellValue for int
        ]);
      }

      final fileBytes = excel.encode();
      if (fileBytes != null) {
        await FileSaver.instance.saveFile(
          name: "perguntas_${widget.formulario.nome}.xlsx",
          bytes: Uint8List.fromList(fileBytes),
          ext: "xlsx",
          mimeType: MimeType.microsoftExcel,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Planilha baixada com sucesso.")),
          );
        }
      }
    } catch (e) {
      print("Erro ao baixar planilha: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao baixar planilha.")),
        );
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) =>
            ChatController(
              formularioId: widget.formulario.id,
              // NEW: Pass the collectionName here
              targetCollectionName: widget.collectionName,
            )),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.primary),
          title: Text(
            "Gerenciar Perguntas - ${widget.formulario.nome}", // Changed title for clarity
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (context) =>
                              ChatController(
                                formularioId: widget.formulario.id,
                                // NEW: Pass the collectionName here again
                                targetCollectionName: widget.collectionName,
                              )),
                        ],
                        child: const ChatScreen(),
                      )),
                );
              },
              icon: const Icon(Icons.chat),
            ),
          ],
        ),
        body: perguntas.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ReorderableListView(
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = perguntas.removeAt(oldIndex);
                perguntas.insert(newIndex, item);
              });
              _updateOrder();
            },
            children: [
              for (var pergunta in perguntas)
                Card(
                  key: ValueKey(pergunta.id),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: ListTile(
                      title: Text(pergunta['texto']),
                      subtitle: Text('Tipo: ${pergunta['tipo']} | Ativa: ${pergunta['ativa']}'),
                      onTap: () => _editarPergunta(pergunta),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'addQuestion',
              onPressed: _adicionarPergunta,
              tooltip: 'Adicionar Nova Pergunta',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'uploadExcel',
              onPressed: _uploadPlanilha,
              tooltip: 'Importar Perguntas de Planilha',
              child: const Icon(Icons.upload_file),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'copyQuestions',
              onPressed: _copyPerguntas,
              tooltip: 'Copiar Perguntas de Outro Formulário',
              child: const Icon(Icons.copy),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'downloadExcel',
              onPressed: _downloadPlanilha,
              tooltip: 'Baixar Perguntas para Planilha',
              child: const Icon(Icons.download),
            ),
          ],
        ),
      ),
    );
  }
}