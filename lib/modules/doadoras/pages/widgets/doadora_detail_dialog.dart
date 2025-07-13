import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../../core/theme/app_colors.dart';
import '../doadora_list_page.dart'; // Assuming Doadora class is here
import 'doadora_pdf_generator.dart';

class DoadoraDetailDialog extends StatefulWidget {
  final Doadora doadora;
  const DoadoraDetailDialog({required this.doadora, Key? key}) : super(key: key);

  @override
  State<DoadoraDetailDialog> createState() => _DoadoraDetailDialogState();
}

class _DoadoraDetailDialogState extends State<DoadoraDetailDialog> {
  late TextEditingController atividadeFisicaController;
  late TextEditingController prontuarioEletronicoController;
  late TextEditingController assinaturaController;
  late TextEditingController alturaController;
  late TextEditingController caracteristicas1Controller;
  late TextEditingController cepController;
  late TextEditingController cidadeController;
  late TextEditingController cpfController;
  late TextEditingController cabeloCorController;
  late TextEditingController cabeloTexturaController;
  late TextEditingController declaroVeracidadeController;
  late TextEditingController dobController;
  late TextEditingController emailController;
  late TextEditingController enderecoController;
  late TextEditingController estadoController;
  late TextEditingController escolaridadeController;
  late TextEditingController estadoCivilController;
  late TextEditingController examesController;
  late TextEditingController filhosController;
  late TextEditingController filhaAdotivaController;
  late TextEditingController fitzpatrickController;
  late TextEditingController gemeosController;
  late TextEditingController imcController;


  late TextEditingController historicoDoadoraEpilepsiaController;
  late TextEditingController historicoDoadoraDeficienciaFisicaController;
  late TextEditingController historicoDoadoraDeficienciaMentalController;
  late TextEditingController historicoDoadoraDiabetesMellitusController;
  late TextEditingController historicoDoadoraDoencasGeneticasController;
  late TextEditingController historicoDoadoraEspinhaBifidaController;
  late TextEditingController historicoDoadoraHipertensaoController;
  late TextEditingController historicoDoadoraLabioLeporinoController;
  late TextEditingController historicoDoadoraMalFormacaoCardicaController;
  late TextEditingController historicoDoadorasNeoplasiasController;


  late TextEditingController historicoFamiliarAnemiaFalciformeController;
  late TextEditingController historicoFamiliarAtrofiaMuscularController;
  late TextEditingController historicoFamiliarAutismoController;
  late TextEditingController historicoFamiliarDeficienciaFisicaController;
  late TextEditingController historicoFamiliarDeficienciaMentalController;
  late TextEditingController historicoFamiliarDepressaoController;
  late TextEditingController historicoFamiliarDiabetesMelittusController;
  late TextEditingController historicoFamiliarDistrofiaMuscularController;
  late TextEditingController historicoFamiliarDoencaIsquemicaController;
  late TextEditingController historicoFamiliarDoencaGeneticaController;

  late TextEditingController historicoFamiliarEpilepsiaController;
  late TextEditingController historicoFamiliarEsquizofreniaController;
  late TextEditingController historicoFamiliarFibroseCisticaController;
  late TextEditingController historicoFamiliarHipertensaoController;
  late TextEditingController historicoFamiliarNeoplasiaController;
  late TextEditingController historicoFamiliarTalassemiaController;

  late TextEditingController historicoSaudeAlergiaController;
  late TextEditingController historicoSaudeAsmaController;
  late TextEditingController historicoSaudeAudicaoController;
  late TextEditingController historicoSaudeDoencaCronicaController;
  late TextEditingController historicoSaudeDrogasController;
  late TextEditingController historicoSaudeFumanteController;
  late TextEditingController historicoSaudeVisaoController;



  late TextEditingController hobbyController;
  late TextEditingController idadeController;
  late TextEditingController idiomaController;
  late TextEditingController irmaosController;
  late TextEditingController medicoAssistenteController;
  late TextEditingController motivoController;
  late TextEditingController nomeController;
  late TextEditingController ovulosController;
  late TextEditingController observacaoController;
  late TextEditingController olhosController;
  late TextEditingController pesoController;
  late TextEditingController profissaoController;
  late TextEditingController qualidadesController;
  late TextEditingController racaController;
  late TextEditingController rgController;
  late TextEditingController signoController;
  late TextEditingController tipoSanguineoController;
  late TextEditingController telefoneController;

