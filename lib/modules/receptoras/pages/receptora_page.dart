import 'package:flutter/material.dart';

import 'adicionar_receptora_page.dart';
import 'receptora_list_page.dart';
import 'importar_xls_page.dart';

class ModuloReceptorasPage extends StatefulWidget {
  const ModuloReceptorasPage({Key? key}) : super(key: key);

  @override
  State<ModuloReceptorasPage> createState() => _ModuloReceptorasPageState();
}

class _ModuloReceptorasPageState extends State<ModuloReceptorasPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    receptorasListPage(),
    AdicionarReceptoraPage(),
    ImportarReceptorasPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<String> _titles = [
    'Lista de receptoras',
    'Cadastrar receptora',
    'Importar Planilha XLS',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _pages[_selectedIndex],
      /*bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Cadastrar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Importar XLS',
          ),
        ],
      ),*/
    );
  }
}
