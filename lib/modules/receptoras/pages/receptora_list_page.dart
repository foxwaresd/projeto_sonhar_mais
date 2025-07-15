

// Your receptora class remains unchanged
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/filters.dart';
import 'widgets/receptora_detail_dialog.dart';

class Receptora {
  final String id;
  final String nomeCompleto;
  final String fotoPerfil;
  final String observacao;
  final String idade;

  final String? pesoOriginal;
  final String? alturaOriginal;

  final String? tipoSanguineo1;
  final String? tipoSanguineo2;
  final String? raca1;
  final String? raca2;
  final String? corPeleFitzpatrick1;
  final String? corPeleFitzpatrick2;
  final String? corOlhos1;
  final String? corOlhos2;
  final String? corCabelo1;
  final String? corCabelo2;
  final String? tipoCabelo1;
  final String? tipoCabelo2;

  final double? altura1Cm;
  final double? altura2Cm;
  final double? peso1Kg;
  final double? peso2Kg;
  final List<double>? faceEmbedding;

  final String assinatura;
  final String caracteristicas1;
  final String caracteristicas2;
  final String cep;
  final String cidade;
  final String clinica;
  final String cpf;
  final String declaroVeracidade;
  final String email;
  final String endereco;
  final String estado;
  final String fotoAdolescenciaFinal;
  final String fotoAdolescenciaInicial;
  final String fotoAdolescenciaMedia;
  final String fotoAdulto;
  final String fotoAdultoInicial;
  final String fotoAdultoIntermediario;
  final String fotoFaseAtual;
  final String fotoInfanciaIntermediaria;
  final String fotoPrimeiraInfancia;
  final String fotoRecente;
  final String medicoAssistente;
  final String ovulos;
  final String rg;
  final String telefone;
  final String status;
  final DateTime? createdAt; // NEW: DateTime for creation timestamp

  final Map<String, dynamic> rawData;

  Receptora({
    required this.id,
    required this.nomeCompleto,
    required this.fotoPerfil,
    required this.observacao,
    required this.idade,
    this.pesoOriginal,
    this.alturaOriginal,
    this.tipoSanguineo1,
    this.tipoSanguineo2,
    this.corOlhos1,
    this.corOlhos2,
    this.corCabelo1,
    this.corCabelo2,
    this.tipoCabelo1,
    this.tipoCabelo2,
    this.raca1,
    this.raca2,
    this.corPeleFitzpatrick1,
    this.corPeleFitzpatrick2,
    this.altura1Cm,
    this.altura2Cm,
    this.peso1Kg,
    this.peso2Kg,
    this.faceEmbedding,
    required this.assinatura,
    required this.caracteristicas1,
    required this.caracteristicas2,
    required this.cep,
    required this.cidade,
    required this.clinica,
    required this.cpf,
    required this.declaroVeracidade,
    required this.email,
    required this.endereco,
    required this.estado,
    required this.fotoAdolescenciaFinal,
    required this.fotoAdolescenciaInicial,
    required this.fotoAdolescenciaMedia,
    required this.fotoAdulto,
    required this.fotoAdultoInicial,
    required this.fotoAdultoIntermediario,
    required this.fotoFaseAtual,
    required this.fotoInfanciaIntermediaria,
    required this.fotoPrimeiraInfancia,
    required this.fotoRecente,
    required this.medicoAssistente,
    required this.ovulos,
    required this.rg,
    required this.telefone,
    required this.status,
    required this.rawData,
    this.createdAt, // NEW: Add to constructor
  });

