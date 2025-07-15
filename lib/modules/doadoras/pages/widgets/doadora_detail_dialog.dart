import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:projeto_sonhar_mais/modules/banco_ovulos/pages/service/doadora_service.dart';
import 'package:projeto_sonhar_mais/modules/banco_ovulos/pages/service/ovulo_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../banco_ovulos/pages/models/ovulos_models.dart';
import '../doadora_list_page.dart';
import 'doadora_pdf_generator.dart';



class DoadoraDetailDialog extends StatefulWidget {
  final Doadora doadora;
  const DoadoraDetailDialog({required this.doadora, Key? key}) : super(key: key);

  @override
  State<DoadoraDetailDialog> createState() => _DoadoraDetailDialogState();
}

class _DoadoraDetailDialogState extends State<DoadoraDetailDialog> {
  // === DECLARAÇÃO DOS CONTROLLERS ===
  late TextEditingController prontuarioEletronicoController;
  late TextEditingController nomeController;
  late TextEditingController observacaoController;
  late TextEditingController idadeController;
  late TextEditingController pesoController;
  late TextEditingController alturaController;
  late TextEditingController tipoSanguineoController;
  late TextEditingController olhosController;
  late TextEditingController cabeloCorController;
  late TextEditingController cabeloTexturaController;
  late TextEditingController racaController;
  late TextEditingController signoController;
  late TextEditingController fitzpatrickController;
  late TextEditingController formatoRostoController;
  late TextEditingController profissaoController;
  late TextEditingController hobbyController;
  late TextEditingController atividadeFisicaController;
  late TextEditingController escolaridadeController;
  late TextEditingController estadoCivilController;
  late TextEditingController filhosController;
  late TextEditingController irmaosController;
  late TextEditingController filhaAdotivaController;
  late TextEditingController gemeosController;
  late TextEditingController qualidadesController;

  // Histórico de Saúde Pessoal
  late TextEditingController historicoSaudeAudicaoController;
  late TextEditingController historicoSaudeVisaoController;
  late TextEditingController historicoSaudeAlergiaController;
  late TextEditingController historicoSaudeAsmaController;
  late TextEditingController historicoSaudeDoencaCronicaController;
  late TextEditingController historicoSaudeFumanteController;
  late TextEditingController historicoSaudeDrogasController;
  late TextEditingController saudeAlcoolController;

  // Histórico Familiar
  late TextEditingController historicoFamiliarAutismoController;
  late TextEditingController historicoFamiliarDepressaoController;
  late TextEditingController historicoFamiliarEsquizofreniaController;
  late TextEditingController historicoFamiliarAnemiaFalciformeController;
  late TextEditingController historicoFamiliarTalassemiaController;
  late TextEditingController historicoFamiliarFibroseCisticaController;
  late TextEditingController historicoFamiliarDiabetesMelittusController;
  late TextEditingController historicoFamiliarEpilepsiaController;
  late TextEditingController historicoFamiliarHipertensaoController;
  late TextEditingController historicoFamiliarDistrofiaMuscularController;
  late TextEditingController historicoFamiliarAtrofiaMuscularController;
  late TextEditingController historicoFamiliarDoencaIsquemicaController;
  late TextEditingController historicoFamiliarNeoplasiaController;
  late TextEditingController historicoFamiliarDeficienciaFisicaController;
  late TextEditingController historicoFamiliarDeficienciaMentalController;
  late TextEditingController historicoFamiliarDoencaGeneticaController;

  // Histórico Doadora Específico
  late TextEditingController historicoDoadoraEpilepsiaController;
  late TextEditingController historicoDoadoraHipertensaoController;
  late TextEditingController historicoDoadoraDiabetesMellitusController;
  late TextEditingController historicoDoadoraDeficienciaFisicaController;
  late TextEditingController historicoDoadoraDoencasGeneticasController;
  late TextEditingController historicoDoadorasNeoplasiasController;
  late TextEditingController historicoDoadoraLabioLeporinoController;
  late TextEditingController historicoDoadoraEspinhaBifidaController;
  late TextEditingController historicoDoadoraDeficienciaMentalController;
  late TextEditingController historicoDoadoraMalFormacaoCardicaController;
  late TextEditingController historicoDoadoraGeralController;

