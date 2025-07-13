
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportXlsPage extends StatelessWidget {
  const ImportXlsPage({Key? key}) : super(key: key);

  Future<void> _importarXls(BuildContext context) async {
    try {
      // Abrir seletor de arquivos para escolher .xls ou .xlsx
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
      );

      if (result == null || result.files.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum arquivo selecionado.')),
        );
        return;
      }

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao ler arquivo selecionado.')),
        );
        return;
      }

      // Mostrar mensagem inicial
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importação iniciada...')),
      );

      // Ler arquivo Excel
      var excel = Excel.decodeBytes(fileBytes);

      // Exemplo: ler a primeira planilha
      String firstSheet = excel.tables.keys.first;
      var sheet = excel.tables[firstSheet];

      if (sheet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Planilha vazia ou inválida.')),
        );
        return;
      }

      // Iterar pelas linhas (pulando o cabeçalho na linha 0)
      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        List<Data?> row = sheet.row(rowIndex);

        // Supondo que a planilha tenha colunas: Nome (0), Email (1), Telefone (2)
        final id = row[0]?.value?.toString() ?? '';
        final nome = row[1]?.value?.toString() ?? '';
        final ovulos = row[2]?.value?.toString() ?? '';

        if (nome.isNotEmpty) {
          // Salvar no Firestore coleção 'bancoOvulos'
          await FirebaseFirestore.instance.collection('bancoOvulos').add({
            'nome': nome,
            'id': id,
            'ovulos': ovulos,
            'importedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo importado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na importação: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.upload_file),
        label: const Text('Importar Planilha XLS/XLSX'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () => _importarXls(context),
      ),
    );
  }
}
