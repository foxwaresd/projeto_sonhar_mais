import 'package:flutter/material.dart';
import 'criar_usuario_page.dart';
import 'empresa_page.dart';
import 'upload_logo_page.dart';

class AdministrativoPage extends StatefulWidget {
  const AdministrativoPage({super.key});

  @override
  State<AdministrativoPage> createState() => _AdministrativoPageState();
}

class _AdministrativoPageState extends State<AdministrativoPage> {
  int _selectedIndex = 0;

  final _pages = [
    const CriarUsuarioPage(),
    const BancoOvulosPage(),
    const UploadLogoPage(),
  ];

  final _titles = [
    'Criar Usuário',
    'Banco de Óvulos',
    'Upload do Logo',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Usuário'),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: 'Dados Cadastro'),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Logo'),
        ],
      ),
    );
  }
}
