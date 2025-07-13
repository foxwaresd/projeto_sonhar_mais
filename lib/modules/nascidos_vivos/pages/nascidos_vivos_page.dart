import 'package:flutter/material.dart';
import 'adicionar_nascido_vivo_page.dart';
import 'import_xlsx_nascidos_vivos_page.dart';
import 'nascidos_vivos_list_page.dart';

class NascidosVivosPage extends StatefulWidget {
  const NascidosVivosPage({Key? key}) : super(key: key);

  @override
  State<NascidosVivosPage> createState() => _NascidosVivosPageState();
}

class _NascidosVivosPageState extends State<NascidosVivosPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NascidoVivoListPage(),
    const AdicionarNascidoVivoPage(),
    const ImportXlsxNascidosVivosPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<String> _titles = [
    'Lista Nascidos Vivos',
    'Adicionar Nascido Vivo',
    'Importar XLSX',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
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
            icon: Icon(Icons.add),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload),
            label: 'Importar',
          ),
        ],
      ),
    );
  }
}