  late TextEditingController examesController;
  // Novos campos
  late TextEditingController assinaturaController;
  late TextEditingController emailController;
  late TextEditingController telefoneController;
  late TextEditingController cpfController;
  late TextEditingController rgController;
  late TextEditingController cepController;
  late TextEditingController enderecoController;
  late TextEditingController cidadeController;
  late TextEditingController estadoController;
  late TextEditingController dobController;
  late TextEditingController medicoAssistenteController;
  late TextEditingController motivoController;
  late TextEditingController declaroVeracidadeController;
  late TextEditingController caracteristicas1Controller;
  late TextEditingController idiomaController;
  // NOTA: 'ovulosController' não é mais para a quantidade editável diretamente
  // da Doadora, mas pode ser usado para exibir o total atual ou um campo auxiliar
  // O importante é que a adição de novos lotes ocorra via os novos controladores abaixo.
  late TextEditingController imcController;

  // NOVO: Controllers para adicionar um NOVO lote de óvulos
  late TextEditingController newOvumQuantityController;
  late TextEditingController newOvumIncubatorController;
  late TextEditingController newOvumVaretaController;

  // Instâncias dos serviços
  final OvoService _ovoService = OvoService();
  final DoadoraService _doadoraService = DoadoraService();

  String? newPhotoUrl;
  bool isSaving = false;
  bool _isProcessingFace = false;

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
    // === INICIALIZAÇÃO DE TODOS OS CONTROLLERS ===
    prontuarioEletronicoController = TextEditingController(text: widget.doadora.prontuarioEletronico);
    nomeController = TextEditingController(text: widget.doadora.nome);
    observacaoController = TextEditingController(text: widget.doadora.observacao);
    idadeController = TextEditingController(text: widget.doadora.idade);
    pesoController = TextEditingController(text: widget.doadora.peso);
    alturaController = TextEditingController(text: widget.doadora.altura);
    tipoSanguineoController = TextEditingController(text: widget.doadora.tipoSanguineo);
    olhosController = TextEditingController(text: widget.doadora.olhos);
    cabeloCorController = TextEditingController(text: widget.doadora.cabeloCor);
    cabeloTexturaController = TextEditingController(text: widget.doadora.cabeloTextura);
    racaController = TextEditingController(text: widget.doadora.raca);
    signoController = TextEditingController(text: widget.doadora.signo);
    fitzpatrickController = TextEditingController(text: widget.doadora.fitzpatrick);
    formatoRostoController = TextEditingController(text: widget.doadora.formatoRosto);
    profissaoController = TextEditingController(text: widget.doadora.profissao);
    hobbyController = TextEditingController(text: widget.doadora.hobby);
    atividadeFisicaController = TextEditingController(text: widget.doadora.atividadeFisica);
    escolaridadeController = TextEditingController(text: widget.doadora.escolaridade);
    estadoCivilController = TextEditingController(text: widget.doadora.estadoCivil);
    filhosController = TextEditingController(text: widget.doadora.filhos);
    irmaosController = TextEditingController(text: widget.doadora.irmaos);
    filhaAdotivaController = TextEditingController(text: widget.doadora.filhaAdotiva);
    gemeosController = TextEditingController(text: widget.doadora.gemeos);
    qualidadesController = TextEditingController(text: widget.doadora.qualidades);

