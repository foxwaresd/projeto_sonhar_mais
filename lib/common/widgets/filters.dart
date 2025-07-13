// lib/modules/doadoras/models/filter_options.dart
// (Create a new folder 'models' inside 'doadoras')

class FilterOption {
  final String label;
  final String value;

  FilterOption({required this.label, required this.value});
}

class FilterCategory {
  final String title;
  final List<FilterOption> options;
  final String attributeName; // Corresponds to the Doadora attribute

  FilterCategory({
    required this.title,
    required this.options,
    required this.attributeName,
  });

  static List<FilterCategory> get allCategories => [
    FilterCategory(
      title: 'Tipo Sanguíneo',
      attributeName: 'tipoSanguineo1',
      options: [
        FilterOption(label: 'A+', value: 'A+'),
        FilterOption(label: 'A-', value: 'A-'),
        FilterOption(label: 'B+', value: 'B+'),
        FilterOption(label: 'B-', value: 'B-'),
        FilterOption(label: 'AB+', value: 'AB+'),
        FilterOption(label: 'AB-', value: 'AB-'),
        FilterOption(label: 'O+', value: 'O+'),
        FilterOption(label: 'O-', value: 'O-'),
      ],
    ),
    FilterCategory(
      title: 'Cor dos Olhos',
      attributeName: 'corOlhos1',
      options: [
        FilterOption(label: 'PRETO', value: 'PRETO'),
        FilterOption(label: 'CASTANHO ESCURO', value: 'CASTANHO ESCURO'),
        FilterOption(label: 'CASTANHO CLARO', value: 'CASTANHO CLARO'),
        FilterOption(label: 'MEL', value: 'MEL'),
        FilterOption(label: 'VERDE', value: 'VERDE'),
        FilterOption(label: 'AZUL', value: 'AZUL'),
        FilterOption(label: 'CINZA', value: 'CINZA'),
      ],
    ),
    FilterCategory(
      title: 'Cor de Cabelo',
      attributeName: 'corCabelo1',
      options: [
        FilterOption(label: 'PRETO', value: 'PRETO'),
        FilterOption(label: 'CASTANHO ESCURO', value: 'CASTANHO ESCURO'),
        FilterOption(label: 'CASTANHO MÉDIO', value: 'CASTANHO MÉDIO'),
        FilterOption(label: 'CASTANHO CLARO', value: 'CASTANHO CLARO'),
        FilterOption(label: 'LOIRO ESCURO', value: 'LOIRO ESCURO'),
        FilterOption(label: 'LOIRO MÉDIO', value: 'LOIRO MÉDIO'),
        FilterOption(label: 'LOIRO CLARO', value: 'LOIRO CLARO'),
        FilterOption(label: 'RUIVO', value: 'RUIVO'),
      ],
    ),
    FilterCategory(
      title: 'Tipo de Cabelo',
      attributeName: 'tipoCabelo1',
      options: [
        FilterOption(label: '1A - LISO', value: '1A - LISO'),
        FilterOption(label: '1B - LISO', value: '1B - LISO'),
        FilterOption(label: '1C - LISO', value: '1C - LISO'),
        FilterOption(label: '2A - ONDULADO', value: '2A - ONDULADO'),
        FilterOption(label: '2B - ONDULADO', value: '2B - ONDULADO'),
        FilterOption(label: '2C - ONDULADO', value: '2C - ONDULADO'),
        FilterOption(label: '3A - CACHEADO', value: '3A - CACHEADO'),
        FilterOption(label: '3B - CACHEADO', value: '3B - CACHEADO'),
        FilterOption(label: '3C - CACHEADO', value: '3C - CACHEADO'),
        FilterOption(label: '4A - CRESPO', value: '4A - CRESPO'),
        FilterOption(label: '4B - CRESPO', value: '4B - CRESPO'),
        FilterOption(label: '4C - CRESPO', value: '4C - CRESPO'),
      ],
    ),
    FilterCategory(
      title: 'Cor da Pele (Escala Fitzpatrick)',
      attributeName: 'fitzpatrick',
      options: [
        FilterOption(label: '1.1 - SEMPRE QUEIMA; NUNCA BRONZEIA', value: '1.1'),
        FilterOption(label: '1.2 - SEMPRE QUEIMA; NUNCA BRONZEIA', value: '1.2'),
        FilterOption(label: '1.3 - SEMPRE QUEIMA; NUNCA BRONZEIA', value: '1.3'),
        FilterOption(label: '1.4 - SEMPRE QUEIMA; NUNCA BRONZEIA', value: '1.4'),
        FilterOption(label: '2.1 - MUITO FREQUENTEMENTE QUEIMA; BRONZEIA COM DIFICULDADE', value: '2.1'),
        FilterOption(label: '2.2 - MUITO FREQUENTEMENTE QUEIMA; BRONZEIA COM DIFICULDADE', value: '2.2'),
        FilterOption(label: '2.3 - MUITO FREQUENTEMENTE QUEIMA; BRONZEIA COM DIFICULDADE', value: '2.3'),
        FilterOption(label: '2.4 - MUITO FREQUENTEMENTE QUEIMA; BRONZEIA COM DIFICULDADE', value: '2.4'),
        FilterOption(label: '3.1 - FREQUENTEMENTE QUEIMA; BRONZEIA SEM MUITA DIFICULDADE', value: '3.1'),
        FilterOption(label: '3.2 - FREQUENTEMENTE QUEIMA; BRONZEIA SEM MUITA DIFICULDADE', value: '3.2'),
        FilterOption(label: '3.3 - FREQUENTEMENTE QUEIMA; BRONZEIA SEM MUITA DIFICULDADE', value: '3.3'),
        FilterOption(label: '3.4 - FREQUENTEMENTE QUEIMA; BRONZEIA SEM MUITA DIFICULDADE', value: '3.4'),
        FilterOption(label: '4.1 - DIFICILMENTE QUEIMA; BRONZEIA FACILMENTE', value: '4.1'),
        FilterOption(label: '4.2 - DIFICILMENTE QUEIMA; BRONZEIA FACILMENTE', value: '4.2'),
        FilterOption(label: '4.3 - DIFICILMENTE QUEIMA; BRONZEIA FACILMENTE', value: '4.3'),
        FilterOption(label: '4.4 - DIFICILMENTE QUEIMA; BRONZEIA FACILMENTE', value: '4.4'),
        FilterOption(label: '5.1 - MUITO DIFICILMENTE QUEIMA; BRONZEIA MUITO FACILMENTE', value: '5.1'),
        FilterOption(label: '5.2 - MUITO DIFICILMENTE QUEIMA; BRONZEIA MUITO FACILMENTE', value: '5.2'),
        FilterOption(label: '5.3 - MUITO DIFICILMENTE QUEIMA; BRONZEIA MUITO FACILMENTE', value: '5.3'),
        FilterOption(label: '5.4 - MUITO DIFICILMENTE QUEIMA; BRONZEIA MUITO FACILMENTE', value: '5.4'),
        FilterOption(label: '6.1 - RARAMENTE QUEIMA', value: '6.1'),
        FilterOption(label: '6.2 - RARAMENTE QUEIMA', value: '6.2'),
        FilterOption(label: '6.3 - RARAMENTE QUEIMA', value: '6.3'),
        FilterOption(label: '6.4 - RARAMENTE QUEIMA', value: '6.4'),
      ],
    ),
    FilterCategory(
      title: 'Raça',
      attributeName: 'raca1',
      options: [
        FilterOption(label: 'INDÍGENA', value: 'INDÍGENA'),
        FilterOption(label: 'INDIANA', value: 'INDIANA'),
        FilterOption(label: 'LATINA', value: 'LATINA'),
        FilterOption(label: 'ORIENTE MÉDIO', value: 'ORIENTE MÉDIO'),
        FilterOption(label: 'AFRICANA', value: 'AFRICANA'),
        FilterOption(label: 'ASIÁTICA', value: 'ASIÁTICA'),
        FilterOption(label: 'EUROPEIA', value: 'EUROPEIA'),
      ],
    ),
  ];
}