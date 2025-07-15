import 'package:flutter/material.dart';
import 'package:projeto_sonhar_mais/modules/pareamento/models/donor.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Import for Timer
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Firestore

import '../../../common/widgets/app_text_field.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';

import '../../banco_ovulos/pages/models/ovulos_models.dart';
import '../../banco_ovulos/pages/models/reserva_models.dart';
import '../../receptoras/pages/receptora_list_page.dart';
import '../models/matching_results.dart';
import '../widgets/doadora_match_card.dart';
import '../widgets/paring_pdf.dart';
// ASSUMINDO: ReceptoraCard widget está em lib/modules/matching/widgets/receptora_card.dart
import '../widgets/receptora_card.dart';


// --- IMPORTS PARA FUNCIONALIDADE DE RESERVA ---
import '../../banco_ovulos/pages/service/ovulo_service.dart';
import '../../banco_ovulos/pages/service/reserva_service.dart';
import '../../banco_ovulos/pages/service/receptora_service.dart';


class PairingScreen extends StatefulWidget {
  const PairingScreen({Key? key}) : super(key: key);

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Receptora> _searchResults = []; // Corrigido para List<Receptora>
  Receptora? _selectedReceiver;       // Corrigido para Receptora?
  List<MatchingResult> _compatibleDonors = [];
  bool _isLoadingSearch = false;
  bool _isLoadingMatching = false;
  String? _searchError;
  String? _matchingError;
  Timer? _debounce;
  bool _isGeneratingPdf = false;

