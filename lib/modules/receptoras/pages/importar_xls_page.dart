import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportarReceptorasPage extends StatelessWidget {
  const ImportarReceptorasPage({Key? key}) : super(key: key);

  Future<void> _importarReceptoras(BuildContext context) async {
    try {
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
          const SnackBar(content: Text('Erro ao ler arquivo.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importação iniciada...')),
      );

      var excel = Excel.decodeBytes(fileBytes);
      String firstSheet = excel.tables.keys.first;
      var sheet = excel.tables[firstSheet];

      if (sheet == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Planilha vazia ou inválida.')),
        );
        return;
      }

      // Cabeçalhos conforme sua lista
      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        List<Data?> row = sheet.row(rowIndex);

        final foto = row[0]?.value?.toString() ?? '';
        final nome = row[1]?.value?.toString() ?? '';
        final id = row[2]?.value?.toString() ?? '';
        final observacao = row[3]?.value?.toString() ?? '';
        final idade = row[4]?.value?.toString() ?? '';
        final peso = row[5]?.value?.toString() ?? '';
        final altura = row[6]?.value?.toString() ?? '';
        final tipoSanguineo = row[7]?.value?.toString() ?? '';
        final olhos = row[8]?.value?.toString() ?? '';
        final cabeloCor = row[9]?.value?.toString() ?? '';
        final cabeloTextura = row[10]?.value?.toString() ?? '';
        final raca = row[11]?.value?.toString() ?? '';
        final signo = row[12]?.value?.toString() ?? '';
        final painelGenetico = row[13]?.value?.toString() ?? '';
        final escalaFitzpatric = row[14]?.value?.toString() ?? '';
        final formatoRosto = row[15]?.value?.toString() ?? '';
        final profissao = row[16]?.value?.toString() ?? '';
        final hobby = row[17]?.value?.toString() ?? '';
        final atividadeFisica = row[18]?.value?.toString() ?? '';
        final escolaridade = row[19]?.value?.toString() ?? '';
        final estadoCivil = row[20]?.value?.toString() ?? '';
        final filhos = row[21]?.value?.toString() ?? '';
        final irmaos = row[22]?.value?.toString() ?? '';
        final filhoAdotivo = row[23]?.value?.toString() ?? '';
        final gemeosNaFamilia = row[24]?.value?.toString() ?? '';
        final qualidades = row[25]?.value?.toString() ?? '';
        final saudeAudicao = row[26]?.value?.toString() ?? '';
        final saudeVisao = row[27]?.value?.toString() ?? '';
        final saudeAlergia = row[28]?.value?.toString() ?? '';
        final saudeAsma = row[29]?.value?.toString() ?? '';
        final saudeCronica = row[30]?.value?.toString() ?? '';
        final saudeFumante = row[31]?.value?.toString() ?? '';
        final saudeDrogas = row[32]?.value?.toString() ?? '';
        final saudeAlcool = row[33]?.value?.toString() ?? '';
        final familiaAutismo = row[34]?.value?.toString() ?? '';
        final familiaDepressao = row[35]?.value?.toString() ?? '';
        final familiaEsquizofrenia = row[36]?.value?.toString() ?? '';
        final familiaAnemiaFalciforme = row[37]?.value?.toString() ?? '';
        final familiaTalassemia = row[38]?.value?.toString() ?? '';
        final familiaFibroseCistica = row[39]?.value?.toString() ?? '';
        final familiaDiabetesMellitus = row[40]?.value?.toString() ?? '';
        final familiaEpilepsia = row[41]?.value?.toString() ?? '';
        final familiaHipertensao = row[42]?.value?.toString() ?? '';
        final familiaDistrofiaMuscular = row[43]?.value?.toString() ?? '';
        final familiaAtrofiaMuscular = row[44]?.value?.toString() ?? '';
        final familiaDoencaIsquemica = row[45]?.value?.toString() ?? '';
        final familiaNeoplasias = row[46]?.value?.toString() ?? '';
        final familiaDeficienciaFisica = row[47]?.value?.toString() ?? '';
        final familiaDeficienciaMental = row[48]?.value?.toString() ?? '';
        final familiaDoencasGeneticas = row[49]?.value?.toString() ?? '';
        final saudereceptoraHipertencao = row[50]?.value?.toString() ?? '';
        final saudereceptoraDiabetesMelitus = row[51]?.value?.toString() ?? '';
        final saudereceptoraEpilepsia = row[52]?.value?.toString() ?? '';
        final saudereceptoraDeficienciaFisica = row[53]?.value?.toString() ?? '';
        final saudereceptoraDoencasGeneticas = row[54]?.value?.toString() ?? '';
        final saudereceptoraNeoplasias = row[55]?.value?.toString() ?? '';
        final saudereceptoraLabioLeporino = row[56]?.value?.toString() ?? '';
        final saudereceptoraEspinhaBifida = row[57]?.value?.toString() ?? '';
        final saudereceptoraDeficienciaMental = row[58]?.value?.toString() ?? '';

        // campo exames — transforma string separada por vírgulas em List<String>
        final examesString = row[59]?.value?.toString() ?? '';
        final exames = examesString.split(',').map((e) => e.trim()).toList();

        final saudereceptoraMalformacaoCardiaca = row[60]?.value?.toString() ?? '';

        // Montar o documento
        final receptoraData = {
          'foto': foto,
          'nome': nome,
          'id': id,
          'observacao': observacao,
          'idade': idade,
          'peso': peso,
          'altura': altura,
          'tipoSanguineo': tipoSanguineo,
          'olhos': olhos,
          'cabeloCor': cabeloCor,
          'cabeloTextura': cabeloTextura,
          'raca': raca,
          'signo': signo,
          'painelGenetico': painelGenetico,
          'escalaFitzpatric': escalaFitzpatric,
          'formatoRosto': formatoRosto,
          'profissao': profissao,
          'hobby': hobby,
          'atividadeFisica': atividadeFisica,
          'escolaridade': escolaridade,
          'estadoCivil': estadoCivil,
          'filhos': filhos,
          'irmaos': irmaos,
          'filhoAdotivo': filhoAdotivo,
          'gemeosNaFamilia': gemeosNaFamilia,
          'qualidades': qualidades,
          'saudeAudicao': saudeAudicao,
          'saudeVisao': saudeVisao,
          'saudeAlergia': saudeAlergia,
          'saudeAsma': saudeAsma,
          'saudeCronica': saudeCronica,
          'saudeFumante': saudeFumante,
          'saudeDrogas': saudeDrogas,
          'saudeAlcool': saudeAlcool,
          'familiaAutismo': familiaAutismo,
          'familiaDepressao': familiaDepressao,
          'familiaEsquizofrenia': familiaEsquizofrenia,
          'familiaAnemiaFalciforme': familiaAnemiaFalciforme,
          'familiaTalassemia': familiaTalassemia,
          'familiaFibroseCistica': familiaFibroseCistica,
          'familiaDiabetesMellitus': familiaDiabetesMellitus,
          'familiaEpilepsia': familiaEpilepsia,
          'familiaHipertensao': familiaHipertensao,
          'familiaDistrofiaMuscular': familiaDistrofiaMuscular,
          'familiaAtrofiaMuscular': familiaAtrofiaMuscular,
          'familiaDoencaIsquemica': familiaDoencaIsquemica,
          'familiaNeoplasias': familiaNeoplasias,
          'familiaDeficienciaFisica': familiaDeficienciaFisica,
          'familiaDeficienciaMental': familiaDeficienciaMental,
          'familiaDoencasGeneticas': familiaDoencasGeneticas,
          'saudereceptoraHipertencao': saudereceptoraHipertencao,
          'saudereceptoraDiabetesMelitus': saudereceptoraDiabetesMelitus,
          'saudereceptoraEpilepsia': saudereceptoraEpilepsia,
          'saudereceptoraDeficienciaFisica': saudereceptoraDeficienciaFisica,
          'saudereceptoraDoencasGeneticas': saudereceptoraDoencasGeneticas,
          'saudereceptoraNeoplasias': saudereceptoraNeoplasias,
          'saudereceptoraLabioLeporino': saudereceptoraLabioLeporino,
          'saudereceptoraEspinhaBifida': saudereceptoraEspinhaBifida,
          'saudereceptoraDeficienciaMental': saudereceptoraDeficienciaMental,
          'exames': exames,
          'saudereceptoraMalformacaoCardiaca': saudereceptoraMalformacaoCardiaca,
          'importedAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('receptoras').add(receptoraData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importação concluída com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.upload_file),
        label: const Text('Importar receptoras XLS/XLSX'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () => _importarReceptoras(context),
      ),
    );
  }
}
