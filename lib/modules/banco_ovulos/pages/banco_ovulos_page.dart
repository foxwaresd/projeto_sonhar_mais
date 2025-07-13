import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'banco_ovulos_list_page.dart';
import 'import_xls_page.dart';

class BancoOvulosPage extends StatefulWidget {
  const BancoOvulosPage({Key? key}) : super(key: key);

  @override
  State<BancoOvulosPage> createState() => _BancoOvulosPageState();
}

class _BancoOvulosPageState extends State<BancoOvulosPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BancoOvulosListPage(),
    const ImportXlsPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Ao clicar em Adicionar, abre o diálogo
      _showAddDialog();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddDialog() {
    String nome = '';
    String id = '';
    String ovulos = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Doadora'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) => nome = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'ID'),
                onChanged: (value) => id = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Óvulos'),
                keyboardType: TextInputType.number,
                onChanged: (value) => ovulos = value,
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
                if (nome.isNotEmpty && ovulos.isNotEmpty) {
                  final newDoc = FirebaseFirestore.instance.collection('bancoOvulos').doc();
                  await newDoc.set({
                    'id': id,
                    'nome': nome,
                    'ovulos': int.tryParse(ovulos) ?? 0,
                  });
                  // Mostrar snackbar de sucesso
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Doadora adicionada com sucesso!')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
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
        title: const Text('Banco de Óvulos'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Importar XLS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Adicionar',
          ),
        ],
      ),
    );
  }
}
