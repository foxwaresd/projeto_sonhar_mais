// ignore_for_file: unused_local_variable, avoid_print

import 'dart:typed_data';
import 'dart:html' as html; // This import is specifically for web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

/// Represents a single message in the chat, distinguishing between user and bot messages.
class ChatMessage {
  final String text;
  final bool isUser;
  final String? imageUrl; // Used for displaying images within the chat
  final int? questionIndex; // To link messages back to a specific question for editing

  ChatMessage(
      this.text, {
        this.isUser = false,
        this.imageUrl,
        this.questionIndex,
      });
}

/// Manages the state and logic for the chat-based form.
class ChatController extends ChangeNotifier {
  final String formularioId;
  final String targetCollectionName; // The Firestore collection where responses will be saved

  final List<ChatMessage> messages = [];
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  int step = 0; // Current question index
  bool showInput = true; // Controls visibility of text input and action buttons
  bool showResetButton = false; // Controls visibility of the reset button
  bool showCompletionButtons = false; // New: Controls visibility of "Continue" / "Answer Again" buttons

  // MUDANÇA: O Map de respostas agora pode guardar outros tipos além de String
  Map<String, dynamic> responses = {};
  List<Map<String, dynamic>> perguntas = []; // List of questions loaded from Firestore
  List<Map<String, dynamic>> opcoes = []; // Options for the current question
  List<String> selectedOptions = []; // For multi-selection questions

  Uint8List? _selectedImage;
  Uint8List? _selectedImage2;
  Uint8List? selectedFileBytes;
  String? selectedFileName;

  final List<String> _questionsToSkipIfHasSpouse = const [
    'peso2', 'altura2', 'tipoSanguineo2', 'etnia2', 'fitzpatrick2',
    'corOlhos2', 'corCabelo2', 'tipoCabelo2', 'caracteristicas2',
  ];

  String? _currentRegistrationDocId;

  ChatController({required this.formularioId, required this.targetCollectionName}) {
    _loadQuestions();
  }

  Uint8List? get selectedImage => _selectedImage;
  Uint8List? get selectedImage2 => _selectedImage2;

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void selectImage(Uint8List? imageBytes) {
    _selectedImage = imageBytes;
    notifyListeners();
  }