    historicoSaudeAudicaoController = TextEditingController(text: widget.doadora.historicoSaudeAudicao);
    historicoSaudeVisaoController = TextEditingController(text: widget.doadora.historicoSaudeVisao);
    historicoSaudeAlergiaController = TextEditingController(text: widget.doadora.historicoSaudeAlergia);
    historicoSaudeAsmaController = TextEditingController(text: widget.doadora.historicoSaudeAsma);
    historicoSaudeDoencaCronicaController = TextEditingController(text: widget.doadora.historicoSaudeDoencaCronica);
    historicoSaudeFumanteController = TextEditingController(text: widget.doadora.historicoSaudeFumante);
    historicoSaudeDrogasController = TextEditingController(text: widget.doadora.historicoSaudeDrogas);
    saudeAlcoolController = TextEditingController(text: widget.doadora.saudeAlcool);

    historicoFamiliarAutismoController = TextEditingController(text: widget.doadora.historicoFamiliarAutismo);
    historicoFamiliarDepressaoController = TextEditingController(text: widget.doadora.historicoFamiliarDepressao);
    historicoFamiliarEsquizofreniaController = TextEditingController(text: widget.doadora.historicoFamiliarEsquizofrenia);
    historicoFamiliarAnemiaFalciformeController = TextEditingController(text: widget.doadora.historicoFamiliarAnemiaFalciforme);
    historicoFamiliarTalassemiaController = TextEditingController(text: widget.doadora.historicoFamiliarTalassemia);
    historicoFamiliarFibroseCisticaController = TextEditingController(text: widget.doadora.historicoFamiliarFibroseCistica);
    historicoFamiliarDiabetesMelittusController = TextEditingController(text: widget.doadora.historicoFamiliarDiabetesMelittus);
    historicoFamiliarEpilepsiaController = TextEditingController(text: widget.doadora.historicoFamiliarEpilepsia);
    historicoFamiliarHipertensaoController = TextEditingController(text: widget.doadora.historicoFamiliarHipertensao);
    historicoFamiliarDistrofiaMuscularController = TextEditingController(text: widget.doadora.historicoFamiliarDistrofiaMuscular);
    historicoFamiliarAtrofiaMuscularController = TextEditingController(text: widget.doadora.historicoFamiliarAtrofiaMuscular);
    historicoFamiliarDoencaIsquemicaController = TextEditingController(text: widget.doadora.historicoFamiliarDoencaIsquemica);
    historicoFamiliarNeoplasiaController = TextEditingController(text: widget.doadora.historicoFamiliarNeoplasia);
    historicoFamiliarDeficienciaFisicaController = TextEditingController(text: widget.doadora.historicoFamiliarDeficienciaFisica);
    historicoFamiliarDeficienciaMentalController = TextEditingController(text: widget.doadora.historicoFamiliarDeficienciaMental);
    historicoFamiliarDoencaGeneticaController = TextEditingController(text: widget.doadora.historicoFamiliarDoencaGenetica);

    historicoDoadoraEpilepsiaController = TextEditingController(text: widget.doadora.historicoDoadoraEpilepsia);
    historicoDoadoraHipertensaoController = TextEditingController(text: widget.doadora.historicoDoadoraHipertensao);
    historicoDoadoraDiabetesMellitusController = TextEditingController(text: widget.doadora.historicoDoadoraDiabetesMellitus);
    historicoDoadoraDeficienciaFisicaController = TextEditingController(text: widget.doadora.historicoDoadoraDeficienciaFisica);
    historicoDoadoraDeficienciaMentalController = TextEditingController(text: widget.doadora.historicoDoadoraDeficienciaMental);
    historicoDoadoraDoencasGeneticasController = TextEditingController(text: widget.doadora.historicoDoadoraDoencasGeneticas);
    historicoDoadoraEspinhaBifidaController = TextEditingController(text: widget.doadora.historicoDoadoraEspinhaBifida);
    historicoDoadoraHipertensaoController = TextEditingController(text: widget.doadora.historicoDoadoraHipertensao);
    historicoDoadoraLabioLeporinoController = TextEditingController(text: widget.doadora.historicoDoadoraLabioLeporino);
    historicoDoadoraMalFormacaoCardicaController = TextEditingController(text: widget.doadora.historicoDoadoraMalFormacaoCardica);
    historicoDoadorasNeoplasiasController = TextEditingController(text: widget.doadora.historicoDoadorasNeoplasias);
    historicoDoadoraGeralController = TextEditingController(text: widget.doadora.historicoDoadora);

