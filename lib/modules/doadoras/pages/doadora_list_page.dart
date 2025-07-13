

// Your Doadora class remains unchanged
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/filters.dart';
import 'widgets/doadora_detail_dialog.dart';

class Doadora {
  final String id;
  final String prontuarioEletronico;
  final String nome;
  final String foto;
  final String observacao;
  final String idade;
  final String peso;
  final String altura;
  final String tipoSanguineo;
  final String olhos;
  final String cabeloCor;
  final String cabeloTextura;
  final String raca;
  final String signo;
  // Renamed from escalaFitzpatric to fitzpatrick for direct access
  final String fitzpatrick;
  final String formatoRosto;
  final String profissao;
  final String hobby;
  final String atividadeFisica;
  final String escolaridade;
  final String estadoCivil;
  final String filhos;
  final String irmaos;
  // Renamed from filhoAdotivo to filhaAdotiva for direct access
  final String filhaAdotiva;
  // Renamed from gemeosNaFamilia to gemeos for direct access
  final String gemeos;
  final String qualidades;
  // Direct mapping for historicoSaude fields
  final String historicoSaudeAudicao;
  final String historicoSaudeVisao;
  final String historicoSaudeAlergia;
  final String historicoSaudeAsma;
  // Renamed from saudeCronica to historicoSaudeDoencaCronica for direct access
  final String historicoSaudeDoencaCronica;
  final String historicoSaudeFumante;
  final String historicoSaudeDrogas;
  final String saudeAlcool; // This one seems to be `saudeAlcool` in your definition
  final List<double>? faceEmbedding;
  // Direct mapping for historicoFamiliar fields
  final String historicoFamiliarAutismo;
  final String historicoFamiliarDepressao;
  final String historicoFamiliarEsquizofrenia;
  final String historicoFamiliarAnemiaFalciforme;
  final String historicoFamiliarTalassemia;
  final String historicoFamiliarFibroseCistica;
  final String historicoFamiliarDiabetesMelittus;
  final String historicoFamiliarEpilepsia;
  final String historicoFamiliarHipertensao;
  final String historicoFamiliarDistrofiaMuscular;
  final String historicoFamiliarAtrofiaMuscular;
  final String historicoFamiliarDoencaIsquemica;
  final String historicoFamiliarNeoplasia; // Changed from Neoplasias to Neoplasia
  final String historicoFamiliarDeficienciaFisica;
  final String historicoFamiliarDeficienciaMental;
  final String historicoFamiliarDoencaGenetica; // Changed from DoencasGeneticas to DoencaGenetica

  // Direct mapping for historicoDoadora fields
  // Note: 'historicoDoadora' was used for general epilepsy, now specifically for historicoDoadoraEpilepsia
  final String historicoDoadoraEpilepsia;
  final String historicoDoadoraHipertensao;
  final String historicoDoadoraDiabetesMellitus;
  final String historicoDoadoraDeficienciaFisica;
  final String historicoDoadoraDoencasGeneticas;
  final String historicoDoadorasNeoplasias;
  final String historicoDoadoraLabioLeporino;
  final String historicoDoadoraEspinhaBifida;
  final String historicoDoadoraDeficienciaMental;
  final String historicoDoadoraMalFormacaoCardica; // Corrected typo from Cardiaca to Cardica for consistency
  final String historicoDoadora; // This seems to be a general field based on your controller list

  final List<String> exames;
  final String status;

  // New fields
  final String assinatura;
  final String email;
  final String telefone;
  final String cpf;
  final String rg;
  final String cep;
  final String endereco;
  final String cidade;
  final String estado;
  final String dob;
  final String medicoAssistente;
  final String motivo;
  final String declaroVeracidade;
  final String caracteristicas1;
  final String idioma; // Added from controller list
  final String ovulos; // Added from controller list
  final Map<String, dynamic> rawData;

