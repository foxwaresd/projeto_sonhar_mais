import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_sonhar_mais/core/theme/app_colors.dart';
import '../../../common/widgets/filters.dart';
import '../../doadoras/pages/doadora_list_page.dart'; // Ensure Doadora class is accessible
import '../../receptoras/pages/receptora_list_page.dart'; // Import Receptora class

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, String?> _selectedDoadoraCounts = {};
  Map<String, String?> _selectedReceptoraCounts = {};

  @override
  void initState() {
    super.initState();
    for (var category in FilterCategory.allCategories) {
      _selectedDoadoraCounts[category.attributeName] = null;
    }
    for (var category in FilterCategory.allCategories) {
      _selectedReceptoraCounts[category.attributeName] = null;
    }
  }

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
      default:
        return '';
    }
  }

  String _getReceptoraAttribute(Receptora receptora, String attributeName) {
    switch (attributeName) {
      case 'tipoSanguineo1':
        return receptora.tipoSanguineo1!;
      case 'corOlhos1':
        return receptora.corOlhos1!;
      case 'corCabelo1':
        return receptora.corCabelo1!;
      case 'tipoCabelo1':
        return receptora.tipoCabelo1!;
      case 'raca1':
        return receptora.raca1!;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('doadoras').snapshots(),
        builder: (context, doadorasSnapshot) {
          if (doadorasSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (doadorasSnapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados de doadoras: ${doadorasSnapshot.error}'));
          }

          final allDoadoras = doadorasSnapshot.data!.docs.map((doc) {
            return Doadora.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          final rawDoadoraDocs = doadorasSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('receptora').snapshots(),
            builder: (context, receptorasSnapshot) {
              if (receptorasSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (receptorasSnapshot.hasError) {
                return Center(child: Text('Erro ao carregar dados de receptoras: ${receptorasSnapshot.error}'));
              }

              final allReceptoras = receptorasSnapshot.data!.docs.map((doc) {
                return Receptora.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();

              final rawReceptoraDocs = receptorasSnapshot.data!.docs;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Visão Geral Doadoras'),
                              _buildInfoCard(
                                title: 'Total de Doadoras',
                                count: allDoadoras.length,
                                icon: Icons.people,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                title: 'Óvulos Disponíveis',
                                count: rawDoadoraDocs.fold<int>(0, (int sum, QueryDocumentSnapshot doc) { // Explicitly define sum as int
                                  final data = doc.data() as Map<String, dynamic>;
                                  final dynamic quantidadeOvos = data['quantidadeOvos'];
                                  int parsedQuantity = 0;
                                  if (quantidadeOvos is num) { // Check if it's a number
                                    parsedQuantity = quantidadeOvos.toInt();
                                  } else if (quantidadeOvos is String) { // Or a string that can be parsed
                                    parsedQuantity = int.tryParse(quantidadeOvos) ?? 0;
                                  }
                                  return sum + parsedQuantity;
                                }),
                                icon: Icons.egg,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Visão Geral Receptoras'),
                              _buildInfoCard(
                                title: 'Total de Receptoras',
                                count: allReceptoras.length,
                                icon: Icons.pregnant_woman,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                title: 'Óvulos Desejados',
                                count: rawReceptoraDocs.fold<int>(0, (int sum, QueryDocumentSnapshot doc) { // Explicitly define sum as int
                                  final data = doc.data() as Map<String, dynamic>;
                                  final dynamic ovulosDesejados = data['ovulosDesejados'];
                                  int parsedDesiredOvulos = 0;
                                  if (ovulosDesejados is num) {
                                    parsedDesiredOvulos = ovulosDesejados.toInt();
                                  } else if (ovulosDesejados is String) {
                                    parsedDesiredOvulos = int.tryParse(ovulosDesejados) ?? 0;
                                  }
                                  return sum + parsedDesiredOvulos;
                                }),
                                icon: Icons.baby_changing_station,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Doadoras por Categoria'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        mainAxisExtent: 150.0,
                      ),
                      itemCount: FilterCategory.allCategories.length,
                      itemBuilder: (context, index) {
                        final category = FilterCategory.allCategories[index];
                        final currentSelectedValue = _selectedDoadoraCounts[category.attributeName];
                        final count = currentSelectedValue != null
                            ? allDoadoras
                            .where((doadora) =>
                        _getDoadoraAttribute(doadora, category.attributeName) ==
                            currentSelectedValue)
                            .length
                            : allDoadoras.length;

                        return _buildCategoryCard(
                          category.title,
                          currentSelectedValue,
                          category.options.map((opt) => DropdownMenuItem<String>(
                            value: opt.value,
                            child: Text(opt.label, style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          count,
                              (newValue) {
                            setState(() {
                              _selectedDoadoraCounts[category.attributeName] = newValue;
                            });
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Receptoras por Categoria'),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        mainAxisExtent: 150.0,
                      ),
                      itemCount: FilterCategory.allCategories.length,
                      itemBuilder: (context, index) {
                        final category = FilterCategory.allCategories[index];
                        final currentSelectedValue = _selectedReceptoraCounts[category.attributeName];
                        final count = currentSelectedValue != null
                            ? allReceptoras
                            .where((receptora) =>
                        _getReceptoraAttribute(receptora, category.attributeName) ==
                            currentSelectedValue)
                            .length
                            : allReceptoras.length;

                        return _buildCategoryCard(
                          category.title,
                          currentSelectedValue,
                          category.options.map((opt) => DropdownMenuItem<String>(
                            value: opt.value,
                            child: Text(opt.label, style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          count,
                              (newValue) {
                            setState(() {
                              _selectedReceptoraCounts[category.attributeName] = newValue;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Divider(color: AppColors.textPrimary, thickness: 1),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required int count, required IconData icon}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 36, color: AppColors.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                  ),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      String title,
      String? currentValue,
      List<DropdownMenuItem<String>> dropdownItems,
      int count,
      ValueChanged<String?> onChanged) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: currentValue,
                        hint: const Text('Selecionar', style: TextStyle(fontSize: 13)),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Todas as opções', style: TextStyle(fontSize: 13)),
                          ),
                          ...dropdownItems,
                        ],
                        onChanged: onChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  Text(
                    currentValue != null ? 'itens' : 'total',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}