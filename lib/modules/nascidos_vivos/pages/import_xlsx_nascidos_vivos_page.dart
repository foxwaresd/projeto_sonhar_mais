import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImportXlsxNascidosVivosPage extends StatefulWidget {
  const ImportXlsxNascidosVivosPage({Key? key}) : super(key: key);

  @override
  State<ImportXlsxNascidosVivosPage> createState() => _ImportXlsxNascidosVivosPageState();
}

class _ImportXlsxNascidosVivosPageState extends State<ImportXlsxNascidosVivosPage> {
  String? _selectedFileName;

  void _importXlsxFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
      });

      // Aqui você pode processar o arquivo conforme necessário:
      // - Usar excel.dart para ler os dados
      // - Fazer upload para servidor, etc.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arquivo "${result.files.single.name}" importado com sucesso!')),
      );
    } else {
      // Usuário cancelou
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importação cancelada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Planilha XLSX'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Selecione um arquivo XLSX conforme o formato exigido:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.file_upload),
              label: const Text('Selecionar Arquivo'),
              onPressed: _importXlsxFile,
            ),
            const SizedBox(height: 20),
            if (_selectedFileName != null)
              Text(
                'Arquivo selecionado: $_selectedFileName',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Formato da planilha esperado:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''
INFORMAÇÕES GERAIS
- paciente
- id
- medico

INFORMAÇÕES AMOSTRA
- dataUsoAmostra
- procedimento

INFORMAÇÕES ÓVULOS
- Nº de óvulos descongelados
- Nº de óvulos sobreviventes
- Nº de óvulos utilizados
- Nº de blastocistos
- N° de embriões congelados

TRANSFERÊNCIA 1 a 4
- Dia de cultivo
- Data da TE
- Cidade/Estado (Receptora)
- Nº de embriões congelados restantes
- gestação clínica
- gestação química
- aborto
- tipo de gestação
- bebês nascidos
- natimorto
- malformações
- peso
- altura
- sexo
- OBS

TRANSPORTES
- Transporte para outra clínica
- Data
- Nome da clínica
- tipo material
- quantidade
                  ''',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            label: 'Voltar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Importar',
          ),
        ],
      ),
    );
  }
}
