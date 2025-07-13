import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import 'chat_controller.dart';
import 'forms/userform_conclusion.dart';
import 'widgets/form_camera.dart';
import 'widgets/chatMessageBubble.dart';
import 'package:signature/signature.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isUploading = false;
  List<Map<String, dynamic>> _filteredOptions = [];
  String _searchQuery = '';

  // Controller for the signature pad
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isSignatureEmpty = true;

  final List<String> _skippablePhotoTypes = const [
    'fotoPrimeiraInfancia',
    'fotoInfanciaIntermediaria',
    'fotoAdolescenciaInicial',
    'fotoAdolescenciaMedia',
    'fotoAdolescenciaFinal',
    'fotoAdultoInicial',
    'fotoAdultoIntermediario',
    'fotoAdulto',
  ];

  final List<String> _questionsToSkipIfNoSpouse = const [
    'peso2',
    'altura2',
    'tipoSanguineo2',
    'etnia2',
    'fitzpatrick2',
    'corOlhos2',
    'corCabelo2',
    'tipoCabelo2',
    'caracteristicas2',
  ];

  @override
  void initState() {
    super.initState();
    _signatureController.addListener(_updateSignatureStatus);
    _isSignatureEmpty = _signatureController.isEmpty;
  }

  void _updateSignatureStatus() {
    setState(() {
      _isSignatureEmpty = _signatureController.isEmpty;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatController = Provider.of<ChatController>(context, listen: false);

    Map<String, dynamic>? pergunta;
    if (chatController.perguntas.isNotEmpty && chatController.step < chatController.perguntas.length) {
      pergunta = chatController.perguntas[chatController.step];
    }

    if (pergunta != null && pergunta['tipo'] == 'aeroporto') {
      _filteredOptions = List.from(pergunta['opcoes']);
    } else {
      _filteredOptions.clear();
      _searchQuery = '';
    }
  }

  @override
  void dispose() {
    _signatureController.removeListener(_updateSignatureStatus);
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final pergunta =
    chatController.perguntas.isNotEmpty && chatController.step < chatController.perguntas.length
        ? chatController.perguntas[chatController.step]
        : null;


    if (chatController.perguntas.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final bool isSkippablePhotoType =
        pergunta != null && _skippablePhotoTypes.contains(pergunta['tipo']);

    final bool possuiConjugeAnsweredNo = chatController.responses['possuiConjuge'] == 'Não';

    final bool shouldSkipQuestion =
        possuiConjugeAnsweredNo &&
            pergunta != null &&
            _questionsToSkipIfNoSpouse.contains(pergunta['campoFirebase']);

    if (shouldSkipQuestion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pergunta != null && pergunta['campoFirebase'] != null) {
          chatController.responses[pergunta['campoFirebase']] = "Não se aplica";
        }
        chatController.nextQuestion();
      });
      return Container();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: const Text("Formulário de Cadastro",
            style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                controller: chatController.scrollController,
                itemCount: chatController.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatController.messages[index];
                  Map<String, dynamic>? associatedQuestion;
                  if (msg.isUser &&
                      msg.questionIndex != null &&
                      msg.questionIndex! < chatController.perguntas.length) {
                    associatedQuestion = chatController.perguntas[msg.questionIndex!];
                  }
                  return ChatMessageBubble(
                    message: msg,
                    chatController: chatController,
                    associatedQuestion: associatedQuestion,
                  );
                },
              ),
            ),
            if (chatController.showInput)
              Column(
                children: [
                  if (pergunta != null && pergunta['tipo'] == 'uploadFotoFase')
                    Column(
                      children: [
                        if (chatController.selectedImage2 != null && chatController.selectedImage2!.isNotEmpty)
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: Image.memory(
                              chatController.selectedImage2!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                chatController.getImage2();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Text('Selecionar Foto'),
                            ),
                            const SizedBox(width: 10),
                            if (chatController.selectedImage2 == null || chatController.selectedImage2!.isEmpty)
                              const Expanded(
                                child: Text(
                                  'Nenhuma foto selecionada',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: (chatController.selectedImage2 != null && chatController.selectedImage2!.isNotEmpty && !_isUploading)
                                      ? () async {
                                    setState(() {
                                      _isUploading = true;
                                    });
                                    await chatController.sendImage(
                                      chatController.selectedImage2!,
                                      pergunta['id'],
                                      'fotos_fase',
                                    );
                                    chatController.clearSelectedImage2();
                                    setState(() {
                                      _isUploading = false;
                                    });
                                  }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: _isUploading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : const Text("Enviar Foto"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (pergunta['campoFirebase'] != null) {
                                      chatController.responses[pergunta['campoFirebase']] = "não possuo a foto";
                                    }
                                    chatController.sendMessage("Não possuo a foto.");
                                    chatController.clearSelectedImage2();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(0, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: const Text("Não possuo a foto"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  if (pergunta != null && pergunta['tipo'] == 'multiSelecao')
                    Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: Column(
                              children: chatController.opcoes.map<Widget>((opcao) {
                                return CheckboxListTile(
                                  title: Text(opcao['label']),
                                  value: chatController.selectedOptions.contains(opcao['label']),
                                  onChanged: (value) {
                                    chatController.selectOption(opcao['label'], pergunta['tipo']);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: chatController.sendSelectedOptions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Text("Enviar Seleção"),
                        ),
                      ],
                    ),
                  if (pergunta != null && pergunta['tipo'] == 'radio')
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: chatController.opcoes.map<Widget>((opcao) {
                            return RadioListTile<String>(
                              title: Text(opcao['label']),
                              value: opcao['label'],
                              groupValue: chatController.responses[pergunta['campoFirebase']],
                              onChanged: (String? value) {
                                if (value != null) {
                                  chatController.selectOption(value, pergunta['tipo']);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  if (pergunta != null && pergunta['tipo'] == 'uploadFoto')
                    Column(
                      children: [
                        if (chatController.selectedImage != null)
                          SizedBox(
                            width: 400,
                            height: 300,
                            child: Image.memory(chatController.selectedImage!),
                          ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final Uint8List? imageBytes = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CustomWebCameraPage(
                                      appBarTitle: 'Câmera',
                                      centerTitle: true,
                                    ),
                                  ),
                                );

                                if (imageBytes != null) {
                                  chatController.selectImage(imageBytes);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16), // Added horizontal padding
                              ),
                              child: const Text('Abrir Câmera'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (chatController.selectedImage != null && !_isUploading)
                                    ? () async {
                                  setState(() {
                                    _isUploading = true;
                                  });
                                  await chatController.sendImage(
                                      chatController.selectedImage!, pergunta['id'], 'fotos');
                                  setState(() {
                                    _isUploading = false;
                                  });
                                }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16), // Added horizontal padding
                                ),
                                child: _isUploading
                                    ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : const Text("Enviar Foto"),
                              ),
                            ),
                          ],
                        ),
                        if (isSkippablePhotoType)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ElevatedButton(
                              onPressed: () {
                                chatController.sendMessage("Não tenho a Foto");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade400,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Text("Não tenho a Foto"),
                            ),
                          ),
                      ],
                    ),
                  if (pergunta != null && pergunta['tipo'] == 'opcoesImagem')
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: chatController.opcoes.map<Widget>((opcao) {
                            return GestureDetector(
                              onTap: () {
                                chatController.selectOption(opcao['label'], pergunta['tipo']);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          image: NetworkImage(opcao['imageUrl']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(width: 80, height: 80, child: Text(opcao['label'])),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  if (pergunta != null && pergunta['tipo'] == 'assinatura')
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Signature(
                            controller: _signatureController,
                            height: 200,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _signatureController.clear();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Text('Limpar'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: (!_isSignatureEmpty && !_isUploading)
                                  ? () async {
                                setState(() {
                                  _isUploading = true;
                                });
                                final signatureBytes = await _signatureController.toPngBytes();
                                if (signatureBytes != null) {
                                  await chatController.sendImage(
                                      signatureBytes, pergunta['id'], 'assinaturas');
                                  _signatureController.clear();
                                }
                                setState(() {
                                  _isUploading = false;
                                });
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: _isUploading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : const Text("Enviar Assinatura"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  if (pergunta != null && pergunta['tipo'] == 'uploadArquivo')
                    Column(
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                chatController.pickFile();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              child: const Text('Selecionar Arquivo'),
                            ),
                            const SizedBox(width: 10),
                            if (chatController.selectedFileName != null)
                              Expanded(
                                child: Text(
                                  chatController.selectedFileName!,
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (chatController.selectedFileName == null)
                              const Expanded(
                                child: Text(
                                  'Nenhum arquivo selecionado',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: (chatController.selectedFileBytes != null && !_isUploading)
                              ? () async {
                            setState(() {
                              _isUploading = true;
                            });
                            await chatController.sendUploadedFile();
                            setState(() {
                              _isUploading = false;
                            });
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: _isUploading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Text("Enviar Arquivo"),
                        ),
                      ],
                    ),
                  if (pergunta != null && pergunta['tipo'] == 'texto')
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: chatController.textController,
                            decoration: InputDecoration(
                              hintText: "Digite sua resposta...",
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) chatController.sendMessage(value);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: () {
                            final message = chatController.textController.text;
                            if (message.isNotEmpty) {
                              chatController.sendMessage(message);
                            }
                          },
                        )
                      ],
                    ),
                ],
              ),
            if (chatController.showCompletionButtons)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: chatController.resetChat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text("Responder Novamente"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('Action: Continuar');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConclusionUserForm(
                                scaffoldKey: GlobalKey<ScaffoldState>(),
                                targetCollectionName: chatController.targetCollectionName,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text("Continuar"),
                      ),
                    ),
                    const SizedBox(width: 10),

                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}