import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/matching_results.dart';

class DonorMatchCard extends StatelessWidget {
  final MatchingResult match;
  final VoidCallback onTap;

  const DonorMatchCard({
    Key? key,
    required this.match,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de Informações da Doadora (sem alterações)
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                    backgroundImage: match.donorPhotoUrl.isNotEmpty
                        ? NetworkImage(match.donorPhotoUrl)
                        : null,
                    child: match.donorPhotoUrl.isEmpty
                        ? Icon(Icons.woman, size: 30, color: AppColors.secondary)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.donorName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Óvulos disponíveis: ${match.eggCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // --- BARRAS DE COMPATIBILIDADE ADICIONADAS ---

              // Barra de Compatibilidade Fenotípica
              _buildProgressBar(
                context: context,
                label: "Compatibilidade (Dados)",
                value: match.phenotypePercentage,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),

              // Barra de Compatibilidade Facial
              _buildProgressBar(
                context: context,
                label: "Similaridade (Facial)",
                value: match.photoPercentage,
                color: Colors.purple,
              ),

              const Divider(height: 24),

              // Barra de Compatibilidade Geral
              Text(
                "Match Geral",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: match.finalCompatibilityPercentage / 100,
                minHeight: 8, // Barra mais grossa para destaque
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCompatibilityColor(match.finalCompatibilityPercentage),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${match.finalCompatibilityPercentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getCompatibilityColor(match.finalCompatibilityPercentage),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget auxiliar para criar as barras de progresso individuais
  Widget _buildProgressBar({
    required BuildContext context,
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Retorna a cor para a barra de compatibilidade geral
  Color _getCompatibilityColor(double percentage) {
    if (percentage >= 80) return Colors.green.shade600;
    if (percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}