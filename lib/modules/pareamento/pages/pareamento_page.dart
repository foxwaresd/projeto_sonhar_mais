import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Importe para usar Timer para debounce

import '../../../common/widgets/app_text_field.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';
import '../models/matching_results.dart';
import '../models/reciver.dart';
import '../widgets/doadora_match_card.dart';
import '../widgets/paring_pdf.dart';
import '../widgets/receptora_card.dart';
import '../models/donor.dart';


class PairingScreen extends StatefulWidget {
  const PairingScreen({Key? key}) : super(key: key);

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Receiver> _searchResults = [];
  Receiver? _selectedReceiver;
  List<MatchingResult> _compatibleDonors = [];
  bool _isLoadingSearch = false;
  bool _isLoadingMatching = false;
  String? _searchError;
  String? _matchingError;
  Timer? _debounce;
  bool _isGeneratingPdf = false; // Novo estado para o indicador de PDF

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
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final results = await firestoreService.searchReceiversByName(query);
      setState(() {
        _searchResults = results.cast<Receiver>();
        _isLoadingSearch = false;
        if (results.isEmpty) {
          _searchError = 'Nenhuma receptora encontrada com este nome.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingSearch = false;
        _searchError = 'Erro ao pesquisar: $e';
      });
    }
  }

  Future<void> _selectReceiver(Receiver receiver) async {
    setState(() {
      _selectedReceiver = receiver;
      _searchResults = [];
      _isLoadingMatching = true;
      _matchingError = null;
      _compatibleDonors = [];
    });

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      final compatibleDonors = await firestoreService.getCompatibleDonors(
        receiverId: receiver.id,
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

  void _showDonorDetails(MatchingResult donorMatch) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Usar dialogContext para o Navigator.of(dialogContext).pop()
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
                Text('Compatibilidade: ${donorMatch.finalCompatibilityPercentage.toStringAsFixed(0)}%', ),
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
                // Adicione mais campos conforme desejar exibir
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
            // --- Botão para Gerar PDF ---
            StatefulBuilder(
              builder: (context, setInnerState) {
                return TextButton(
                  onPressed: _isGeneratingPdf
                      ? null // Desabilita o botão enquanto estiver gerando
                      : () async {
                    if (_selectedReceiver == null) {
                      // Caso não haja receptora selecionada, embora não deva acontecer aqui
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Selecione uma receptora antes de gerar o PDF.')),
                      );
                      return;
                    }

                    setInnerState(() {
                      _isGeneratingPdf = true; // Inicia o loading
                    });

                    try {
                      // Busca a doadora completa a partir do ID
                      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                      final Donor? fullDonor = await firestoreService.getDonorById(donorMatch.donorId);

                      if (fullDonor != null) {
                        await generateDonorMatchPdf(
                          fullDonor,
                          _selectedReceiver!, // _selectedReceiver não será nulo aqui
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
                        _isGeneratingPdf = false; // Finaliza o loading
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
                          final receiver = _searchResults[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(receiver.nomeCompleto),
                              subtitle: Text(receiver.rawData['tipoSanguineo1'] ?? 'Sem tipo sanguíneo'),
                              onTap: () => _selectReceiver(receiver),
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
                          child: ReceiverInfoCard(
                            name: _selectedReceiver!.nomeCompleto,
                            photoUrl: _selectedReceiver!.fotoPerfilUrl,
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
                              onTap: () => _showDonorDetails(match),
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