  String? newPhotoUrl;
  bool isSaving = false;
  bool _isProcessingFace = false;

  // Novo: Variável para armazenar o status selecionado
  String? _selectedStatus;
  final List<String> _statusOptions = [
    'Pendente Punção',
    'Punção Feita',
    'Aguardando Exames',
    'Óvulos Reservados',
    'Excluída',
    'Desistiu',
    'Todos os Óvulos Doados',
  ];

  @override
  void initState() {
    super.initState();
    alturaController = TextEditingController(text: widget.doadora.altura);
    prontuarioEletronicoController = TextEditingController(text: widget.doadora.prontuarioEletronico);
    assinaturaController = TextEditingController(text: widget.doadora.assinatura);
    atividadeFisicaController = TextEditingController(text: widget.doadora.atividadeFisica);
    cabeloCorController = TextEditingController(text: widget.doadora.cabeloCor);
    cabeloTexturaController = TextEditingController(text: widget.doadora.cabeloTextura);
    caracteristicas1Controller = TextEditingController(text: widget.doadora.caracteristicas1);
    cepController = TextEditingController(text: widget.doadora.cep);
    cidadeController = TextEditingController(text: widget.doadora.cidade);
    cpfController = TextEditingController(text: widget.doadora.cpf);
    declaroVeracidadeController = TextEditingController(text: widget.doadora.declaroVeracidade);
    dobController = TextEditingController(text: widget.doadora.dob);
    emailController = TextEditingController(text: widget.doadora.email);
    enderecoController = TextEditingController(text: widget.doadora.endereco);
    escolaridadeController = TextEditingController(text: widget.doadora.escolaridade);
    estadoCivilController = TextEditingController(text: widget.doadora.estadoCivil);
    estadoController = TextEditingController(text: widget.doadora.estado);
    examesController = TextEditingController(text: widget.doadora.exames.join('\n'));
    filhaAdotivaController = TextEditingController(text: widget.doadora.filhaAdotiva);
    filhosController = TextEditingController(text: widget.doadora.filhos);
    fitzpatrickController = TextEditingController(text: widget.doadora.fitzpatrick);
    gemeosController = TextEditingController(text: widget.doadora.gemeos);
    imcController = TextEditingController();
    historicoDoadoraEpilepsiaController = TextEditingController(text: widget.doadora.historicoDoadora);
    historicoDoadoraDeficienciaFisicaController = TextEditingController(text: widget.doadora.historicoDoadoraDeficienciaFisica);
    historicoDoadoraDeficienciaMentalController = TextEditingController(text: widget.doadora.historicoDoadoraDeficienciaMental);
    historicoDoadoraDiabetesMellitusController = TextEditingController(text: widget.doadora.historicoDoadoraDiabetesMellitus);
    historicoDoadoraDoencasGeneticasController = TextEditingController(text: widget.doadora.historicoDoadoraDoencasGeneticas);
    historicoDoadoraEspinhaBifidaController = TextEditingController(text: widget.doadora.historicoDoadoraEspinhaBifida);
    historicoDoadoraHipertensaoController = TextEditingController(text: widget.doadora.historicoDoadoraHipertensao);
    historicoDoadoraLabioLeporinoController = TextEditingController(text: widget.doadora.historicoDoadoraLabioLeporino);
    historicoDoadoraMalFormacaoCardicaController = TextEditingController(text: widget.doadora.historicoDoadoraMalFormacaoCardica);
    historicoDoadorasNeoplasiasController = TextEditingController(text: widget.doadora.historicoDoadorasNeoplasias);
    historicoFamiliarAnemiaFalciformeController = TextEditingController(text: widget.doadora.historicoFamiliarAnemiaFalciforme);
    historicoFamiliarAtrofiaMuscularController = TextEditingController(text: widget.doadora.historicoFamiliarAtrofiaMuscular);
    historicoFamiliarAutismoController = TextEditingController(text: widget.doadora.historicoFamiliarAutismo);
    historicoFamiliarDeficienciaFisicaController = TextEditingController(text: widget.doadora.historicoFamiliarDeficienciaFisica);
    historicoFamiliarDeficienciaMentalController = TextEditingController(text: widget.doadora.historicoFamiliarDeficienciaMental);
    historicoFamiliarDepressaoController = TextEditingController(text: widget.doadora.historicoFamiliarDepressao);
    historicoFamiliarDiabetesMelittusController = TextEditingController(text: widget.doadora.historicoFamiliarDiabetesMelittus);
    historicoFamiliarDistrofiaMuscularController = TextEditingController(text: widget.doadora.historicoFamiliarDistrofiaMuscular);
    historicoFamiliarDoencaGeneticaController = TextEditingController(text: widget.doadora.historicoFamiliarDoencaGenetica);
    historicoFamiliarDoencaIsquemicaController = TextEditingController(text: widget.doadora.historicoFamiliarDoencaIsquemica);
    historicoFamiliarEpilepsiaController = TextEditingController(text: widget.doadora.historicoFamiliarEpilepsia);
    historicoFamiliarEsquizofreniaController = TextEditingController(text: widget.doadora.historicoFamiliarEsquizofrenia);
    historicoFamiliarFibroseCisticaController = TextEditingController(text: widget.doadora.historicoFamiliarFibroseCistica);
    historicoFamiliarHipertensaoController = TextEditingController(text: widget.doadora.historicoFamiliarHipertensao);
    historicoFamiliarNeoplasiaController = TextEditingController(text: widget.doadora.historicoFamiliarNeoplasia);
    historicoFamiliarTalassemiaController = TextEditingController(text: widget.doadora.historicoFamiliarTalassemia);
    historicoSaudeAlergiaController = TextEditingController(text: widget.doadora.historicoSaudeAlergia);
    historicoSaudeAsmaController = TextEditingController(text: widget.doadora.historicoSaudeAsma);
    historicoSaudeAudicaoController = TextEditingController(text: widget.doadora.historicoSaudeAudicao);
    historicoSaudeDoencaCronicaController = TextEditingController(text: widget.doadora.historicoSaudeDoencaCronica);
    historicoSaudeDrogasController = TextEditingController(text: widget.doadora.historicoSaudeDrogas);
    historicoSaudeFumanteController = TextEditingController(text: widget.doadora.historicoSaudeFumante);
    historicoSaudeVisaoController = TextEditingController(text: widget.doadora.historicoSaudeVisao);
    hobbyController = TextEditingController(text: widget.doadora.hobby);
    idadeController = TextEditingController(text: widget.doadora.idade);
    idiomaController = TextEditingController(text: widget.doadora.idioma);
    irmaosController = TextEditingController(text: widget.doadora.irmaos);
    medicoAssistenteController = TextEditingController(text: widget.doadora.medicoAssistente);
    motivoController = TextEditingController(text: widget.doadora.motivo);
    nomeController = TextEditingController(text: widget.doadora.nome);
    observacaoController = TextEditingController(text: widget.doadora.observacao);
    olhosController = TextEditingController(text: widget.doadora.olhos);
    ovulosController = TextEditingController(text: widget.doadora.ovulos);
    pesoController = TextEditingController(text: widget.doadora.peso);
    profissaoController = TextEditingController(text: widget.doadora.profissao);
    qualidadesController = TextEditingController(text: widget.doadora.qualidades);
    racaController = TextEditingController(text: widget.doadora.raca);
    rgController = TextEditingController(text: widget.doadora.rg);
    signoController = TextEditingController(text: widget.doadora.signo);
    telefoneController = TextEditingController(text: widget.doadora.telefone);
    tipoSanguineoController = TextEditingController(text: widget.doadora.tipoSanguineo);

    // Adicione listeners para recalcular o IMC quando peso ou altura mudarem
    pesoController.addListener(_calcularEAtualizarIMC);
    alturaController.addListener(_calcularEAtualizarIMC);

    // Inicializa o _selectedStatus com o valor atual da doadora ou a primeira opção
    _selectedStatus = widget.doadora.status.isNotEmpty ? widget.doadora.status : _statusOptions.first;

    // Chame o cálculo inicial do IMC para preencher o campo se já houver dados
    _calcularEAtualizarIMC();


  }

