
import 'package:flutter/material.dart';
import 'package:projeto_sonhar_mais/core/theme/app_colors.dart';
class ReceiverInfoCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final Map<String, dynamic> receiverDetails;

  const ReceiverInfoCard({
    Key? key,
    required this.name,
    this.photoUrl,
    required this.receiverDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
              CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.secondary.withOpacity(0.2),
              backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
                  ? NetworkImage(photoUrl!)
                  : null,
              child: photoUrl == null || photoUrl!.isEmpty
                  ? Icon(Icons.person, size: 60, color: AppColors.secondary)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(name, style: TextStyle(fontSize: 18),),
            const SizedBox(height: 8),
            // Exibir outras informações da receptora
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo sanguíneo: ${receiverDetails['tipoSanguineo1'] ?? 'N/A'}',),
                    const SizedBox(height: 8),
                    // Exibir outras informações da receptora
                    Text('Raça: ${receiverDetails['raca1'] ?? 'N/A'}',),
                    const SizedBox(height: 8),
                    // Exibir outras informações da receptora
                    Text('Fitzpatrick: ${receiverDetails['fitzpatrick'] ?? 'N/A'}',),
                    const SizedBox(height: 8),
                    // Exibir outras informações da receptora
                    Text('Cor dos olhos: ${receiverDetails['corOlhos1'] ?? 'N/A'}',),
                    const SizedBox(height: 8),
                    // Exibir outras informações da receptora
                    Text('Cor do cabelo: ${receiverDetails['corCabelo1'] ?? 'N/A'}',),
                    const SizedBox(height: 8),
                    // Exibir outras informações da receptora
                    Text('Tipo de cabelo: ${receiverDetails['tipoCabelo1'] ?? 'N/A'}',),
              ],
            ),
  // Você pode adicionar mais detalhes aqui, como fenótipos da receptora, etc.
  ],
  ),
  ),
  );
}
}