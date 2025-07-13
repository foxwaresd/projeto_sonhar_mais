import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BancoOvulosPage extends StatefulWidget {
  const BancoOvulosPage({super.key});

  @override
  State<BancoOvulosPage> createState() => _BancoOvulosPageState();
}

class _BancoOvulosPageState extends State<BancoOvulosPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeFantasiaController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  void _salvarEmpresa() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseFirestore.instance.collection('empresas').add({
        'nomeFantasia': _nomeFantasiaController.text.trim(),
        'cnpj': _cnpjController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(), // data do cadastro
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados da empresa salvos com sucesso!')),
      );

      _nomeFantasiaController.clear();
      _cnpjController.clear();
      _enderecoController.clear();
      _telefoneController.clear();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao salvar dados: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  void dispose() {
    _nomeFantasiaController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            TextFormField(
              controller: _nomeFantasiaController,
              decoration: const InputDecoration(labelText: 'Nome Fantasia'),
              validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
            ),
            TextFormField(
              controller: _cnpjController,
              decoration: const InputDecoration(labelText: 'CNPJ'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obrigatório';
                // Você pode colocar validação simples do CNPJ aqui
                if (v.length != 14) return 'CNPJ deve ter 14 dígitos';
                return null;
              },
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _enderecoController,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            TextFormField(
              controller: _telefoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _salvarEmpresa,
              child: const Text('Salvar Dados'),
            ),
          ],
        ),
      ),
    );
  }
}