  @override
  void dispose() {
    imcController.dispose();
    prontuarioEletronicoController.dispose();
    pesoController.removeListener(_calcularEAtualizarIMC); // REMOVER LISTENER ANTES DE DISCARDAR
    pesoController.dispose();
    alturaController.removeListener(_calcularEAtualizarIMC); // REMOVER LISTENER ANTES DE DISCARDAR
    alturaController.dispose();
    assinaturaController.dispose();
    atividadeFisicaController.dispose();
    cabeloCorController.dispose();
    cabeloTexturaController.dispose();
    caracteristicas1Controller.dispose();
    cepController.dispose();
    cidadeController.dispose();
    cpfController.dispose();
    declaroVeracidadeController.dispose();
    dobController.dispose();
    emailController.dispose();
    enderecoController.dispose();
    escolaridadeController.dispose();
    estadoCivilController.dispose();
    estadoController.dispose();
    examesController.dispose();
    filhaAdotivaController.dispose();
    filhosController.dispose();
    fitzpatrickController.dispose();
    gemeosController.dispose();
    historicoDoadoraEpilepsiaController.dispose();
    historicoDoadoraDeficienciaFisicaController.dispose();
    historicoDoadoraDeficienciaMentalController.dispose();
    historicoDoadoraDiabetesMellitusController.dispose();
    historicoDoadoraDoencasGeneticasController.dispose();
    historicoDoadoraEspinhaBifidaController.dispose();
    historicoDoadoraHipertensaoController.dispose();
    historicoDoadoraLabioLeporinoController.dispose();
    historicoDoadoraMalFormacaoCardicaController.dispose();
    historicoDoadorasNeoplasiasController.dispose();
    historicoFamiliarAnemiaFalciformeController.dispose();
    historicoFamiliarAtrofiaMuscularController.dispose();
    historicoFamiliarAutismoController.dispose();
    historicoFamiliarDeficienciaFisicaController.dispose();
    historicoFamiliarDeficienciaMentalController.dispose();
    historicoFamiliarDepressaoController.dispose();
    historicoFamiliarDiabetesMelittusController.dispose();
    historicoFamiliarDistrofiaMuscularController.dispose();
    historicoFamiliarDoencaGeneticaController.dispose();
    historicoFamiliarDoencaIsquemicaController.dispose();
    historicoFamiliarEpilepsiaController.dispose();
    historicoFamiliarEsquizofreniaController.dispose();
    historicoFamiliarFibroseCisticaController.dispose();
    historicoFamiliarHipertensaoController.dispose();
    historicoFamiliarNeoplasiaController.dispose();
    historicoFamiliarTalassemiaController.dispose();
    historicoSaudeAlergiaController.dispose();
    historicoSaudeAsmaController.dispose();
    historicoSaudeAudicaoController.dispose();
    historicoSaudeDoencaCronicaController.dispose();
    historicoSaudeDrogasController.dispose();
    historicoSaudeFumanteController.dispose();
    historicoSaudeVisaoController.dispose();
    hobbyController.dispose();
    idadeController.dispose();
    idiomaController.dispose();
    irmaosController.dispose();
    medicoAssistenteController.dispose();
    motivoController.dispose();
    nomeController.dispose();
    observacaoController.dispose();
    olhosController.dispose();
    ovulosController.dispose();
    profissaoController.dispose();
    qualidadesController.dispose();
    racaController.dispose();
    rgController.dispose();
    signoController.dispose();
    telefoneController.dispose();
    tipoSanguineoController.dispose();

    super.dispose();
  }

