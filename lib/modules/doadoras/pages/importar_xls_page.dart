import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportarDoadorasPage extends StatelessWidget {
  const ImportarDoadorasPage({Key? key}) : super(key: key);

  Future<void> _importarDoadoras(BuildContext context) async {
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

      // IMPORTANTE: Assumimos que a primeira linha (índice 0) contém os cabeçalhos
      // e que os dados das doadoras começam na segunda linha (índice 1).
      // A ordem dos índices abaixo CORRESPONDE EXATAMENTE À ORDEM DOS CABEÇALHOS
      // NA SUA STRING "idnomeCompletofotoPerfil..."
      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        List<Data?> row = sheet.row(rowIndex);

        // Mapeamento dos campos da planilha para as variáveis locais
        // Lembre-se: índices de lista começam em 0.
        // Cuidado com o "painelGenetico" que estava no código anterior mas não na lista exata.
        // Se ele não estiver na sua planilha, esse campo no Firestore ficará vazio.
        final String id = row[0]?.value?.toString() ?? '';
        final String nomeCompleto = row[1]?.value?.toString() ?? '';
        final String fotoPerfil = row[2]?.value?.toString() ?? '';
        final String observacao = row[3]?.value?.toString() ?? '';
        final String idade = row[4]?.value?.toString() ?? '';
        final String peso1 = row[5]?.value?.toString() ?? ''; // Usando peso1
        final String altura1 = row[6]?.value?.toString() ?? ''; // Usando altura1
        final String tipoSanguineo1 = row[7]?.value?.toString() ?? ''; // Usando tipoSanguineo1
        final String corOlhos1 = row[8]?.value?.toString() ?? ''; // Usando corOlhos1
        final String corCabelo1 = row[9]?.value?.toString() ?? ''; // Usando corCabelo1
        final String tipoCabelo1 = row[10]?.value?.toString() ?? ''; // Usando tipoCabelo1
        final String raca1 = row[11]?.value?.toString() ?? ''; // Usando raca1
        final String signo = row[12]?.value?.toString() ?? '';
        final String escalaFitzpatric = row[13]?.value?.toString() ?? ''; // Mapeado de "escalaFitzpatric"
        final String formatoRosto = row[14]?.value?.toString() ?? '';
        final String profissao = row[15]?.value?.toString() ?? '';
        final String hobby = row[16]?.value?.toString() ?? '';
        final String atividadeFisica = row[17]?.value?.toString() ?? '';
        final String escolaridade = row[18]?.value?.toString() ?? '';
        final String estadoCivil = row[19]?.value?.toString() ?? '';
        final String filhos = row[20]?.value?.toString() ?? '';
        final String irmaos = row[21]?.value?.toString() ?? '';
        final String filhoAdotivo = row[22]?.value?.toString() ?? '';
        final String gemeosNaFamilia = row[23]?.value?.toString() ?? '';
        final String qualidades = row[24]?.value?.toString() ?? '';
        final String saudeAudicao = row[25]?.value?.toString() ?? '';
        final String saudeVisao = row[26]?.value?.toString() ?? '';
        final String saudeAlergia = row[27]?.value?.toString() ?? '';
        final String saudeAsma = row[28]?.value?.toString() ?? '';
        final String saudeCronica = row[29]?.value?.toString() ?? '';
        final String saudeFumante = row[30]?.value?.toString() ?? '';
        final String saudeDrogas = row[31]?.value?.toString() ?? '';
        final String saudeAlcool = row[32]?.value?.toString() ?? '';
        final String familiaAutismo = row[33]?.value?.toString() ?? '';
        final String familiaDepressao = row[34]?.value?.toString() ?? '';
        final String familiaEsquizofrenia = row[35]?.value?.toString() ?? '';
        final String familiaAnemiaFalciforme = row[36]?.value?.toString() ?? '';
        final String familiaTalassemia = row[37]?.value?.toString() ?? '';
        final String familiaFibroseCistica = row[38]?.value?.toString() ?? '';
        final String familiaDiabetesMellitus = row[39]?.value?.toString() ?? '';
        final String familiaEpilepsia = row[40]?.value?.toString() ?? '';
        final String familiaHipertensao = row[41]?.value?.toString() ?? '';
        final String familiaDistrofiaMuscular = row[42]?.value?.toString() ?? '';
        final String familiaAtrofiaMuscular = row[43]?.value?.toString() ?? '';
        final String familiaDoencaIsquemica = row[44]?.value?.toString() ?? '';
        final String familiaNeoplasias = row[45]?.value?.toString() ?? '';
        final String familiaDeficienciaFisica = row[46]?.value?.toString() ?? '';
        final String familiaDeficienciaMental = row[47]?.value?.toString() ?? '';
        final String familiaDoencasGeneticas = row[48]?.value?.toString() ?? '';
        final String saudeDoadoraHipertencao = row[49]?.value?.toString() ?? '';
        final String saudeDoadoraDiabetesMelitus = row[50]?.value?.toString() ?? '';
        final String saudeDoadoraEpilepsia = row[51]?.value?.toString() ?? '';
        final String saudeDoadoraDeficienciaFisica = row[52]?.value?.toString() ?? '';
        final String saudeDoadoraDoencasGeneticas = row[53]?.value?.toString() ?? '';
        final String saudeDoadoraNeoplasias = row[54]?.value?.toString() ?? '';
        final String saudeDoadoraLabioLeporino = row[55]?.value?.toString() ?? '';
        final String saudeDoadoraEspinhaBifida = row[56]?.value?.toString() ?? '';
        final String saudeDoadoraDeficienciaMental = row[57]?.value?.toString() ?? '';

        // campo exames — transforma string separada por vírgulas em List<String>
        final String examesString = row[58]?.value?.toString() ?? '';
        final List<String> exames = examesString.split(',').map((e) => e.trim()).toList();

        final String saudeDoadoraMalformacaoCardiaca = row[59]?.value?.toString() ?? '';
        final String status = row[60]?.value?.toString() ?? '';
        final String assinatura = row[61]?.value?.toString() ?? '';
        final String email = row[62]?.value?.toString() ?? '';
        final String telefone = row[63]?.value?.toString() ?? '';
        final String cpf = row[64]?.value?.toString() ?? '';
        final String rg = row[65]?.value?.toString() ?? '';
        final String cep = row[66]?.value?.toString() ?? '';
        final String endereco = row[67]?.value?.toString() ?? '';
        final String cidade = row[68]?.value?.toString() ?? '';
        final String estado = row[69]?.value?.toString() ?? '';
        final String dob = row[70]?.value?.toString() ?? ''; // Data de Nascimento
        final String medicoAssistente = row[71]?.value?.toString() ?? '';
        final String motivo = row[72]?.value?.toString() ?? '';
        final String declaroVeracidade = row[73]?.value?.toString() ?? '';
        final String caracteristicas1 = row[74]?.value?.toString() ?? '';

        // Montar o documento para o Firestore
        final doadoraData = {
          'id': id,
          'nomeCompleto': nomeCompleto,
          'fotoPerfil': fotoPerfil,
          'observacao': observacao,
          'idade': idade,
          'peso1': peso1, // Usando o nome exato do campo da planilha
          'altura1': altura1, // Usando o nome exato do campo da planilha
          'tipoSanguineo1': tipoSanguineo1, // Usando o nome exato do campo da planilha
          'corOlhos1': corOlhos1, // Usando o nome exato do campo da planilha
          'corCabelo1': corCabelo1, // Usando o nome exato do campo da planilha
          'tipoCabelo1': tipoCabelo1, // Usando o nome exato do campo da planilha
          'raca1': raca1, // Usando o nome exato do campo da planilha
          'signo': signo,
          // Se 'painelGenetico' não está na lista exata, pode não ser preenchido
          // ou você pode ter que adicionar a um índice. Mantenho como um lembrete.
          // 'painelGenetico': painelGenetico,
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
          'saudeDoadoraHipertencao': saudeDoadoraHipertencao,
          'saudeDoadoraDiabetesMelitus': saudeDoadoraDiabetesMelitus,
          'saudeDoadoraEpilepsia': saudeDoadoraEpilepsia,
          'saudeDoadoraDeficienciaFisica': saudeDoadoraDeficienciaFisica,
          'saudeDoadoraDoencasGeneticas': saudeDoadoraDoencasGeneticas,
          'saudeDoadoraNeoplasias': saudeDoadoraNeoplasias,
          'saudeDoadoraLabioLeporino': saudeDoadoraLabioLeporino,
          'saudeDoadoraEspinhaBifida': saudeDoadoraEspinhaBifida,
          'saudeDoadoraDeficienciaMental': saudeDoadoraDeficienciaMental,
          'exames': exames,
          'saudeDoadoraMalformacaoCardiaca': saudeDoadoraMalformacaoCardiaca,
          'status': status == '' ? 'Pendente Punção' : status, // Lógica para status vazio
          'assinatura': assinatura,
          'email': email,
          'telefone': telefone,
          'cpf': cpf,
          'rg': rg,
          'cep': cep,
          'endereco': endereco,
          'cidade': cidade,
          'estado': estado,
          'dob': dob,
          'medicoAssistente': medicoAssistente,
          'motivo': motivo,
          'declaroVeracidade': declaroVeracidade,
          'caracteristicas1': caracteristicas1,
          'importedAt': FieldValue.serverTimestamp(), // Adiciona um timestamp de importação
        };

        // Adiciona o documento ao Firestore. Usando o 'id' da planilha como ID do documento.
        // Se 'id' for vazio ou você quiser que o Firebase gere um ID, use .add(doadoraData)
        // Se 'id' da planilha for único e você quer que ele seja o ID do documento, use .doc(id).set(doadoraData)
        if (id.isNotEmpty) {
          await FirebaseFirestore.instance.collection('doadoras').doc(id).set(doadoraData);
        } else {
          // Se o ID da planilha for vazio, o Firebase gera um ID automaticamente
          await FirebaseFirestore.instance.collection('doadoras').add(doadoraData);
        }
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
        label: const Text('Importar Doadoras XLS/XLSX'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16),
        ),
        onPressed: () => _importarDoadoras(context),
      ),
    );
  }
}