import 'package:flutter/material.dart';

class AdicionarNascidoVivoPage extends StatefulWidget {
  const AdicionarNascidoVivoPage({Key? key}) : super(key: key);

  @override
  State<AdicionarNascidoVivoPage> createState() => _AdicionarNascidoVivoPageState();
}

class _AdicionarNascidoVivoPageState extends State<AdicionarNascidoVivoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController pacienteController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController medicoController = TextEditingController();
  final TextEditingController dataUsoController = TextEditingController();
  final TextEditingController procedimentoController = TextEditingController();
  final TextEditingController ovulosDescongeladosController = TextEditingController();
  final TextEditingController ovulosSobreviventesController = TextEditingController();
  final TextEditingController ovulosUtilizadosController = TextEditingController();
  final TextEditingController blastocistosController = TextEditingController();
  final TextEditingController embrioesCongeladosController = TextEditingController();

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      // Aqui vai o código para salvar no banco ou backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nascido vivo adicionado com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Nascido Vivo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: pacienteController,
                decoration: const InputDecoration(labelText: 'Paciente'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'ID'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: medicoController,
                decoration: const InputDecoration(labelText: 'Médico'),
              ),
              TextFormField(
                controller: dataUsoController,
                decoration: const InputDecoration(labelText: 'Data de Uso da Amostra'),
              ),
              TextFormField(
                controller: procedimentoController,
                decoration: const InputDecoration(labelText: 'Procedimento'),
              ),
              TextFormField(
                controller: ovulosDescongeladosController,
                decoration: const InputDecoration(labelText: 'Nº de Óvulos Descongelados'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: ovulosSobreviventesController,
                decoration: const InputDecoration(labelText: 'Nº de Óvulos Sobreviventes'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: ovulosUtilizadosController,
                decoration: const InputDecoration(labelText: 'Nº de Óvulos Utilizados'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: blastocistosController,
                decoration: const InputDecoration(labelText: 'Nº de Blastocistos'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: embrioesCongeladosController,
                decoration: const InputDecoration(labelText: 'Nº de Embriões Congelados'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