  void selectImage2(Uint8List? imageBytes) {
    _selectedImage2 = imageBytes;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void clearSelectedImage2() {
    _selectedImage2 = null;
    notifyListeners();
  }

  void selectFile(Uint8List fileBytes, String fileName) {
    selectedFileBytes = fileBytes;
    selectedFileName = fileName;
    notifyListeners();
  }

  void clearSelectedFile() {
    selectedFileBytes = null;
    selectedFileName = null;
    notifyListeners();
  }

  Future<void> _loadQuestions() async {
    try {
      print("Carregando perguntas para formularioId: $formularioId");
      final snapshot = await _firestore
          .collection('perguntas')
          .where('ativa', isEqualTo: true)
          .where('formularioId', isEqualTo: formularioId)
          .orderBy('ordem')
          .get();
      print("Número de perguntas encontradas: ${snapshot.docs.length}");
      perguntas = snapshot.docs.map((doc) =>
      {
        'id': doc.id,
        'texto': doc['texto'],
        'campoFirebase': doc['campoFirebase'],
        'tipo': doc['tipo'],
        'opcoes': (doc['opcoes'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      }).toList();
      _startChat();
    } catch (e) {
      print("Erro ao carregar perguntas: $e");
      messages.add(ChatMessage("Erro ao carregar perguntas: $e"));
      notifyListeners();
    }
  }

  void _startChat() {
    if (perguntas.isNotEmpty) {
      messages.add(ChatMessage(perguntas[step]['texto']));
      opcoes = List<Map<String, dynamic>>.from(perguntas[step]['opcoes']);
      selectedOptions = [];
      notifyListeners();
      _scrollToBottom();

      if ((targetCollectionName == 'doadores' || targetCollectionName == 'receptores' || targetCollectionName == 'receptora') &&
          _currentRegistrationDocId == null) {
        _currentRegistrationDocId = _firestore.collection(targetCollectionName).doc().id;
        print('Novo ID de cadastro (temporário) gerado: $_currentRegistrationDocId');
      }
    } else {
      messages.add(ChatMessage("Não há perguntas disponíveis no momento."));
      notifyListeners();
    }
  }

  void sendMessage(String userResponse, {String? imageUrl}) {
    messages.add(ChatMessage(userResponse, isUser: true, imageUrl: imageUrl, questionIndex: step));
    if (step < perguntas.length && perguntas[step].containsKey('campoFirebase') && perguntas[step]['campoFirebase'] != null) {
      responses[_getQuestionKey(step)] = userResponse;
    }
    textController.clear();
    notifyListeners();
    _scrollToBottom();
    if (imageUrl != null) {
      clearSelectedImage();
      clearSelectedImage2();
    }
    Future.delayed(const Duration(seconds: 1), nextQuestion);
  }

  void nextQuestion() {
    step++;
    final bool possuiConjugeAnswered = responses.containsKey('possuiConjuge');
    while (step < perguntas.length) {
      final String? nextQuestionCampoFirebase = perguntas[step]['campoFirebase'];
      if (possuiConjugeAnswered &&
          nextQuestionCampoFirebase != null &&
          _questionsToSkipIfHasSpouse.contains(nextQuestionCampoFirebase)) {
        responses[perguntas[step]['campoFirebase']] = "Não se aplica";
        print('Pulando pergunta: ${perguntas[step]['texto']} (campoFirebase: $nextQuestionCampoFirebase)');
        step++;
      } else {
        break;
      }
    }
    if (step < perguntas.length) {
      messages.add(ChatMessage(perguntas[step]['texto']));
      opcoes = List<Map<String, dynamic>>.from(perguntas[step]['opcoes']);
      selectedOptions = [];
      _scrollToBottom();
    } else {
      showInput = false;
      showResetButton = false; // Mantém o botão de reset oculto até a confirmação de salvamento
      opcoes.clear();
      selectedOptions.clear();
      textController.clear();
      messages.add(ChatMessage("Obrigado por responder! Salvando suas informações..."));
      _scrollToBottom();
      _saveResponses();
      // After saving, show completion options
      _showCompletionOptions();
    }
    notifyListeners();
  }

  Future<String?> _uploadFile(Uint8List fileBytes, String fileName, String folder) async {
    try {
      final String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final Reference ref = _storage.ref().child('$folder/$uniqueFileName');
      final UploadTask uploadTask = ref.putData(fileBytes);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Erro ao fazer upload do arquivo ($fileName) para $folder: $e");
      messages.add(ChatMessage("Erro ao enviar o arquivo: $e"));
      notifyListeners();
      return null;
    }
  }

  // ATUALIZADO: para receber e armazenar o embedding
  Future<void> _callFaceRecognitionCloudFunction(String imageUrl) async {
    try {
      messages.add(ChatMessage("Processando características do rosto...", isUser: false));
      notifyListeners();

      final HttpsCallable callable = _functions.httpsCallable('processFaceForEmbedding');
      final result = await callable.call(<String, dynamic>{
        'imageUrl': imageUrl,
      });

      final faceEmbedding = result.data['faceEmbedding'];
      if (faceEmbedding != null) {
        // Armazena o embedding junto com as outras respostas
        responses['faceEmbedding'] = faceEmbedding;
        messages.add(ChatMessage("Características do rosto processadas com sucesso!", isUser: false));
      } else {
        throw Exception('Embedding não retornado pela função.');
      }

    } on FirebaseFunctionsException catch (e) {
      print('Erro na Cloud Function: ${e.code} - ${e.message}');
      messages.add(ChatMessage("Erro ao processar o rosto: ${e.message}", isUser: false));
    } catch (e) {
      print('Erro inesperado ao chamar Cloud Function: $e');
      messages.add(ChatMessage("Erro inesperado ao processar o rosto: $e", isUser: false));
    } finally {
      notifyListeners();
      _scrollToBottom();
    }
  }

  Future<void> sendImage(Uint8List imageBytes, String perguntaId, String folderName) async {
    final downloadUrl = await _uploadFile(imageBytes, 'resposta_$perguntaId.jpg', folderName);
    if (downloadUrl != null) {
      final String campo = _getQuestionKey(step);
      responses[campo] = downloadUrl;
      sendMessage(downloadUrl, imageUrl: downloadUrl);

      if (folderName == 'fotos') {
        // A função agora só precisa da URL da imagem
        await _callFaceRecognitionCloudFunction(downloadUrl);
      }

      clearSelectedImage();
      clearSelectedImage2();
    }
  }

  Future<void> sendUploadedFile() async {
    if (selectedFileBytes != null && selectedFileName != null) {
      final downloadUrl = await _uploadFile(selectedFileBytes!, selectedFileName!, 'uploads');
      if (downloadUrl != null) {
        final String campo = _getQuestionKey(step);
        responses[campo] = downloadUrl;
        sendMessage(downloadUrl, imageUrl: null);
        clearSelectedFile();
      }
    } else {
      messages.add(ChatMessage("Nenhum arquivo selecionado!"));
      notifyListeners();
    }
  }

  /// Saves the collected responses to Firestore, adding a status based on the collection.
  Future<void> _saveResponses() async {
    final Map<String, dynamic> dataToSave = {};

    responses.forEach((key, value) {
      if (key == 'faceEmbedding') {
        dataToSave[key] = value;
      } else if (value is String && !value.startsWith('http')) {
        dataToSave[key] = value.toUpperCase();
      } else {
        dataToSave[key] = value;
      }
    });

    // Add the status based on the target collection name
    if (targetCollectionName == 'doadoras') {
      dataToSave['status'] = 'Pendente Punção';
    } else if (targetCollectionName == 'receptores' || targetCollectionName == 'receptora') {
      dataToSave['status'] = 'Iniciando a ficha';
    }

    try {
      final HttpsCallable callable = _functions.httpsCallable('generateSequentialUserIdAndSave');
      final result = await callable.call(<String, dynamic>{
        'userData': dataToSave,
        'targetCollection': targetCollectionName,
      });

      final newUserId = result.data['userId'];
      messages.add(ChatMessage("Suas respostas foram salvas com sucesso! Seu ID de cadastro é: $newUserId"));
      print("Usuário criado com sucesso com ID sequencial: $newUserId");

      // ATUALIZAÇÃO DA UI: Mostra o botão de concluir/resetar
      showResetButton = true; // This can be removed if "showCompletionButtons" replaces it.
      showInput = false;

    } catch (e) {
      print("Erro ao chamar a Cloud Function para salvar respostas: $e");
      messages.add(ChatMessage("Ocorreu um erro ao salvar suas respostas: $e"));
    } finally {
      notifyListeners();
    }
  }

  // New method to show completion options
  void _showCompletionOptions() {
    showInput = false;
    showResetButton = false; // Hide the reset button if completion buttons are shown
    showCompletionButtons = true;
    notifyListeners();
    _scrollToBottom();
  }

  String _getQuestionKey(int step) => perguntas[step]['campoFirebase'];

  void resetChat() {
    showInput = true;
    showResetButton = false;
    showCompletionButtons = false; // Hide completion buttons on reset
    step = 0;
    responses.clear();
    messages.clear();
    opcoes.clear();
    selectedOptions.clear();
    textController.clear();
    _currentRegistrationDocId = null;
    _startChat();
    clearSelectedFile();
    clearSelectedImage();
    clearSelectedImage2();
    notifyListeners();
  }

  void selectOption(String optionText, String tipo) {
    if (tipo == 'multiSelecao') {
      if (selectedOptions.contains(optionText)) {
        selectedOptions.remove(optionText);
      } else {
        selectedOptions.add(optionText);
      }
    } else if (tipo == 'radio' || tipo == 'opcoesImagem') {
      responses[_getQuestionKey(step)] = optionText;
      sendMessage(optionText);
    }
    notifyListeners();
  }

  void sendSelectedOptions() {
    sendMessage(selectedOptions.join(', '));
  }

  Future<void> getImageFromCamera(Function(Uint8List) onImageSelected) async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.setAttribute('capture', 'user');
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          final bytes = reader.result as Uint8List;
          onImageSelected(bytes);
        });
      }
    });
  }

  Future<void> getImageFromCamera2(Function(Uint8List) onImageSelected) async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.setAttribute('capture', 'user');
    uploadInput.setAttribute('facingMode', 'environment'); // Optional: For rear camera
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          final bytes = reader.result as Uint8List;
          onImageSelected(bytes);
        });
      }
    });
  }

  void getImage() {
    getImageFromCamera((Uint8List bytes) {
      selectImage(bytes);
    });
  }

  void getImage2() {
    getImageFromCamera2((Uint8List bytes) {
      selectImage2(bytes);
    });
  }

  Future<void> pickFile() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          final bytes = reader.result as Uint8List;
          selectFile(bytes, file.name);
        });
      }
    });
  }

  void editResponse(int questionIndex, dynamic newResponseValue) {
    if (questionIndex >= 0 && questionIndex < perguntas.length) {
      final String questionKey = _getQuestionKey(questionIndex);
      String responseText;
      String? updatedImageUrl;

      if (newResponseValue is List<String>) {
        responseText = newResponseValue.join(', ');
      } else {
        responseText = newResponseValue.toString();
      }

      if (Uri.tryParse(responseText)?.hasAbsolutePath == true && (responseText.startsWith('http://') || responseText.startsWith('https://'))) {
        updatedImageUrl = responseText;
      }

      responses[questionKey] = newResponseValue;

      for (int i = messages.length - 1; i >= 0; i--) {
        if (messages[i].isUser && messages[i].questionIndex == questionIndex) {
          messages[i] = ChatMessage(responseText, isUser: true, imageUrl: updatedImageUrl, questionIndex: questionIndex);
          break;
        }
      }
      notifyListeners();
      _scrollToBottom();
    }
  }
}