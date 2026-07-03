// MOCK CONTRACT — см. ability.dart. Предыстории, раздел 7.9 PRD.

class BackgroundOption {
  final String id;
  final String nameRu;
  final List<String> skillIds; // ровно 2, фиксированные владения

  const BackgroundOption({required this.id, required this.nameRu, required this.skillIds});
}

const List<BackgroundOption> mockBackgrounds = [
  BackgroundOption(id: 'soldier', nameRu: 'Солдат', skillIds: ['athletics', 'intimidation']),
  BackgroundOption(id: 'acolyte', nameRu: 'Аколит', skillIds: ['insight', 'religion']),
  BackgroundOption(id: 'criminal', nameRu: 'Преступник', skillIds: ['deception', 'stealth']),
  BackgroundOption(id: 'sage', nameRu: 'Мудрец', skillIds: ['arcana', 'history']),
];

BackgroundOption backgroundById(String id) => mockBackgrounds.firstWhere((b) => b.id == id);