    examesController = TextEditingController(text: widget.doadora.exames.join('\n'));
    assinaturaController = TextEditingController(text: widget.doadora.assinatura);
    emailController = TextEditingController(text: widget.doadora.email);
    telefoneController = TextEditingController(text: widget.doadora.telefone);
    cpfController = TextEditingController(text: widget.doadora.cpf);
    rgController = TextEditingController(text: widget.doadora.rg);
    cepController = TextEditingController(text: widget.doadora.cep);
    enderecoController = TextEditingController(text: widget.doadora.endereco);
    cidadeController = TextEditingController(text: widget.doadora.cidade);
    estadoController = TextEditingController(text: widget.doadora.estado);
    dobController = TextEditingController(text: widget.doadora.dob);
    medicoAssistenteController = TextEditingController(text: widget.doadora.medicoAssistente);
    motivoController = TextEditingController(text: widget.doadora.motivo);
    declaroVeracidadeController = TextEditingController(text: widget.doadora.declaroVeracidade);
    caracteristicas1Controller = TextEditingController(text: widget.doadora.caracteristicas1);
    idiomaController = TextEditingController(text: widget.doadora.idioma);
    // REMOVIDO: ovulosController não é mais para edição direta da doadora.
    // Ele não será inicializado aqui se você o removeu da lista de late.
    imcController = TextEditingController(); // Inicializa vazio, será calculado

    // NOVO: Inicializa os controllers para adicionar Lotes de Óvulos
    newOvumQuantityController = TextEditingController();
    newOvumIncubatorController = TextEditingController();
    newOvumVaretaController = TextEditingController();

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
    // === DISCARD DE TODOS OS CONTROLLERS ===
    prontuarioEletronicoController.dispose();
    nomeController.dispose();
    observacaoController.dispose();
    idadeController.dispose();
    pesoController.removeListener(_calcularEAtualizarIMC);
    pesoController.dispose();
    alturaController.removeListener(_calcularEAtualizarIMC);
    alturaController.dispose();
    tipoSanguineoController.dispose();
    olhosController.dispose();
    cabeloCorController.dispose();
    cabeloTexturaController.dispose();
    racaController.dispose();
    signoController.dispose();
    fitzpatrickController.dispose();
    formatoRostoController.dispose();
    profissaoController.dispose();
    hobbyController.dispose();
    atividadeFisicaController.dispose();
    escolaridadeController.dispose();
    estadoCivilController.dispose();
    filhosController.dispose();
    irmaosController.dispose();
    filhaAdotivaController.dispose();
    gemeosController.dispose();
    qualidadesController.dispose();

    historicoSaudeAudicaoController.dispose();
    historicoSaudeVisaoController.dispose();
    historicoSaudeAlergiaController.dispose();
    historicoSaudeAsmaController.dispose();
    historicoSaudeDoencaCronicaController.dispose();
    historicoSaudeDrogasController.dispose();
    saudeAlcoolController.dispose();

    historicoFamiliarAutismoController.dispose();
    historicoFamiliarDepressaoController.dispose();
    historicoFamiliarEsquizofreniaController.dispose();
    historicoFamiliarAnemiaFalciformeController.dispose();
    historicoFamiliarTalassemiaController.dispose();
    historicoFamiliarFibroseCisticaController.dispose();
    historicoFamiliarDiabetesMelittusController.dispose();
    historicoFamiliarEpilepsiaController.dispose();
    historicoFamiliarHipertensaoController.dispose();
    historicoFamiliarDistrofiaMuscularController.dispose();
    historicoFamiliarAtrofiaMuscularController.dispose();
    historicoFamiliarDoencaIsquemicaController.dispose();
    historicoFamiliarNeoplasiaController.dispose();
    historicoFamiliarDeficienciaFisicaController.dispose();
    historicoFamiliarDeficienciaMentalController.dispose();
    historicoFamiliarDoencaGeneticaController.dispose();

