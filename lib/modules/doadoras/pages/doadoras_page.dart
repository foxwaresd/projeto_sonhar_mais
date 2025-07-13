import 'package:flutter/material.dart';

import 'adicionar_doadora_page.dart';
import 'doadora_list_page.dart';
import 'importar_xls_page.dart';

class ModuloDoadorasPage extends StatefulWidget {
  const ModuloDoadorasPage({Key? key}) : super(key: key);

  @override
  State<ModuloDoadorasPage> createState() => _ModuloDoadorasPageState();
}

class _ModuloDoadorasPageState extends State<ModuloDoadorasPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DoadorasListPage(),
    AdicionarDoadoraPage(),
    ImportarDoadorasPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<String> _titles = [
    'Lista de Doadoras',
    'Cadastrar Doadora',
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