  Doadora({
    required this.id,
    this.prontuarioEletronico = "",
    required this.nome,
    required this.foto,
    this.observacao = '',
    required this.idade,
    required this.peso,
    required this.altura,
    required this.tipoSanguineo,
    required this.olhos,
    required this.cabeloCor,
    required this.cabeloTextura,
    required this.raca,
    required this.signo,
    required this.fitzpatrick, // Updated
    this.formatoRosto = '',
    required this.profissao,
    required this.hobby,
    required this.atividadeFisica,
    required this.escolaridade,
    required this.estadoCivil,
    required this.filhos,
    required this.irmaos,
    required this.filhaAdotiva, // Updated
    required this.gemeos, // Updated
    required this.qualidades,
    required this.historicoSaudeAudicao, // Updated
    required this.historicoSaudeVisao, // Updated
    required this.historicoSaudeAlergia, // Updated
    required this.historicoSaudeAsma, // Updated
    required this.historicoSaudeDoencaCronica, // Updated
    required this.historicoSaudeFumante, // Updated
    required this.historicoSaudeDrogas, // Updated
    required this.saudeAlcool,
    required this.historicoFamiliarAutismo, // Updated
    required this.historicoFamiliarDepressao, // Updated
    required this.historicoFamiliarEsquizofrenia, // Updated
    required this.historicoFamiliarAnemiaFalciforme, // Updated
    required this.historicoFamiliarTalassemia, // Updated
    required this.historicoFamiliarFibroseCistica, // Updated
    required this.historicoFamiliarDiabetesMelittus, // Updated
    required this.historicoFamiliarEpilepsia, // Updated
    required this.historicoFamiliarHipertensao, // Updated
    required this.historicoFamiliarDistrofiaMuscular, // Updated
    required this.historicoFamiliarAtrofiaMuscular, // Updated
    required this.historicoFamiliarDoencaIsquemica, // Updated
    required this.historicoFamiliarNeoplasia, // Updated
    required this.historicoFamiliarDeficienciaFisica, // Updated
    required this.historicoFamiliarDeficienciaMental, // Updated
    required this.historicoFamiliarDoencaGenetica, // Updated

    required this.historicoDoadoraEpilepsia, // Updated
    required this.historicoDoadoraHipertensao, // Updated
    required this.historicoDoadoraDiabetesMellitus, // Updated
    required this.historicoDoadoraDeficienciaFisica, // Updated
    required this.historicoDoadoraDoencasGeneticas, // Updated
    required this.historicoDoadorasNeoplasias, // Updated
    required this.historicoDoadoraLabioLeporino, // Updated
    required this.historicoDoadoraEspinhaBifida, // Updated
    required this.historicoDoadoraDeficienciaMental, // Updated
    required this.historicoDoadoraMalFormacaoCardica, // Updated
    required this.historicoDoadora, // Updated

    required this.exames,
    this.status = 'Pendente Punção',
    required this.assinatura,
    required this.email,
    required this.telefone,
    required this.cpf,
    required this.rg,
    required this.cep,
    required this.endereco,
    required this.cidade,
    required this.estado,
    required this.dob,
    required this.medicoAssistente,
    required this.motivo,
    required this.declaroVeracidade,
    required this.caracteristicas1,
    required this.rawData,
    this.idioma = '',
    this.ovulos = '',
    this.faceEmbedding,
  });