  factory Receptora.fromFirestore(Map<String, dynamic> data, String docId) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final cleanedValue = value.trim().replaceAll(',', '.');
        return double.tryParse(cleanedValue);
      }
      return null;
    }

    List<double>? embedding;
    if (data['faceEmbedding'] != null && data['faceEmbedding'] is List) {
      List<dynamic> rawList = data['faceEmbedding'];
      List<double> tempList = [];
      bool parseSuccess = true;

      for (int i = 0; i < rawList.length; i++) {
        var element = rawList[i];
        if (element is num) {
          tempList.add(element.toDouble());
        } else {
          parseSuccess = false;
          break;
        }
      }
      if (parseSuccess) {
        embedding = tempList;
      } else {
        embedding = null;
      }
    }

    // NEW: Parse createdAt Timestamp
    DateTime? createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    }

    return Receptora(
      id: docId,
      nomeCompleto: data['nomeCompleto'] ?? 'Receptora Desconhecida',
      fotoPerfil: data['fotoPerfil'] ?? '',
      observacao: data['observacao'] ?? '',
      idade: data['idade'] ?? '',
      pesoOriginal: data['peso1'],
      alturaOriginal: data['altura1'],
      tipoSanguineo1: (data['tipoSanguineo1'] as String?)?.toUpperCase(),
      tipoSanguineo2: (data['tipoSanguineo2'] as String?)?.toUpperCase(),
      corOlhos1: (data['corOlhos1'] as String?)?.toUpperCase(),
      corOlhos2: (data['corOlhos2'] as String?)?.toUpperCase(),
      corCabelo1: (data['corCabelo1'] as String?)?.toUpperCase(),
      corCabelo2: (data['corCabelo2'] as String?)?.toUpperCase(),
      tipoCabelo1: (data['tipoCabelo1'] as String?)?.toUpperCase(),
      tipoCabelo2: (data['tipoCabelo2'] as String?)?.toUpperCase(),
      raca1: (data['raca1'] as String?)?.toUpperCase(),
      raca2: (data['raca2'] as String?)?.toUpperCase(),
      corPeleFitzpatrick1: (data['fitzpatrick'] as String?)?.toUpperCase(),
      corPeleFitzpatrick2: (data['fitzpatrick2'] as String?)?.toUpperCase(),
      altura1Cm: parseDouble(data['altura1']),
      altura2Cm: parseDouble(data['altura2']),
      peso1Kg: parseDouble(data['peso1']),
      peso2Kg: parseDouble(data['peso2']),
      faceEmbedding: embedding,
      assinatura: data['assinatura'] ?? '',
      caracteristicas1: data['caracteristicas1'] ?? '',
      caracteristicas2: data['caracteristicas2'] ?? '',
      cep: data['cep'] ?? '',
      cidade: data['cidade'] ?? '',
      clinica: data['clinica'] ?? '',
      cpf: data['cpf'] ?? '',
      declaroVeracidade: data['declaroVeracidade'] ?? '',
      email: data['email'] ?? '',
      endereco: data['endereco'] ?? '',
      estado: data['estado'] ?? '',
      fotoAdolescenciaFinal: data['fotoAdolescenciaFinal'] ?? '',
      fotoAdolescenciaInicial: data['fotoAdolescenciaInicial'] ?? '',
      fotoAdolescenciaMedia: data['fotoAdolescenciaMedia'] ?? '',
      fotoAdulto: data['fotoAdulto'] ?? '',
      fotoAdultoInicial: data['fotoAdultoInicial'] ?? '',
      fotoAdultoIntermediario: data['fotoAdultoIntermediario'] ?? '',
      fotoFaseAtual: data['fotoFaseAtual'] ?? '',
      fotoInfanciaIntermediaria: data['fotoInfanciaIntermediaria'] ?? '',
      fotoPrimeiraInfancia: data['fotoPrimeiraInfancia'] ?? '',
      fotoRecente: data['fotoRecente'] ?? '',
      medicoAssistente: data['medicoAssistente'] ?? '',
      ovulos: data['ovulos'] ?? '',
      rg: data['rg'] ?? '',
      telefone: data['telefone'] ?? '',
      status: (data['status'] == null || data['status'] == '') ? 'Iniciando a ficha' : data['status'],
      rawData: data,
      createdAt: createdAt, // NEW: Assign parsed createdAt
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nomeCompleto': nomeCompleto,
      'fotoPerfil': fotoPerfil,
      'observacao': observacao,
      'idade': idade,
      'peso1': pesoOriginal,
      'altura1': alturaOriginal,
      'tipoSanguineo1': tipoSanguineo1,
      'tipoSanguineo2': tipoSanguineo2,
      'corOlhos1': corOlhos1,
      'corOlhos2': corOlhos2,
      'corCabelo1': corCabelo1,
      'corCabelo2': corCabelo2,
      'tipoCabelo1': tipoCabelo1,
      'tipoCabelo2': tipoCabelo2,
      'raca1': raca1,
      'raca2': raca2,
      'fitzpatrick': corPeleFitzpatrick1,
      'fitzpatrick2': corPeleFitzpatrick2,
      'altura1': altura1Cm,
      'altura2': altura2Cm,
      'peso1Kg': peso1Kg,
      'peso2Kg': peso2Kg,
      'faceEmbedding': faceEmbedding,
      'assinatura': assinatura,
      'caracteristicas1': caracteristicas1,
      'caracteristicas2': caracteristicas2,
      'cep': cep,
      'cidade': cidade,
      'clinica': clinica,
      'cpf': cpf,
      'declaroVeracidade': declaroVeracidade,
      'email': email,
      'endereco': endereco,
      'estado': estado,
      'fotoAdolescenciaFinal': fotoAdolescenciaFinal,
      'fotoAdolescenciaInicial': fotoAdolescenciaInicial,
      'fotoAdolescenciaMedia': fotoAdolescenciaMedia,
      'fotoAdulto': fotoAdulto,
      'fotoAdultoInicial': fotoAdultoInicial,
      'fotoAdultoIntermediario': fotoAdultoIntermediario,
      'fotoFaseAtual': fotoFaseAtual,
      'fotoInfanciaIntermediaria': fotoInfanciaIntermediaria,
      'fotoPrimeiraInfancia': fotoPrimeiraInfancia,
      'fotoRecente': fotoRecente,
      'medicoAssistente': medicoAssistente,
      'ovulos': ovulos,
      'rg': rg,
      'telefone': telefone,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null, // NEW: Save createdAt
    };
  }
}

