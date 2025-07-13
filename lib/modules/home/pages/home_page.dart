import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../banco_ovulos/pages/banco_ovulos_page.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../administrativo/pages/administrativo_page.dart';
import '../../doadoras/pages/doadoras_page.dart';
import '../../formulario/pages/forms/form_admin.dart';
import '../../nascidos_vivos/pages/nascidos_vivos_page.dart';
import '../../pareamento/pages/pareamento_page.dart';
import '../../receptoras/pages/receptora_page.dart';
import '../widgets/side_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const ModuloDoadorasPage();
      case 2:
        return const ModuloReceptorasPage();
      case 5:
        return const BancoOvulosPage();
        case 3:
        return const PairingScreen();
      case 4:
        return const FormulariosScreen();
      case 6:
        return const AdministrativoPage();
      case 7:
        return const Center(child: Text('Saindo...'));
      default:
        return Center(
          child: Text(
            _menuLabels[_selectedIndex],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
    }
  }

  static const List<String> _menuLabels = [
    'Dashboard',
    'Doadoras',
    'Receptoras',
    'Banco de Óvulos',
    'Pareamento',
    'Formulário',
    'Administrativo',
    'Sair',
  ];

  void _onItemSelected(int index) async {
    if (index == 8) {
      // Se for "Sair"
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      drawer: isSmallScreen
          ? SideMenu(
        onItemSelected: (index) {
          _onItemSelected(index);
          Navigator.of(context).pop();
        },
        selectedIndex: _selectedIndex,
      )
          : null,
      body: Row(
        children: [
          if (!isSmallScreen)
            SizedBox(
              width: 250,
              child: SideMenu(
                onItemSelected: _onItemSelected,
                selectedIndex: _selectedIndex,
              ),
            ),
          Expanded(child: _getSelectedPage()),
        ],
      ),
    );
  }
}
