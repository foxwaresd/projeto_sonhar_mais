class Pergunta {
  String id;
  String texto;
  String tipo;
  List<String> opcoes;
  int ordem;
  bool ativa;

  Pergunta({
    required this.id,
    required this.texto,
    required this.tipo,
    required this.opcoes,
    required this.ordem,
    required this.ativa,
  });

  Map<String, dynamic> toMap() {
    return {
      'texto': texto,
      'tipo': tipo,
      'opcoes': opcoes,
      'ordem': ordem,
      'ativa': ativa,
    };
  }

  factory Pergunta.fromMap(String id, Map<String, dynamic> map) {
    return Pergunta(
      id: id,
      texto: map['texto'],
      tipo: map['tipo'],
      opcoes: List<String>.from(map['opcoes'] ?? []),
      ordem: map['ordem'],
      ativa: map['ativa'],
    );
  }
}