  factory Doadora.fromFirestore(Map<String, dynamic> data, String id) {
    // Certifique-se de que o faceEmbedding está sendo parseado aqui
    List<double>? parsedFaceEmbedding;
    if (data['faceEmbedding'] is List) {
      try {
        parsedFaceEmbedding = (data['faceEmbedding'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList();
      } catch (e) {
        print('Erro ao parsear faceEmbedding para Doadora ID $id: $e');
      }
    }
    return Doadora(
      faceEmbedding: parsedFaceEmbedding,
      id: id,
      nome: data['nomeCompleto'] ?? '',
      prontuarioEletronico: data['prontuarioEletronico'] ?? '',
      foto: data['fotoPerfil'] ?? '',
      observacao: data['observacao'] ?? '',
      idade: data['idade'] ?? '',
      peso: data['peso1'] ?? '',
      altura: data['altura1'] ?? '',
      tipoSanguineo: data['tipoSanguineo1'] ?? '',
      olhos: data['corOlhos1'] ?? '',
      cabeloCor: data['corCabelo1'] ?? '',
      cabeloTextura: data['tipoCabelo1'] ?? '',
      raca: data['raca1'] ?? '',
      signo: data['signo'] ?? '',
      fitzpatrick: data['fitzpatrick'] ?? '', // Updated
      formatoRosto: data['formatoRosto'] ?? '',
      profissao: data['profissao'] ?? '',
      hobby: data['hobbies'] ?? '',
      atividadeFisica: data['atividadesFisicas'] ?? '',
      escolaridade: data['escolaridade'] ?? '',
      estadoCivil: data['estadoCivil'] ?? '',
      filhos: data['filhos'] ?? '',
      irmaos: data['irmaos'] ?? '',
      filhaAdotiva: data['filhaAdotiva'] ?? '', // Updated
      gemeos: data['gemeos'] ?? '', // Updated
      qualidades: data['qualidades'] ?? '',
      historicoSaudeAudicao: data['historicoSaudeAudicao'] ?? '', // Updated
      historicoSaudeVisao: data['historicoSaudeVisao'] ?? '', // Updated
      historicoSaudeAlergia: data['historicoSaudeAlergia'] ?? '', // Updated
      historicoSaudeAsma: data['historicoSaudeAsma'] ?? '', // Updated
      historicoSaudeDoencaCronica: data['historicoSaudeDoencaCronica'] ?? '', // Updated
      historicoSaudeFumante: data['historicoSaudeFumante'] ?? '', // Updated
      historicoSaudeDrogas: data['historicoSaudeDrogas'] ?? '', // Updated
      saudeAlcool: data['historicoSaudeAlcool'] ?? '',
      historicoFamiliarAutismo: data['historicoFamiliarAutismo'] ?? '', // Updated
      historicoFamiliarDepressao: data['historicoFamiliarDepressao'] ?? '', // Updated
      historicoFamiliarEsquizofrenia: data['historicoFamiliarEsquizofrenia'] ?? '', // Updated
      historicoFamiliarAnemiaFalciforme: data['historicoFamiliarAnemiaFalciforme'] ?? '', // Updated
      historicoFamiliarTalassemia: data['historicoFamiliarTalassemia'] ?? '', // Updated
      historicoFamiliarFibroseCistica: data['historicoFamiliarFibroseCistica'] ?? '', // Updated
      historicoFamiliarDiabetesMelittus: data['historicoFamiliarDiabetesMelittus'] ?? '', // Updated
      historicoFamiliarEpilepsia: data['historicoFamiliarEpilepsia'] ?? '', // Updated
      historicoFamiliarHipertensao: data['historicoFamiliarHipertensao'] ?? '', // Updated
      historicoFamiliarDistrofiaMuscular: data['historicoFamiliarDistrofiaMuscular'] ?? '', // Updated
      historicoFamiliarAtrofiaMuscular: data['historicoFamiliarAtrofiaMuscular'] ?? '', // Updated
      historicoFamiliarDoencaIsquemica: data['historicoFamiliarDoencaIsquemica'] ?? '', // Updated
      historicoFamiliarNeoplasia: data['historicoFamiliarNeoplasia'] ?? '', // Updated
      historicoFamiliarDeficienciaFisica: data['historicoFamiliarDeficienciaFisica'] ?? '', // Updated
      historicoFamiliarDeficienciaMental: data['historicoFamiliarDeficienciaMental'] ?? '', // Updated
      historicoFamiliarDoencaGenetica: data['historicoFamiliarDoençaGenetica'] ?? '', // Updated

      historicoDoadoraEpilepsia: data['historicoDoadora'] ?? '', // Updated based on your mapping
      historicoDoadoraHipertensao: data['historicoDoadoraHipertensao'] ?? '', // Updated
      historicoDoadoraDiabetesMellitus: data['historicoDoadoraDiabetesMellitus'] ?? '', // Updated
      historicoDoadoraDeficienciaFisica: data['historicoDoadoraDeficienciaFisica'] ?? '', // Updated
      historicoDoadoraDoencasGeneticas: data['historicoDoadoraDoencasGeneticas'] ?? '', // Updated
      historicoDoadorasNeoplasias: data['historicoDoadorasNeoplasias'] ?? '', // Updated
      historicoDoadoraLabioLeporino: data['historicoDoadoraLabioLeporino'] ?? '', // Updated
      historicoDoadoraEspinhaBifida: data['historicoDoadoraEspinhaBifida'] ?? '', // Updated
      historicoDoadoraDeficienciaMental: data['historicoDoadoraDeficienciaMental'] ?? '', // Updated
      historicoDoadoraMalFormacaoCardica: data['historicoDoadoraMalFormacaoCardica'] ?? '', // Updated
      historicoDoadora: data['historicoDoadora'] ?? '', // If this is a general field, keep it.

      exames: (data['examesFeitos'] as String?)?.split(', ').toList() ?? [],
      status: data['status'] == '' ? 'Pendente Punção' : data['status'],
      assinatura: data['assinatura'] ?? '',
      email: data['email'] ?? '',
      telefone: data['telefone'] ?? '',
      cpf: data['cpf'] ?? '',
      rg: data['rg'] ?? '',
      cep: data['cep'] ?? '',
      endereco: data['endereco'] ?? '',
      cidade: data['cidade'] ?? '',
      estado: data['estado'] ?? '',
      dob: data['dob'] ?? '',
      medicoAssistente: data['medicoAssistente'] ?? '',
      motivo: data['motivo'] ?? '',
      declaroVeracidade: data['declaroVeracidade'] ?? '',
      caracteristicas1: data['caracteristicas1'] ?? '',
      rawData: data,
      idioma: data['idioma'] ?? '',
      ovulos: data['ovulos'] ?? '',
    );
  }
}


// Convert DoadorasListPage to StatefulWidget
class DoadorasListPage extends StatefulWidget {
  const DoadorasListPage({super.key});

  @override
  State<DoadorasListPage> createState() => _DoadorasListPageState();
}

class _DoadorasListPageState extends State<DoadorasListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // Store selected filter options for each category
  final Map<String, Set<String>> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });

    // Initialize _selectedFilters with empty sets for all categories
    for (var category in FilterCategory.allCategories) {
      _selectedFilters[category.attributeName] = {};
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to show the filter dialog
  void _showFilterDialog(BuildContext context, FilterCategory category) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a StatefulBuilder to manage the internal state of the dialog
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInDialog) {
            return AlertDialog(
              title: Text('Filtrar por ${category.title}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: category.options.map((option) {
                    final isSelected = _selectedFilters[category.attributeName]!.contains(option.value);
                    return CheckboxListTile(
                      title: Text(option.label),
                      value: isSelected,
                      onChanged: (bool? newValue) {
                        setStateInDialog(() { // Update dialog's state
                          if (newValue == true) {
                            _selectedFilters[category.attributeName]!.add(option.value);
                          } else {
                            _selectedFilters[category.attributeName]!.remove(option.value);
                          }
                        });
                        setState(() { // Update page's state to trigger list rebuild
                          // This setState will trigger the main build method to re-filter
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Limpar Filtros'),
                  onPressed: () {
                    setStateInDialog(() {
                      _selectedFilters[category.attributeName]!.clear();
                    });
                    setState(() {}); // Trigger main build to clear filters
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('Aplicar'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Pesquisar por nome',
                    hintText: 'Digite o nome da doadora',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchText.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Dropdown button for filters
              PopupMenuButton<FilterCategory>(
                icon: const Icon(Icons.filter_list),
                onSelected: (FilterCategory category) {
                  _showFilterDialog(context, category);
                },
                itemBuilder: (BuildContext context) {
                  return FilterCategory.allCategories.map((FilterCategory category) {
                    // Check if any filters are active for this category
                    final isActive = _selectedFilters[category.attributeName]?.isNotEmpty == true;
                    return PopupMenuItem<FilterCategory>(
                      value: category,
                      child: Row(
                        children: [
                          Text(category.title),
                          if (isActive)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                            ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('doadoras').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar dados'));
              }

              final docs = snapshot.data!.docs;

              List<Doadora> doadoras = docs.map((doc) {
                return Doadora.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              // Apply search filter
              if (_searchText.isNotEmpty) {
                doadoras = doadoras.where((doadora) {
                  return doadora.nome.toLowerCase().contains(_searchText);
                }).toList();
              }

              // Apply checkbox filters
              for (var category in FilterCategory.allCategories) {
                final selectedValues = _selectedFilters[category.attributeName];
                if (selectedValues != null && selectedValues.isNotEmpty) {
                  doadoras = doadoras.where((doadora) {
                    final doadoraAttributeValue = _getDoadoraAttribute(doadora, category.attributeName);
                    return selectedValues.contains(doadoraAttributeValue);
                  }).toList();
                }
              }

              // Sort the filtered list alphabetically by 'nome'
              doadoras.sort((a, b) => a.nome.compareTo(b.nome));

              if (doadoras.isEmpty && (_searchText.isNotEmpty || _anyFilterActive())) {
                return const Center(child: Text('Nenhuma doadora encontrada com os filtros aplicados.'));
              } else if (doadoras.isEmpty) {
                return const Center(child: Text('Nenhuma doadora cadastrada.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: doadoras.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                  height: 16,
                ),
                itemBuilder: (context, index) {
                  final doadora = doadoras[index];
                  final originalDocData = (docs.firstWhere((doc) => doc.id == doadora.id).data() as Map<String, dynamic>);
                  final quantidadeOvos = originalDocData['quantidadeOvos'] ?? '0';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(doadora.foto),
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Error loading image for ${doadora.nome}: $exception');
                      },
                      child: doadora.foto.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                      backgroundColor: doadora.foto.isEmpty ? Colors.grey : null,
                    ),
                    title: Text(doadora.nome, style: const TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text('Óvulos: $quantidadeOvos'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => DoadoraDetailDialog(doadora: doadora),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper method to dynamically get doadora attribute value
  String _getDoadoraAttribute(Doadora doadora, String attributeName) {
    switch (attributeName) {
      case 'tipoSanguineo1':
        return doadora.tipoSanguineo;
      case 'corOlhos1':
        return doadora.olhos;
      case 'corCabelo1':
        return doadora.cabeloCor;
      case 'tipoCabelo1':
        return doadora.cabeloTextura;
      case 'fitzpatric':
        return doadora.fitzpatrick;
      case 'raca1':
        return doadora.raca;
    // Add more cases here as you add more filter categories
      default:
        return ''; // Return empty string for unknown attributes
    }
  }

  // Helper to check if any filter is active
  bool _anyFilterActive() {
    return _selectedFilters.values.any((set) => set.isNotEmpty);
  }
}