    historicoDoadoraEpilepsiaController.dispose();
    historicoDoadoraHipertensaoController.dispose();
    historicoDoadoraDiabetesMellitusController.dispose();
    historicoDoadoraDeficienciaFisicaController.dispose();
    historicoDoadoraDoencasGeneticasController.dispose();
    historicoDoadoraEspinhaBifidaController.dispose();
    historicoDoadoraHipertensaoController.dispose();
    historicoDoadoraLabioLeporinoController.dispose();
    historicoDoadoraMalFormacaoCardicaController.dispose();
    historicoDoadorasNeoplasiasController.dispose();
    historicoDoadoraGeralController.dispose();

    examesController.dispose();
    assinaturaController.dispose();
    emailController.dispose();
    telefoneController.dispose();
    cpfController.dispose();
    rgController.dispose();
    cepController.dispose();
    enderecoController.dispose();
    cidadeController.dispose();
    estadoController.dispose();
    dobController.dispose();
    medicoAssistenteController.dispose();
    motivoController.dispose();
    declaroVeracidadeController.dispose();
    caracteristicas1Controller.dispose();
    idiomaController.dispose();
    // REMOVIDO: ovulosController.dispose();
    imcController.dispose();

    // NOVO: Dispose dos novos controllers
    newOvumQuantityController.dispose();
    newOvumIncubatorController.dispose();
    newOvumVaretaController.dispose();

