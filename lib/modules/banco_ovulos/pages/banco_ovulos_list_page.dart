import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BancoOvulo {
  final String uid;  // ID do documento Firestore (único, para operação)
  final String id;   // campo id que vem do dado e será exibido
  final String nome;
  final int ovulos;

  BancoOvulo({
    required this.uid,
    required this.id,
    required this.nome,
    required this.ovulos,
  });

  factory BancoOvulo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return BancoOvulo(
      uid: doc.id,
      id: data['id'] ?? '',
      nome: data['nome'] ?? 'Paciente desconhecido',
      ovulos: int.tryParse(data['ovulos'].toString()) ?? 0,
    );
  }
}


class BancoOvulosListPage extends StatefulWidget {
  const BancoOvulosListPage({Key? key}) : super(key: key);

  @override
  _BancoOvulosListPageState createState() => _BancoOvulosListPageState();
}

class _BancoOvulosListPageState extends State<BancoOvulosListPage> {
  final Stream<QuerySnapshot> _bancoOvulosStream = FirebaseFirestore.instance
      .collection('bancoOvulos')
      .orderBy('nome')
      .snapshots();

  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _bancoOvulosStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('Nenhum registro encontrado.'));
        }

        final banco = docs.map((doc) => BancoOvulo.fromDocument(doc)).toList();

        final totalOvulos = banco.fold<int>(0, (sum, item) => sum + item.ovulos);
        final totalDoadoras = banco.length;

        final filteredBanco = banco.where((item) {
          return item.nome.toLowerCase().contains(_searchText.toLowerCase());
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.blueAccent.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total de doadoras: $totalDoadoras',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    '|',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total de óvulos: $totalOvulos',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar por nome...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredBanco.isEmpty
                  ? const Center(child: Text('Nenhum resultado encontrado.'))
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredBanco.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filteredBanco[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            String nomeEditado = item.nome;
                            String ovulosEditado = item.ovulos.toString();

                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Detalhes'),
                                  SizedBox(
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      tooltip: 'Fechar',
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Doadora: ${item.nome}'),
                                  const SizedBox(height: 8),
                                  Text('ID: ${item.id}'),
                                  const SizedBox(height: 8),
                                  Text('Óvulos: ${item.ovulos}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // fecha primeiro Dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Editar Doadora'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextField(
                                                decoration: const InputDecoration(labelText: 'Nome'),
                                                controller: TextEditingController(text: nomeEditado),
                                                onChanged: (value) => nomeEditado = value,
                                              ),
                                              TextField(
                                                decoration: const InputDecoration(labelText: 'Óvulos'),
                                                keyboardType: TextInputType.number,
                                                controller: TextEditingController(text: ovulosEditado),
                                                onChanged: (value) => ovulosEditado = value,
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('bancoOvulos')
                                                    .doc(item.uid) // <-- usar uid aqui
                                                    .update({
                                                  'nome': nomeEditado,
                                                  'ovulos': int.tryParse(ovulosEditado) ?? item.ovulos,
                                                });

                                                Navigator.pop(context);
                                              },
                                              child: const Text('Salvar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Editar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirmar Exclusão'),
                                        content: const Text('Tem certeza que deseja excluir esta doadora?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection('bancoOvulos')
                                          .doc(item.uid)  // <-- uid aqui também
                                          .delete();

                                    }

                                    Navigator.pop(context); // fecha o primeiro dialog
                                  },
                                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      title: Text(item.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('ID: ${item.id}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.ovulos} óvulos',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    )

                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
