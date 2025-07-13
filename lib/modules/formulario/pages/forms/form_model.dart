class Formulario {
  final String id;
  final String nome;
  final List<String> emails;
  final String collectionName; // New field

  Formulario({
    required this.id,
    required this.nome,
    this.emails = const [],
    required this.collectionName, // Must be required or have a default
  });

  Formulario copyWith({String? id, String? nome, List<String>? emails, String? collectionName}) {
    return Formulario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      emails: emails ?? this.emails,
      collectionName: collectionName ?? this.collectionName, // Copy the new field
    );
  }
}