  // NOVO MÉTODO: Scannear Rosto e Obter Embedding
  Future<void> _scanFaceForEmbedding() async {
    setState(() {
      _isProcessingFace = true;
    });

    try {
      final imageUrl = newPhotoUrl ?? widget.doadora.foto;
      if (imageUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, adicione uma foto antes de escanear o rosto.')),
        );
        return;
      }

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('processFaceForEmbedding');
      final result = await callable.call({'imageUrl': imageUrl});

      if (result.data != null && result.data['success'] == true) {
        final List<dynamic> rawEmbedding = result.data['faceEmbedding'];
        final List<double> faceEmbedding = rawEmbedding.map((e) => (e as num).toDouble()).toList();

        // Salvar o faceEmbedding no documento da doadora no Firestore
        final docRef = FirebaseFirestore.instance.collection('doadoras').doc(widget.doadora.id);
        await docRef.update({'faceEmbedding': faceEmbedding});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rosto escaneado e embedding salvo com sucesso!')),
        );
        // Opcional: Atualizar a doadora localmente para que o botão desapareça
        // Você pode recarregar a doadora ou atualizar o widget.doadora.faceEmbedding
        // Por simplicidade, faremos um pop do dialog e assumimos que a lista será recarregada.
        // Ou, se quiser mais dinamicidade, pode-se passar o faceEmbedding para o widget.doadora.
        // Para este exemplo, farei um pop para recarregar.
        Navigator.of(context).pop(true); // Retorna true para indicar que houve uma atualização
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao escanear rosto: ${result.data['message'] ?? 'Detalhes desconhecidos.'}')),
        );
      }
    } on FirebaseFunctionsException catch (e) {
      print('Erro de Cloud Function: ${e.code} - ${e.message} - ${e.details}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na Cloud Function: ${e.message}')),
      );
    } catch (e) {
      print('Erro inesperado ao escanear rosto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado ao escanear rosto: $e')),
      );
    } finally {
      setState(() {
        _isProcessingFace = false;
      });
    }
  }

  Future<void> pickNewPhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = await picked.readAsBytes();
        final storageRef = FirebaseStorage.instance.ref().child('doadoras/${widget.doadora.id}/foto.jpg');
        final uploadTask = storageRef.putData(file);
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          newPhotoUrl = downloadUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar a foto: $e')),
      );
    }
  }

  void _calcularEAtualizarIMC() {
    try {
      // CORRIGIDO: Trocar vírgula por ponto para garantir a conversão correta
      double? peso = double.tryParse(pesoController.text.replaceAll(',', '.'));
      double? altura = double.tryParse(alturaController.text.replaceAll(',', '.')); // Altura deve estar em metros!

      // Verifica se os valores são válidos e positivos
      if (peso != null && altura != null && peso > 0 && altura > 0) {
        // Se a altura é inserida em centímetros (ex: 170), converta para metros.
        // Se a sua Doadora.altura já salva em metros, pode remover essa linha.
        // double alturaEmMetros = altura / 100; // Descomente se altura for em CM e precisar converter

        double imc = peso / (altura * altura); // Use altura (ou alturaEmMetros se necessário)
        // Atualiza o texto do controlador do IMC, formatando para 2 casas decimais
        // CORRIGIDO: Usar setState para garantir que a UI seja reconstruída
        setState(() {
          imcController.text = imc.toStringAsFixed(2);
        });
      } else {
        // Limpa o campo do IMC se os valores forem inválidos ou vazios
        setState(() {
          imcController.text = '';
        });
      }
    } catch (e) {
      // Em caso de erro na conversão ou cálculo (embora o tryParse já ajude), exibe "Erro"
      setState(() {
        imcController.text = 'Erro';
      });
      print("Erro ao calcular IMC: $e");
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Stack( // Use a Stack to layer widgets
            children: [
              Container(
                // You can add width/height constraints here if needed,
                // or let the Image.network determine the size within the dialog
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned( // Position the close button
                top: 8, // Adjust as needed for spacing from the top
                right: 8, // Adjust as needed for spacing from the right
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // White background for the button
                    shape: BoxShape.circle, // Circular shape
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close,color: AppColors.primary,),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Future<void> saveChanges() async {
    setState(() => isSaving = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('doadoras').doc(widget.doadora.id);

      final List<String> updatedExames = examesController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await docRef.update({
        'nome': nomeController.text,
        'prontuarioEletronico': prontuarioEletronicoController.text,
        'idade': idadeController.text,
        'observacao': observacaoController.text,
        'peso': pesoController.text,
        'altura': alturaController.text,
        'tipoSanguineo': tipoSanguineoController.text,
        'olhos': olhosController.text,
        'cabeloCor': cabeloCorController.text,
        'cabeloTextura': cabeloTexturaController.text,
        'raca': racaController.text,
        'profissao': profissaoController.text,
        'hobby': hobbyController.text,
        'atividadeFisica': atividadeFisicaController.text,
        'escolaridade': escolaridadeController.text,
        'estadoCivil': estadoCivilController.text,
        'filhos': filhosController.text,
        'exames': updatedExames,
        if (newPhotoUrl != null) 'foto': newPhotoUrl,
        'status': _selectedStatus, // Salva o novo status!
      });

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações: $e')),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> deleteDoadora() async {
    try {
      await FirebaseFirestore.instance.collection('doadoras').doc(widget.doadora.id).delete();
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar: $e')),
      );
    }
  }

  Widget buildSection(String title, List<Widget> fields) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: fields.map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: e,
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween
              children: [
                // Novo: Dropdown para o status
                Expanded( // Added Expanded to give it space
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjust padding
                    ),
                    value: _selectedStatus,
                    items: _statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    },
                    isExpanded: true, // Make dropdown button expand horizontally
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Add some spacing after the status row
            // --- Existing: Row for Photo and Initial TextFields ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showImageDialog(context, newPhotoUrl ?? widget.doadora.foto),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          newPhotoUrl ?? widget.doadora.foto,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 250,
                              height: 250,
                              color: Colors.grey[300],
                              child: Icon(Icons.person, size: 100, color: Colors.grey[600]),
                            );
                          },
                        ),
                      ),
                    ),
                    Row( // Agrupando os botões de foto
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: pickNewPhoto,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Alterar Foto'),
                        ),
                        // Lógica Condicional para o Botão "Scanear Rosto"
                        if (widget.doadora.faceEmbedding == null || widget.doadora.faceEmbedding!.isEmpty)
                          _isProcessingFace
                              ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                              : TextButton.icon(
                            onPressed: _scanFaceForEmbedding,
                            icon: const Icon(Icons.face_retouching_natural),
                            label: const Text('Scanear Rosto'),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    children: [
                      TextField(controller: prontuarioEletronicoController,
                          decoration: const InputDecoration(labelText: 'ID Prontuario Eletrônico')),
                      TextField(controller: nomeController,
                          decoration: const InputDecoration(labelText: 'Nome')),
                      TextField(controller: observacaoController,
                          maxLines: null,
                          decoration: const InputDecoration(labelText: 'Observação')),
                    ].map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: e,
                    )).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            const SizedBox(height: 16),

          buildSection("Dados Pessoais", [
        TextField(controller: nomeController,
            decoration: const InputDecoration(labelText: 'Nome Completo')),

        TextField(controller: idadeController,
            decoration: const InputDecoration(labelText: 'Idade')),
        TextField(controller: dobController,
            decoration: const InputDecoration(labelText: 'Data de Nascimento (DOB)')),
        TextField(controller: emailController,
            decoration: const InputDecoration(labelText: 'Email')),
        TextField(controller: telefoneController,
            decoration: const InputDecoration(labelText: 'Telefone')),
        TextField(controller: cpfController,
            decoration: const InputDecoration(labelText: 'CPF')),
        TextField(controller: rgController,
            decoration: const InputDecoration(labelText: 'RG')),
        TextField(controller: cepController,
            decoration: const InputDecoration(labelText: 'CEP')),
        TextField(controller: enderecoController,
            decoration: const InputDecoration(labelText: 'Endereço')),
        TextField(controller: cidadeController,
            decoration: const InputDecoration(labelText: 'Cidade')),
        TextField(controller: estadoController,
            decoration: const InputDecoration(labelText: 'Estado')),
        TextField(controller: pesoController,
            decoration: const InputDecoration(labelText: 'Peso')),
        TextField(controller: alturaController,
            decoration: const InputDecoration(labelText: 'Altura')),
            TextField(
              controller: imcController, // O valor é exibido através do controller
              decoration: const InputDecoration(labelText: 'IMC'), // Label fixo para o campo
              readOnly: true, // Campo somente leitura
              enabled: false, // Campo desabilitado para interação
              style: const TextStyle(fontWeight: FontWeight.bold), // Estilo opcional para destaque
            ),
      ]),

            buildSection("Dados fenotípicos", [

              TextField(controller: tipoSanguineoController,
                  decoration: const InputDecoration(labelText: 'Tipo Sanguíneo')),
              TextField(controller: olhosController,
                  decoration: const InputDecoration(labelText: 'Cor dos Olhos')),
              TextField(controller: cabeloCorController,
                  decoration: const InputDecoration(labelText: 'Cor do Cabelo')),
              TextField(controller: cabeloTexturaController,
                  decoration: const InputDecoration(labelText: 'Textura do Cabelo')),
              TextField(controller: racaController,
                  decoration: const InputDecoration(labelText: 'Raça')),
              TextField(controller: signoController,
                  decoration: const InputDecoration(labelText: 'Signo')),
              TextField(controller: fitzpatrickController,
                  decoration: const InputDecoration(labelText: 'Escala Fitzpatrick')),
              TextField(controller: idiomaController,
                  decoration: const InputDecoration(labelText: 'Idioma')),
              TextField(controller: caracteristicas1Controller,
                  decoration: const InputDecoration(labelText: 'Características Adicionais')),
            ]),


        buildSection("Contexto Social e Estilo de Vida", [
          TextField(controller: profissaoController,
              decoration: const InputDecoration(labelText: 'Profissão')),
          TextField(controller: hobbyController,
              decoration: const InputDecoration(labelText: 'Hobby')),
          TextField(controller: atividadeFisicaController,
              decoration: const InputDecoration(labelText: 'Atividade Física')),
          TextField(controller: escolaridadeController,
              decoration: const InputDecoration(labelText: 'Escolaridade')),
          TextField(controller: estadoCivilController,
              decoration: const InputDecoration(labelText: 'Estado Civil')),
          TextField(controller: filhosController,
              decoration: const InputDecoration(labelText: 'Filhos')),
          TextField(controller: irmaosController,
              decoration: const InputDecoration(labelText: 'Irmãos')),
          TextField(controller: filhaAdotivaController,
              decoration: const InputDecoration(labelText: 'Filha Adotiva')),
          TextField(controller: gemeosController,
              decoration: const InputDecoration(labelText: 'Gêmeos na Família')),
          TextField(controller: qualidadesController,
              decoration: const InputDecoration(labelText: 'Qualidades Pessoais'), maxLines: 3),
        ]),



        buildSection("Histórico de Saúde Pessoal", [
          TextField(controller: historicoSaudeAudicaoController,
              decoration: const InputDecoration(labelText: 'Saúde Auditiva')),
          TextField(controller: historicoSaudeVisaoController,
              decoration: const InputDecoration(labelText: 'Saúde Visual')),
          TextField(controller: historicoSaudeAlergiaController,
              decoration: const InputDecoration(labelText: 'Alergias')),
          TextField(controller: historicoSaudeAsmaController,
              decoration: const InputDecoration(labelText: 'Asma')),
          TextField(controller: historicoSaudeFumanteController,
              decoration: const InputDecoration(labelText: 'Fumante')),
          TextField(controller: historicoSaudeDrogasController,
              decoration: const InputDecoration(labelText: 'Uso de Drogas')),
          TextField(controller: historicoDoadoraEpilepsiaController, // General historicoDoadora from your list mapped to Epilepsy
              decoration: const InputDecoration(labelText: 'Histórico de Epilepsia (Doadora)')),
          TextField(controller: historicoDoadoraHipertensaoController,
              decoration: const InputDecoration(labelText: 'Hipertensão (Doadora)')),
          TextField(controller: historicoDoadoraDiabetesMellitusController,
              decoration: const InputDecoration(labelText: 'Diabetes Mellitus (Doadora)')),
          TextField(controller: historicoDoadoraDeficienciaFisicaController,
              decoration: const InputDecoration(labelText: 'Deficiência Física (Doadora)')),
          TextField(controller: historicoDoadoraDoencasGeneticasController,
              decoration: const InputDecoration(labelText: 'Doenças Genéticas (Doadora)')),
          TextField(controller: historicoDoadorasNeoplasiasController,
              decoration: const InputDecoration(labelText: 'Neoplasias (Doadora)')),
          TextField(controller: historicoDoadoraLabioLeporinoController,
              decoration: const InputDecoration(labelText: 'Lábio Leporino (Doadora)')),
          TextField(controller: historicoDoadoraEspinhaBifidaController,
              decoration: const InputDecoration(labelText: 'Espinha Bífida (Doadora)')),
          TextField(controller: historicoDoadoraDeficienciaMentalController,
              decoration: const InputDecoration(labelText: 'Deficiência Mental (Doadora)')),
          TextField(controller: historicoDoadoraMalFormacaoCardicaController,
              decoration: const InputDecoration(labelText: 'Malformação Cardíaca (Doadora)')),
          TextField(controller: observacaoController,
              decoration: const InputDecoration(labelText: 'Observações Gerais de Saúde'), maxLines: 3),
        ]),



        buildSection("Histórico Familiar de Doenças", [

          TextField(controller: historicoFamiliarAutismoController,
              decoration: const InputDecoration(labelText: 'Autismo na Família')),
          TextField(controller: historicoFamiliarDepressaoController,
              decoration: const InputDecoration(labelText: 'Depressão na Família')),
          TextField(controller: historicoFamiliarEsquizofreniaController,
              decoration: const InputDecoration(labelText: 'Esquizofrenia na Família')),
          TextField(controller: historicoFamiliarAnemiaFalciformeController,
              decoration: const InputDecoration(labelText: 'Anemia Falciforme na Família')),
          TextField(controller: historicoFamiliarTalassemiaController,
              decoration: const InputDecoration(labelText: 'Talassemia na Família')),
          TextField(controller: historicoFamiliarFibroseCisticaController,
              decoration: const InputDecoration(labelText: 'Fibrose Cística na Família')),
          TextField(controller: historicoFamiliarDiabetesMelittusController,
              decoration: const InputDecoration(labelText: 'Diabetes Mellitus na Família')),
          TextField(controller: historicoFamiliarEpilepsiaController,
              decoration: const InputDecoration(labelText: 'Epilepsia na Família')),
          TextField(controller: historicoFamiliarHipertensaoController,
              decoration: const InputDecoration(labelText: 'Hipertensão na Família')),
          TextField(controller: historicoFamiliarDistrofiaMuscularController,
              decoration: const InputDecoration(labelText: 'Distrofia Muscular na Família')),
          TextField(controller: historicoFamiliarAtrofiaMuscularController,
              decoration: const InputDecoration(labelText: 'Atrofia Muscular na Família')),
          TextField(controller: historicoFamiliarDoencaIsquemicaController,
              decoration: const InputDecoration(labelText: 'Doença Isquêmica na Família')),
          TextField(controller: historicoFamiliarNeoplasiaController,
              decoration: const InputDecoration(labelText: 'Neoplasia na Família')),
          TextField(controller: historicoFamiliarDeficienciaFisicaController,
              decoration: const InputDecoration(labelText: 'Deficiência Física na Família')),
          TextField(controller: historicoFamiliarDeficienciaMentalController,
              decoration: const InputDecoration(labelText: 'Deficiência Mental na Família')),
        ]),


        buildSection("Informações Adicionais e Administrativas", [
          TextField(controller: examesController,
              decoration: const InputDecoration(labelText: 'Exames Realizados'), maxLines: 3),
          TextField(controller: medicoAssistenteController,
              decoration: const InputDecoration(labelText: 'Médico Assistente')),
          TextField(controller: motivoController,
              decoration: const InputDecoration(labelText: 'Motivo da Doação'), maxLines: 2),
          TextField(controller: declaroVeracidadeController,
              decoration: const InputDecoration(labelText: 'Declaração de Veracidade'), maxLines: 3),
          TextField(controller: assinaturaController,
              decoration: const InputDecoration(labelText: 'Assinatura')),
          TextField(controller: ovulosController,
              decoration: const InputDecoration(labelText: 'Número de Óvulos Coletados')),
        ]),

            const SizedBox(height: 24),

            if (isSaving) const CircularProgressIndicator() else Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text('Tem certeza que deseja deletar esta doadora?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Deletar')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await deleteDoadora();
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.white,),
                  label: const Text('Deletar', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                Row(
                  children: [

                    ElevatedButton.icon(
                      onPressed: () {
                        generateDoadoraPdf(widget.doadora);
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Gerar PDF'),
                    ),
                    const SizedBox(width: 10,),
                    ElevatedButton.icon(
                      onPressed: saveChanges,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}