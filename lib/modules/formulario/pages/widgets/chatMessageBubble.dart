import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../chat_controller.dart';

class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  final ChatController chatController;
  final Map<String, dynamic>? associatedQuestion; // O mapa completo da pergunta

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.chatController,
    this.associatedQuestion,
  }) : super(key: key);

  @override
  State<ChatMessageBubble> createState() => ChatMessageBubbleState();
}

class ChatMessageBubbleState extends State<ChatMessageBubble> {
  String? _selectedRadioOption;
  List<String> _selectedMultiOptions = [];
  late TextEditingController _textEditDialogController;

  @override
  void initState() {
    super.initState();
    _textEditDialogController = TextEditingController(text: widget.message.text);

    if (widget.message.isUser && widget.associatedQuestion != null) {
      final String? currentAnswer = widget.chatController.responses[widget.associatedQuestion!['campoFirebase']];
      if (widget.associatedQuestion!['tipo'] == 'radio' || widget.associatedQuestion!['tipo'] == 'opcoesImagem') {
        _selectedRadioOption = currentAnswer;
      } else if (widget.associatedQuestion!['tipo'] == 'multiSelecao') {
        _selectedMultiOptions = currentAnswer?.split(', ').toList() ?? [];
      }
    }
  }

  @override
  void dispose() {
    _textEditDialogController.dispose();
    super.dispose();
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar Resposta'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.associatedQuestion != null && widget.associatedQuestion!['texto'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Pergunta: ${widget.associatedQuestion!['texto']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    _buildEditInputWidget(setDialogState),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Salvar'),
                  onPressed: () {
                    if (widget.message.questionIndex != null) {
                      dynamic newResponseValue;
                      String questionType = widget.associatedQuestion?['tipo'] ?? 'texto'; // Default to text

                      switch (questionType) {
                        case 'texto':
                          if (_textEditDialogController.text.isNotEmpty) {
                            newResponseValue = _textEditDialogController.text;
                          } else {
                            return;
                          }
                          break;
                        case 'radio':
                        case 'opcoesImagem':
                          if (_selectedRadioOption != null) {
                            newResponseValue = _selectedRadioOption;
                          } else {
                            return;
                          }
                          break;
                        case 'multiSelecao':
                          if (_selectedMultiOptions.isNotEmpty) {
                            newResponseValue = _selectedMultiOptions;
                          } else {
                            return;
                          }
                          break;
                        case 'assinatura':
                        case 'uploadArquivo':
                          newResponseValue = widget.message.text; // Keep original response (URL)
                          break;
                        default:
                          newResponseValue = _textEditDialogController.text;
                          break;
                      }

                      widget.chatController.editResponse(widget.message.questionIndex!, newResponseValue);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEditInputWidget(StateSetter setDialogState) {
    if (widget.associatedQuestion == null) {
      return const SizedBox.shrink();
    }

    final String questionType = widget.associatedQuestion!['tipo'];
    final List<Map<String, dynamic>> options = (widget.associatedQuestion!['opcoes'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    switch (questionType) {
      case 'texto':
        return TextField(
          controller: _textEditDialogController,
          decoration: InputDecoration(
            labelText: 'Sua nova resposta',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      case 'radio':
        return Column(
          children: options.map<Widget>((opcao) {
            return RadioListTile<String>(
              title: Text(opcao['label']),
              value: opcao['label'],
              groupValue: _selectedRadioOption,
              onChanged: (String? value) {
                setDialogState(() {
                  _selectedRadioOption = value;
                });
              },
            );
          }).toList(),
        );
      case 'multiSelecao':
        return Column(
          children: options.map<Widget>((opcao) {
            return CheckboxListTile(
              title: Text(opcao['label']),
              value: _selectedMultiOptions.contains(opcao['label']),
              onChanged: (bool? value) {
                setDialogState(() {
                  if (value == true) {
                    _selectedMultiOptions.add(opcao['label']);
                  } else {
                    _selectedMultiOptions.remove(opcao['label']);
                  }
                });
              },
            );
          }).toList(),
        );
      case 'opcoesImagem':
        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map<Widget>((opcao) {
            bool isSelected = _selectedRadioOption == opcao['label'];
            return GestureDetector(
              onTap: () {
                setDialogState(() {
                  _selectedRadioOption = opcao['label'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(opcao['imageUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opcao['label'],
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      case 'assinatura':
      case 'uploadArquivo':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conteúdo atual (URL ou descrição):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.message.text),
            const SizedBox(height: 16),
            const Text(
              'Para alterar a resposta, por favor, use a opção de "Responder Novamente" ou implemente uma lógica de re-upload específica.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        );
      default:
        return TextField(
          controller: _textEditDialogController,
          decoration: InputDecoration(
            labelText: 'Sua nova resposta',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the border radius based on whether it's a user message (right) or bot message (left)
    final BorderRadiusGeometry borderRadius = widget.message.isUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomRight: Radius.circular(0), // Reto no canto inferior direito para resposta
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(12),
      bottomLeft: Radius.circular(0), // Reto no canto inferior esquerdo para pergunta
      topRight: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return Align(
      alignment: widget.message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // If it's a bot message and not a user message, move the edit icon to the right
          if (!widget.message.isUser &&
              widget.message.questionIndex != null && // This usually implies a bot message related to a question
              widget.message.imageUrl == null &&
              widget.associatedQuestion?['tipo'] != 'uploadFoto' &&
              widget.associatedQuestion?['tipo'] != 'assinatura' &&
              widget.associatedQuestion?['tipo'] != 'uploadArquivo')
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
              onPressed: () => _showEditDialog(context),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: widget.message.isUser ? AppColors.primary : AppColors.secondary,
              borderRadius: borderRadius, // Apply the determined border radius
            ),
            // Use ConstrainedBox to limit width and allow text to wrap
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75, // Adjust max width as needed
            ),
            child: widget.message.imageUrl != null
                ? Image.network(
              widget.message.imageUrl!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )
                : Text(
              widget.message.text,
              style: const TextStyle(color: Colors.white),
              softWrap: true, // Allow text to wrap to the next line
              overflow: TextOverflow.visible, // Ensure text is fully visible (no ellipsis)
            ),
          ),

          // Edit icon for user messages (original position)
          if (widget.message.isUser &&
              widget.message.questionIndex != null &&
              widget.message.imageUrl == null &&
              widget.associatedQuestion?['tipo'] != 'uploadFoto' &&
              widget.associatedQuestion?['tipo'] != 'assinatura' &&
              widget.associatedQuestion?['tipo'] != 'uploadArquivo')
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
              onPressed: () => _showEditDialog(context),
            ),
        ],
      ),
    );
  }
}