    super.dispose();
  }

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

        final docRef = FirebaseFirestore.instance.collection('doadoras').doc(widget.doadora.id);
        await docRef.update({'faceEmbedding': faceEmbedding});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rosto escaneado e embedding salvo com sucesso!')),
        );
        Navigator.of(context).pop(true);
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
      double? peso = double.tryParse(pesoController.text.replaceAll(',', '.'));
      double? altura = double.tryParse(alturaController.text.replaceAll(',', '.'));

      if (peso != null && altura != null && peso > 0 && altura > 0) {
        double imc = peso / (altura * altura);
        setState(() {
          imcController.text = imc.toStringAsFixed(2);
        });
      } else {
        setState(() {
          imcController.text = '';
        });
      }
    } catch (e) {
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
          child: Stack(
            children: [
              Container(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close,color: AppColors.primary,),
                    onPressed: () {
                      Navigator.of(context).pop();
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

  // NOVO MÉTODO: Adicionar um novo lote de óvulos
  Future<void> _addNewOvumLot() async {
    final int quantidade = int.tryParse(newOvumQuantityController.text) ?? 0;
    final String incubadora = newOvumIncubatorController.text.trim();
    final String vareta = newOvumVaretaController.text.trim();

    if (quantidade <= 0 || incubadora.isEmpty || vareta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha a quantidade, incubadora e vareta para o novo lote.')),
      );
      return;
    }

    setState(() => isSaving = true);
    try {
      final String novoOvoId = FirebaseFirestore.instance.collection('ovos').doc().id;
      final newOvo = Ovo(
        id: novoOvoId,
        doadoraId: widget.doadora.id,
        quantidade: quantidade,
        status: 'disponivel',
        incubadora: incubadora,
        vareta: vareta,
        dataColeta: DateTime.now(),
      );

      await _ovoService.addOvo(newOvo);

      // Atualiza o campo 'quantidadeOvos' na doadora para refletir o novo total
      await _doadoraService.updateOvosDisponiveis(widget.doadora.id, quantidade);

      newOvumQuantityController.clear();
      newOvumIncubatorController.clear();
      newOvumVaretaController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Novo lote de óvulos adicionado com sucesso!')),
      );

      // Recarrega o dialog para mostrar a doadora atualizada (com o novo total de ovos)
      // e também para que a OvumBankScreen (se aberta) seja atualizada via stream.
      Navigator.of(context).pop(true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar lote de óvulos: $e')),
      );
      print('Erro ao adicionar lote de óvulos: $e');
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> saveChanges() async {
    setState(() => isSaving = true);
    try {
      final updatedDoadora = Doadora(
        id: widget.doadora.id,
        prontuarioEletronico: prontuarioEletronicoController.text,
        nome: nomeController.text,
        foto: newPhotoUrl ?? widget.doadora.foto,
        observacao: observacaoController.text,
        idade: idadeController.text,
        peso: pesoController.text,
        altura: alturaController.text,
        tipoSanguineo: tipoSanguineoController.text,
        olhos: olhosController.text,
        cabeloCor: cabeloCorController.text,
        cabeloTextura: cabeloTexturaController.text,
        raca: racaController.text,
        signo: signoController.text,
        fitzpatrick: fitzpatrickController.text,
        formatoRosto: formatoRostoController.text,
        profissao: profissaoController.text,
        hobby: hobbyController.text,
        atividadeFisica: atividadeFisicaController.text,
        escolaridade: escolaridadeController.text,
        estadoCivil: estadoCivilController.text,
        filhos: filhosController.text,
        irmaos: irmaosController.text,
        filhaAdotiva: filhaAdotivaController.text,
        gemeos: gemeosController.text,
        qualidades: qualidadesController.text,
        historicoSaudeAudicao: historicoSaudeAudicaoController.text,
        historicoSaudeVisao: historicoSaudeVisaoController.text,
        historicoSaudeAlergia: historicoSaudeAlergiaController.text,
        historicoSaudeAsma: historicoSaudeAsmaController.text,
        historicoSaudeDoencaCronica: historicoSaudeDoencaCronicaController.text,
        historicoSaudeFumante: historicoSaudeFumanteController.text,
        historicoSaudeDrogas: historicoSaudeDrogasController.text,
        saudeAlcool: saudeAlcoolController.text,
        faceEmbedding: widget.doadora.faceEmbedding,
        historicoFamiliarAutismo: historicoFamiliarAutismoController.text,
        historicoFamiliarDepressao: historicoFamiliarDepressaoController.text,
        historicoFamiliarEsquizofrenia: historicoFamiliarEsquizofreniaController.text,
        historicoFamiliarAnemiaFalciforme: historicoFamiliarAnemiaFalciformeController.text,
        historicoFamiliarTalassemia: historicoFamiliarTalassemiaController.text,
        historicoFamiliarFibroseCistica: historicoFamiliarFibroseCisticaController.text,
        historicoFamiliarDiabetesMelittus: historicoFamiliarDiabetesMelittusController.text,
        historicoFamiliarEpilepsia: historicoFamiliarEpilepsiaController.text,
        historicoFamiliarHipertensao: historicoFamiliarHipertensaoController.text,
        historicoFamiliarDistrofiaMuscular: historicoFamiliarDistrofiaMuscularController.text,
        historicoFamiliarAtrofiaMuscular: historicoFamiliarAtrofiaMuscularController.text,
        historicoFamiliarDoencaIsquemica: historicoFamiliarDoencaIsquemicaController.text,
        historicoFamiliarNeoplasia: historicoFamiliarNeoplasiaController.text,
        historicoFamiliarDeficienciaFisica: historicoFamiliarDeficienciaFisicaController.text,
        historicoFamiliarDeficienciaMental: historicoFamiliarDeficienciaMentalController.text,
        historicoFamiliarDoencaGenetica: historicoFamiliarDoencaGeneticaController.text,
        historicoDoadoraEpilepsia: historicoDoadoraEpilepsiaController.text,
        historicoDoadoraHipertensao: historicoDoadoraHipertensaoController.text,
        historicoDoadoraDiabetesMellitus: historicoDoadoraDiabetesMellitusController.text,
        historicoDoadoraDeficienciaFisica: historicoDoadoraDeficienciaFisicaController.text,
        historicoDoadoraDoencasGeneticas: historicoDoadoraDoencasGeneticasController.text,
        historicoDoadorasNeoplasias: historicoDoadorasNeoplasiasController.text,
        historicoDoadoraLabioLeporino: historicoDoadoraLabioLeporinoController.text,
        historicoDoadoraEspinhaBifida: historicoDoadoraEspinhaBifidaController.text,
        historicoDoadoraDeficienciaMental: historicoDoadoraDeficienciaMentalController.text,
        historicoDoadoraMalFormacaoCardica: historicoDoadoraMalFormacaoCardicaController.text,
        historicoDoadora: historicoDoadoraGeralController.text,
        exames: examesController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        status: _selectedStatus!,
        assinatura: assinaturaController.text,
        email: emailController.text,
        telefone: telefoneController.text,
        cpf: cpfController.text,
        rg: rgController.text,
        cep: cepController.text,
        endereco: enderecoController.text,
        cidade: cidadeController.text,
        estado: estadoController.text,
        dob: dobController.text,
        medicoAssistente: medicoAssistenteController.text,
        motivo: motivoController.text,
        declaroVeracidade: declaroVeracidadeController.text,
        caracteristicas1: caracteristicas1Controller.text,
        idioma: idiomaController.text,
        ovosDisponiveis: widget.doadora.ovosDisponiveis, // **IMPORTANTE: Mantém o valor existente. A alteração de ovosDisponiveis ocorre via _addNewOvumLot ou _handleReserve na OvumBankScreen.**
        rawData: widget.doadora.rawData,
      );

      await FirebaseFirestore.instance.collection('doadoras').doc(updatedDoadora.id).update(updatedDoadora.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doadora atualizada com sucesso!')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar alterações: $e')),
      );
      print('Erro ao salvar doadora: $e');
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    isExpanded: true,
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
            const SizedBox(height: 16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: pickNewPhoto,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Alterar Foto'),
                        ),
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
                const SizedBox(width: 20),
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
            const SizedBox(height: 16),


            // --- NOVA SEÇÃO: Gerenciamento de Lotes de Óvulos ---
            buildSection("Gerenciamento de Lotes de Óvulos", [
              Align( // Adicione Align para garantir o alinhamento do texto
                alignment: Alignment.centerLeft,
                child: Text('Óvulos Disponíveis (Total): ${widget.doadora.ovosDisponiveis}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),
              Align( // Adicione Align para garantir o alinhamento do texto
                alignment: Alignment.centerLeft,
                child: const Text('Adicionar Novo Lote de Óvulos:', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextField(
                controller: newOvumQuantityController,
                decoration: const InputDecoration(labelText: 'Quantidade de Óvulos (Novo Lote)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: newOvumIncubatorController,
                decoration: const InputDecoration(labelText: 'Incubadora'),
              ),
              TextField(
                controller: newOvumVaretaController,
                decoration: const InputDecoration(labelText: 'Vareta'),
              ),
              const SizedBox(height: 10),
              Align( // Adicione Align para o botão
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: _addNewOvumLot,
                  icon: const Icon(Icons.add_box),
                  label: const Text('Adicionar Lote de Óvulos', style: TextStyle(color: AppColors.background),),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), // Corrigido para AppColors.primary
                ),
              ),
            ]),

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
                controller: imcController,
                decoration: const InputDecoration(labelText: 'IMC'),
                readOnly: true,
                enabled: false,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
              TextField(controller: historicoDoadoraEpilepsiaController,
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
              // O campo de óvulos da doadora agora é apenas exibido na seção acima de "Gerenciamento de Lotes".
              // Este campo não é editável diretamente a partir da doadora, mas sim pela adição de lotes.
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