  final OvoService _ovoService = OvoService();
  final ReservaService _reservaService = ReservaService();
  final ReceptoraService _receptoraService = ReceptoraService();

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchReceiver();
    });
  }

  Future<void> _searchReceiver() async {
    setState(() {
      _isLoadingSearch = true;
      _searchError = null;
      _searchResults = [];
      _selectedReceiver = null;
      _compatibleDonors = [];
    });

    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isLoadingSearch = false;
      });
      return;
    }

    try {
      // Assumindo _receptoraService.getReceptoras retorna Stream<List<Receptora>>
      final results = await _receptoraService.getReceptoras(searchName: query).first;
      setState(() {
        _searchResults = results; // Corretamente atribuído List<Receptora>
        _isLoadingSearch = false;
        if (results.isEmpty) {
          _searchError = 'Nenhuma receptora encontrada com este nome.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingSearch = false;
        _searchError = 'Erro ao pesquisar: $e';
        print('Erro ao pesquisar receptora: $e');
      });
    }
  }

  // Tipo do parâmetro corrigido para Receptora
  Future<void> _selectReceiver(Receptora receiver) async {
    setState(() {
      _selectedReceiver = receiver;
      _searchResults = []; // Limpa os resultados da pesquisa
      _isLoadingMatching = true;
      _matchingError = null;
      _compatibleDonors = [];
    });

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      // Assumindo getCompatibleDonors retorna List<MatchingResult>
      final compatibleDonors = await firestoreService.getCompatibleDonors(
        receiverId: receiver.id, // receiver é Receptora
      );

      setState(() {
        _compatibleDonors = compatibleDonors;
        _isLoadingMatching = false;
        if (compatibleDonors.isEmpty) {
          _matchingError = 'Nenhuma doadora compatível encontrada.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingMatching = false;
        _matchingError = 'Erro ao buscar compatibilidade: $e';
        print('Erro no matching: $e');
      });
    }
  }

  // --- DEFINIÇÃO CORRETA: Método _showDonorDetails ---
  void _showDonorDetails(MatchingResult donorMatch) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('${donorMatch.donorName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (donorMatch.donorPhotoUrl.isNotEmpty)
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(donorMatch.donorPhotoUrl),
                    ),
                  ),
                const SizedBox(height: 16),
                Text('ID: ${donorMatch.donorId}'),
                Text('Óvulos Disponíveis: ${donorMatch.eggCount}'),
                Text('Compatibilidade: ${donorMatch.finalCompatibilityPercentage.toStringAsFixed(0)}%'),
                const Divider(),
                Text('Fenótipos e Outros Detalhes:'),
                if (donorMatch.donorDetails['corCabelo1'] != null)
                  Text('Cor do Cabelo: ${donorMatch.donorDetails['corCabelo1']}'),
                if (donorMatch.donorDetails['corOlhos1'] != null)
                  Text('Cor dos Olhos: ${donorMatch.donorDetails['corOlhos1']}'),
                if (donorMatch.donorDetails['raca1'] != null)
                  Text('Raça: ${donorMatch.donorDetails['raca1']}'),
                if (donorMatch.donorDetails['altura1'] != null)
                  Text('Altura: ${donorMatch.donorDetails['altura1']} m'),
                if (donorMatch.donorDetails['tipoSanguineo1'] != null)
                  Text('Tipo Sanguíneo: ${donorMatch.donorDetails['tipoSanguineo1']}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Fechar'),
            ),
            // --- BOTÃO: Reservar Óvulos ---
            // Só mostra se uma receptora estiver selecionada e a doadora tiver óvulos disponíveis
            if (_selectedReceiver != null && donorMatch.eggCount > 0)
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColors.secondary),
                  foregroundColor: MaterialStateProperty.all<Color>(AppColors.background),
                ),
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // Fecha o diálogo de detalhes da doadora

                  // Busca o objeto Ovo (lote de óvulos) completo para esta doadora
                  // OvoService.getOvosByDoadoraId retorna Stream<List<Ovo>>
                  final ovosForDonor = await _ovoService.getOvosByDoadoraId(donorMatch.donorId).first;

                  if (ovosForDonor.isNotEmpty) {
                    // Chama o método _handleReserve com o primeiro Ovo encontrado e a Receptora selecionada
                    await _handleReserve(ovosForDonor.first, initialReceptora: _selectedReceiver!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nenhum lote de óvulos encontrado para esta doadora.')),
                    );
                  }
                },
                child: const Text('Reservar Óvulos'),
              ),
            // --- Botão para Gerar PDF (existente) ---
            StatefulBuilder(
              builder: (context, setInnerState) {
                return TextButton(
                  onPressed: _isGeneratingPdf
                      ? null
                      : () async {
                    if (_selectedReceiver == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecione uma receptora antes de gerar o PDF.')),
                      );
                      return;
                    }

                    setInnerState(() {
                      _isGeneratingPdf = true;
                    });

                    try {
                      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                      // getDonorById deve retornar seu modelo Doadora
                      final Donor? fullDonor = await firestoreService.getDonorById(donorMatch.donorId);

                      if (fullDonor != null) {
                        await generateDonorMatchPdf(
                          fullDonor,
                          _selectedReceiver!, // _selectedReceiver é Receptora
                          donorMatch.finalCompatibilityPercentage,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('PDF gerado com sucesso!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erro: Não foi possível carregar os dados completos da doadora.')),
                        );
                      }
                    } catch (e) {
                      print('Erro ao gerar PDF: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao gerar PDF: $e')),
                      );
                    } finally {
                      setInnerState(() {
                        _isGeneratingPdf = false;
                      });
                    }
                  },
                  child: _isGeneratingPdf
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                      : const Text('Gerar PDF'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- DEFINIÇÃO CORRETA: Método _handleReserve (copiado/adaptado do OvumBankScreen) ---
  Future<void> _handleReserve(Ovo ovo, {required Receptora initialReceptora}) async {
    TextEditingController receptoraSearchController = TextEditingController(text: initialReceptora.nomeCompleto);
    TextEditingController quantidadeReservaController = TextEditingController();
    Receptora? selectedReceptora = initialReceptora;
    final _formKey = GlobalKey<FormState>();

    final String ovoIdDisplay = ovo.id.length > 8 ? '${ovo.id.substring(0, 8)}...' : ovo.id;
    final String doadoraIdDisplay = ovo.doadoraId.length > 8 ? '${ovo.doadoraId.substring(0, 8)}...' : ovo.doadoraId;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Reservar Óvulo(s)'),
            content: SizedBox(
              width: 500,
              height: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Você está prestes a reservar óvulo(s) do lote $ovoIdDisplay da doadora $doadoraIdDisplay. Lote tem ${ovo.quantidade} óvulo(s) disponíveis.'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: quantidadeReservaController,
                      decoration: InputDecoration(
                        labelText: 'Quantidade a Reservar (Máx: ${ovo.quantidade})',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira a quantidade.';
                        }
                        final int? quantidade = int.tryParse(value);
                        if (quantidade == null || quantidade <= 0 || quantidade > ovo.quantidade) {
                          return 'Quantidade inválida ou excede o disponível.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: receptoraSearchController,
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar Receptora',
                        hintText: 'Digite o nome da receptora',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          if (selectedReceptora != null && value != selectedReceptora!.nomeCompleto) {
                            selectedReceptora = null;
                          }
                        });
                      },
                      validator: (value) {
                        if (selectedReceptora == null || (selectedReceptora?.nomeCompleto != value && value!.isNotEmpty)) {
                          return 'Por favor, selecione uma receptora válida da lista.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: StreamBuilder<List<Receptora>>(
                        stream: _receptoraService.getReceptoras(searchName: receptoraSearchController.text),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Erro ao carregar receptoras: ${snapshot.error}'));
                          }
                          final receptoras = snapshot.data ?? [];

                          if (receptoraSearchController.text.isEmpty) {
                            return const Center(child: Text('Digite para pesquisar receptoras.'));
                          }

                          if (receptoras.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('Nenhuma receptora encontrada.', style: TextStyle(color: Colors.red)),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: receptoras.length,
                            itemBuilder: (context, index) {
                              final receptora = receptoras[index];
                              return ListTile(
                                title: Text(receptora.nomeCompleto ?? 'Receptora sem nome'),
                                onTap: () {
                                  setDialogState(() {
                                    selectedReceptora = receptora;
                                    receptoraSearchController.text = receptora.nomeCompleto ?? '';
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                tileColor: selectedReceptora?.id == receptora.id ? AppColors.primary.withOpacity(0.2) : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (selectedReceptora != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Receptora Selecionada: ${selectedReceptora!.nomeCompleto}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate() && selectedReceptora != null) {
                    try {
                      final int quantidadeAReservar = int.parse(quantidadeReservaController.text);

                      final String reservaId = FirebaseFirestore.instance.collection('reservas').doc().id;

                      final newReserva = Reserva(
                        id: reservaId,
                        ovosIds: [ovo.id],
                        doadoraId: ovo.doadoraId,
                        receptoraId: selectedReceptora!.id,
                        dataReserva: DateTime.now(),
                        status: 'ativa',
                        observacoes: 'Reservado $quantidadeAReservar óvulo(s) do lote ${ovo.id.substring(0,8)}.',
                      );

                      await _reservaService.createReserva(newReserva, quantidadeAReservar);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sucesso! $quantidadeAReservar óvulo(s) do lote $ovoIdDisplay reservados para ${selectedReceptora!.nomeCompleto}!')),
                      );
                      Navigator.of(context).pop();
                    } on FirebaseException catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro na reserva (Firebase): ${e.message ?? 'Erro desconhecido'}')),
                      );
                    } catch (e, stacktrace) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro inesperado na reserva: ${e.toString()}')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, selecione uma receptora e uma quantidade válida antes de confirmar.')),
                    );
                  }
                },
                child: const Text('Confirmar Reserva'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- O MÉTODO BUILD ESTAVA AQUI DENTRO DO _handleReserve. AGORA ESTÁ NO LUGAR CERTO ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pareamento'),
        backgroundColor: Colors.white,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Buscar Receptora', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 16),
                  AppTextField(
                    labelText: 'Nome Completo da Receptora',
                    controller: _searchController,
                    keyboardType: TextInputType.text,
                    onChanged: _onSearchChanged,
                    suffixIcon: _isLoadingSearch
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchReceiver,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingSearch && _searchResults.isEmpty && _selectedReceiver == null)
                    const Center(child: CircularProgressIndicator()),
                  if (_searchError != null)
                    Text(_searchError!, style: TextStyle(color: AppColors.error)),
                  if (_searchResults.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final receptora = _searchResults[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(receptora.nomeCompleto!),
                              subtitle: Text(receptora.rawData['tipoSanguineo1'] ?? 'Sem tipo sanguíneo'),
                              onTap: () => _selectReceiver(receptora),
                            ),
                          );
                        },
                      ),
                    ),
                  if (_selectedReceiver != null)
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: double.infinity,
                          child: ReceiverInfoCard( // Instanciação do widget
                            name: _selectedReceiver!.nomeCompleto!,
                            photoUrl: _selectedReceiver!.fotoPerfil, // Usando fotoPerfil de Receptora
                            receiverDetails: _selectedReceiver!.rawData,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Doadoras Mais Compatíveis', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 16),
                  if (_selectedReceiver == null)
                    Center(
                      child: Text(
                        'Selecione uma receptora para ver as doadoras compatíveis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimary.withOpacity(0.6)),
                      ),
                    ),
                  if (_isLoadingMatching)
                    const Center(child: CircularProgressIndicator()),
                  if (_matchingError != null)
                    Text(_matchingError!, style: TextStyle(color: AppColors.error)),
                  if (_compatibleDonors.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _compatibleDonors.length,
                        itemBuilder: (context, index) {
                          final match = _compatibleDonors[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: DonorMatchCard(
                              match: match,
                              onTap: () {
                                _showDonorDetails(match); // Abre o diálogo de detalhes da doadora
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}