// Convert receptorasListPage to StatefulWidget
class receptorasListPage extends StatefulWidget {
  const receptorasListPage({super.key});

  @override
  State<receptorasListPage> createState() => _receptorasListPageState();
}

class _receptorasListPageState extends State<receptorasListPage> {
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
                    hintText: 'Digite o nome da receptora',
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
            stream: FirebaseFirestore.instance.collection('receptora').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar dados'));
              }

              final docs = snapshot.data!.docs;

              List<Receptora> receptoras = docs.map((doc) {
                return Receptora.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              // Apply search filter
              if (_searchText.isNotEmpty) {
                receptoras = receptoras.where((receptora) {
                  return receptora.nomeCompleto.toLowerCase().contains(_searchText);
                }).toList();
              }

              // Apply checkbox filters
              for (var category in FilterCategory.allCategories) {
                final selectedValues = _selectedFilters[category.attributeName];
                if (selectedValues != null && selectedValues.isNotEmpty) {
                  receptoras = receptoras.where((receptora) {
                    final receptoraAttributeValue = _getreceptoraAttribute(receptora, category.attributeName);
                    return selectedValues.contains(receptoraAttributeValue);
                  }).toList();
                }
              }

              // Sort the filtered list alphabetically by 'nomeCompleto'
              receptoras.sort((a, b) => a.nomeCompleto.compareTo(b.nomeCompleto));

              if (receptoras.isEmpty && (_searchText.isNotEmpty || _anyFilterActive())) {
                return const Center(child: Text('Nenhuma receptora encontrada com os filtros aplicados.'));
              } else if (receptoras.isEmpty) {
                return const Center(child: Text('Nenhuma receptora cadastrada.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: receptoras.length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey[400],
                  thickness: 1,
                  height: 16,
                ),
                itemBuilder: (context, index) {
                  final receptora = receptoras[index];
                  final originalDocData = (docs.firstWhere((doc) => doc.id == receptora.id).data() as Map<String, dynamic>);
                  final quantidadeOvos = originalDocData['quantidadeOvos'] ?? '0';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(receptora.fotoPerfil),
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint('Error loading image for ${receptora.nomeCompleto}: $exception');
                      },
                      child: receptora.fotoPerfil.isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                      backgroundColor: receptora.fotoPerfil.isEmpty ? Colors.grey : null,
                    ),
                    title: Text(receptora.nomeCompleto, style: const TextStyle(fontWeight: FontWeight.bold),),
                    subtitle: Text('Óvulos: $quantidadeOvos'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => ReceptoraDetailDialog(receptora: receptora),
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

  // Helper method to dynamically get receptora attribute value
  String _getreceptoraAttribute(Receptora receptora, String attributeName) {
    switch (attributeName) {
      case 'tipoSanguineo':
        return receptora.tipoSanguineo1!;
      case 'olhos':
        return receptora.corOlhos1!;
      case 'cabeloCor':
        return receptora.corCabelo1!;
      case 'cabeloTextura':
        return receptora.tipoCabelo1!;
      case 'escalaFitzpatric':
        return receptora.corPeleFitzpatrick1!;
      case 'raca':
        return receptora.raca1!;
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