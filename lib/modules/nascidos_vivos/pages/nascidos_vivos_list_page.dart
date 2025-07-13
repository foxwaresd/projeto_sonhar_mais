import 'package:flutter/material.dart';

class NascidoVivoListPage extends StatelessWidget {
  const NascidoVivoListPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> nascidosVivos = const [
    {
      'paciente': 'Maria Silva',
      'id': '123',
      'ovulos_utilizados': 3,
    },
    {
      'paciente': 'João Souza',
      'id': '456',
      'ovulos_utilizados': 5,
    },
    // Pode adicionar mais exemplos
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nascidos Vivos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/adicionar_nascido_vivo');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: nascidosVivos.length,
        itemBuilder: (context, index) {
          final nascido = nascidosVivos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(nascido['paciente']),
              subtitle: Text('ID: ${nascido['id']}'),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${nascido['ovulos_utilizados']} óvulos',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            label: 'Voltar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
        ],
      ),
    );
  }
}
