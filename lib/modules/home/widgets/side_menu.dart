import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../../../core/theme/app_colors.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // Method to fetch the logo URL from Firestore
  Future<String?> _fetchLogoUrl() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('configuracoes')
          .doc('logo')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        if (data.containsKey('url') && data['url'] is String) {
          return data['url'] as String;
        }
      }
      return null; // No URL found
    } catch (e) {
      debugPrint('Erro ao buscar URL da logo: $e');
      return null; // Return null on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 9,
      color: AppColors.primary, // cor de fundo primária
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(50),
        ),
        child: Column(
          children: [
            // Container for the logo
            Container(
              alignment: Alignment.centerLeft, // Center the logo
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: FutureBuilder<String?>(
                future: _fetchLogoUrl(), // Call the async function here
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white); // Show loading
                  } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    // Handle error or no logo found
                    return const Icon(
                      Icons.business, // Placeholder icon
                      color: Colors.white70,
                      size: 100,
                    );
                  } else {
                    // Display the logo if URL is available
                    return Image.network(
                      snapshot.data!,
                      height: 100, // Adjust height as needed
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback in case of image loading error
                        return const Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 60,
                        );
                      },
                    );
                  }
                },
              ),
            ),
            // Use Expanded to allow ListView to take remaining space
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (var i = 0; i < _menuLabels.length; i++)
                    ListTile(
                      title: Text(
                        _menuLabels[i],
                        style: TextStyle(
                          color: selectedIndex == i ? Colors.white : Colors.white70,
                          fontWeight: selectedIndex == i ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: selectedIndex == i,
                      onTap: () => onItemSelected(i),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _menuLabels = [
    'Dashboard',
    'Doadoras',
    'Receptoras',
    'Banco de Óvulos',
    'Pareamento',
    'Formulário',
    'Relatórios',
    //'Administrativo',
    'Sair',
  ];
}