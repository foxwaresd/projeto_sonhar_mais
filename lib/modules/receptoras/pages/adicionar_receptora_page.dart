import 'package:flutter/material.dart';

class AdicionarReceptoraPage extends StatefulWidget {
  const AdicionarReceptoraPage({Key? key}) : super(key: key);

  @override
  State<AdicionarReceptoraPage> createState() => _AdicionarReceptoraPageState();
}

class _AdicionarReceptoraPageState extends State<AdicionarReceptoraPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final campos = [
      'nome', 'foto', 'observacao', 'idade', 'peso', 'altura', 'tipoSanguineo',
      'olhos', 'cabeloCor', 'cabeloTextura', 'raca', 'signo', 'painelGenetico',
      'escalaFitzpatric', 'formatoRosto', 'profissao', 'hobby', 'atividadeFisica',
      'escolaridade', 'estadoCivil', 'filhos', 'irmaos', 'filhoAdotivo', 'gemeosNaFamilia',
      'qualidades', 'saudeAudicao', 'saudeVisao', 'saudeAlergia', 'saudeAsma', 'saudeCronica',
      'saudeFumante', 'saudeDrogas', 'saudeAlcool', 'familiaAutismo', 'familiaDepressao',
      'familiaEsquizofrenia', 'familiaAnemiaFalciforme', 'familiaTalassemia', 'familiaFibroseCistica',
      'familiaDiabetesMellitus', 'familiaEpilepsia', 'familiaHipertensao', 'familiaDistrofiaMuscular',
      'familiaAtrofiaMuscular', 'familiaDoencaIsquemica', 'familiaNeoplasias', 'familiaDeficienciaFisica',
      'familiaDeficienciaMental', 'familiaDoencasGeneticas', 'saudereceptoraHipertencao',
      'saudereceptoraDiabetesMelitus', 'saudereceptoraEpilepsia', 'saudereceptoraDeficienciaFisica',
      'saudereceptoraDoencasGeneticas', 'saudereceptoraNeoplasias', 'saudereceptoraLabioLeporino',
      'saudereceptoraEspinhaBifida', 'saudereceptoraDeficienciaMental', 'saudereceptoraMalformacaoCardiaca',
    ];

    for (var campo in campos) {
      _controllers[campo] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _salvarreceptora() {
    if (_formKey.currentState!.validate()) {
      final data = _controllers.map((key, value) => MapEntry(key, value.text));
      print(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('receptora salva com sucesso!')),
      );

      _formKey.currentState!.reset();
      for (var controller in _controllers.values) {
        controller.clear();
      }
    }
  }

  /// Função para converter camelCase para Label com espaços e primeira letra maiúscula.
  String _formatLabel(String camelCase) {
    final regex = RegExp(r'(?<=[a-z])[A-Z]');
    String label = camelCase.replaceAllMapped(regex, (match) => ' ${match.group(0)}');
    return label[0].toUpperCase() + label.substring(1);
  }

  Widget _buildExpandableSection(String title, List<String> fields) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        children: fields.map((field) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextFormField(
              controller: _controllers[field],
              decoration: InputDecoration(labelText: _formatLabel(field)),
              validator: (value) => value == null || value.isEmpty
                  ? 'Informe ${_formatLabel(field)}'
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildExpandableSection('Informações Básicas', [
                'nome', 'foto', 'observacao', 'idade', 'peso', 'altura', 'tipoSanguineo',
                'olhos', 'cabeloCor', 'cabeloTextura', 'raca', 'signo'
              ]),
              _buildExpandableSection('Genética', [
                'painelGenetico', 'escalaFitzpatric', 'formatoRosto'
              ]),
              _buildExpandableSection('Perfil Pessoal', [
                'profissao', 'hobby', 'atividadeFisica', 'escolaridade', 'estadoCivil'
              ]),
              _buildExpandableSection('Informações Familiares', [
                'filhos', 'irmaos', 'filhoAdotivo', 'gemeosNaFamilia', 'qualidades'
              ]),
              _buildExpandableSection('Saúde', [
                'saudeAudicao', 'saudeVisao', 'saudeAlergia', 'saudeAsma', 'saudeCronica',
                'saudeFumante', 'saudeDrogas', 'saudeAlcool'
              ]),
              _buildExpandableSection('Histórico Familiar', [
                'familiaAutismo', 'familiaDepressao', 'familiaEsquizofrenia',
                'familiaAnemiaFalciforme', 'familiaTalassemia', 'familiaFibroseCistica',
                'familiaDiabetesMellitus', 'familiaEpilepsia', 'familiaHipertensao',
                'familiaDistrofiaMuscular', 'familiaAtrofiaMuscular', 'familiaDoencaIsquemica',
                'familiaNeoplasias', 'familiaDeficienciaFisica', 'familiaDeficienciaMental',
                'familiaDoencasGeneticas'
              ]),
              _buildExpandableSection('Saúde da receptora', [
                'saudereceptoraHipertencao', 'saudereceptoraDiabetesMelitus', 'saudereceptoraEpilepsia',
                'saudereceptoraDeficienciaFisica', 'saudereceptoraDoencasGeneticas', 'saudereceptoraNeoplasias',
                'saudereceptoraLabioLeporino', 'saudereceptoraEspinhaBifida', 'saudereceptoraDeficienciaMental',
                'saudereceptoraMalformacaoCardiaca'
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarreceptora,
                child: const Text('Salvar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
