import 'package:flutter/foundation.dart';

import '../mock_contract/ability.dart';
import '../mock_contract/background.dart';
import '../mock_contract/character_draft.dart';
import '../mock_contract/class_data.dart';
import '../mock_contract/race.dart';
import '../mock_contract/rules_engine.dart';

class AbilityPoolEntry {
  const AbilityPoolEntry({
    required this.id,
    required this.value,
  });

  final String id;
  final int value;

  @override
  bool operator ==(Object other) => other is AbilityPoolEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Шаги мастера — экраны 2–5 PRD (Основа / Характеристики / Навыки / Обзор).
enum WizardStep { basics, abilities, skills, review }

/// Состояние мастера создания персонажа (зона ответственности B).
///
/// Держит весь черновик персонажа, пока он собирается по шагам, и умеет
/// проверять, можно ли перейти к следующему шагу (валидация из FR4/FR8).
class CharacterCreationController extends ChangeNotifier {
  WizardStep _currentStep = WizardStep.basics;
  WizardStep get currentStep => _currentStep;

  // --- Шаг 1: Основа ---------------------------------------------------
  String _name = '';
  String? _raceId;
  String? _classId;
  String? _backgroundId;

  String get name => _name;
  String? get raceId => _raceId;
  String? get classId => _classId;
  String? get backgroundId => _backgroundId;

  RaceOption? get selectedRace => _raceId == null ? null : raceById(_raceId!);
  ClassOption? get selectedClass => _classId == null ? null : classById(_classId!);
  BackgroundOption? get selectedBackground => _backgroundId == null ? null : backgroundById(_backgroundId!);

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void selectRace(String id) {
    _raceId = id;
    notifyListeners();
  }

  void selectClass(String id) {
    _classId = id;
    // Список навыков и лимит зависят от класса — старый выбор мог стать невалидным.
    _selectedSkills.clear();
    notifyListeners();
  }

  void selectBackground(String id) {
    _backgroundId = id;
    notifyListeners();
  }

  bool get canProceedFromBasics =>
      _name.trim().isNotEmpty && _raceId != null && _classId != null && _backgroundId != null;

  // --- Шаг 2: Характеристики -------------------------------------------
  AbilityMethod _abilityMethod = AbilityMethod.standardArray;
  AbilityMethod get abilityMethod => _abilityMethod;

  /// Значения, ещё не распределённые по характеристикам (Standard Array / 4d6).
  final Map<AbilityScore, String?> _poolAssignmentId = {
    for (final a in AbilityScore.values) a: null,
  };
  final List<AbilityPoolEntry> _standardPoolEntries = [
    for (var i = 0; i < standardArrayValues.length; i++)
      AbilityPoolEntry(id: 'standard-$i', value: standardArrayValues[i]),
  ];
  List<AbilityPoolEntry> _rolledPoolEntries = const [];

  final Map<AbilityScore, int> _pointBuyScores = {for (final a in AbilityScore.values) a: pointBuyMinScore};

  void setAbilityMethod(AbilityMethod method) {
    _abilityMethod = method;
    for (final a in AbilityScore.values) {
      _poolAssignmentId[a] = null;
    }
    _rolledPoolEntries = const [];
    for (final a in AbilityScore.values) {
      _pointBuyScores[a] = pointBuyMinScore;
    }
    notifyListeners();
  }

  List<AbilityPoolEntry> get _currentPoolEntries =>
      _abilityMethod == AbilityMethod.standardArray ? _standardPoolEntries : _rolledPoolEntries;

  List<String> get currentPool => _currentPoolEntries
      .where((entry) => !_assignedIds.contains(entry.id))
      .map((entry) => entry.value.toString())
      .toList();

  void rollAbilityPoolValues() {
    final rolledValues = rollAbilityPool();
    _rolledPoolEntries = [
      for (var i = 0; i < rolledValues.length; i++)
        AbilityPoolEntry(id: 'rolled-$i', value: rolledValues[i]),
    ];
    for (final a in AbilityScore.values) {
      _poolAssignmentId[a] = null;
    }
    notifyListeners();
  }

  /// Значения пула, ещё доступные для назначения этой характеристике
  /// (плюс уже назначенное ей значение, чтобы dropdown мог его показать).
  List<AbilityPoolEntry> availablePoolEntriesFor(AbilityScore ability) {
    final ownId = _poolAssignmentId[ability];
    return _currentPoolEntries.where((entry) {
      final assignedElsewhere = _poolAssignmentId.entries.any(
        (pair) => pair.key != ability && pair.value == entry.id,
      );
      return !assignedElsewhere || entry.id == ownId;
    }).toList();
  }

  List<int> availableValuesFor(AbilityScore ability) =>
      availablePoolEntriesFor(ability).map((entry) => entry.value).toList();

  AbilityPoolEntry? poolEntryFor(AbilityScore ability) {
    final id = _poolAssignmentId[ability];
    if (id == null) {
      return null;
    }
    for (final entry in _currentPoolEntries) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  int? poolValueFor(AbilityScore ability) => poolEntryFor(ability)?.value;

  void assignPoolValue(AbilityScore ability, int? value) {
    if (value == null) {
      assignPoolEntry(ability, null);
      return;
    }

    final entry = availablePoolEntriesFor(ability).firstWhere(
      (candidate) => candidate.value == value,
      orElse: () => AbilityPoolEntry(id: 'missing-$value', value: value),
    );
    assignPoolEntry(ability, entry.id.startsWith('missing-') ? null : entry);
  }

  void assignPoolEntry(AbilityScore ability, AbilityPoolEntry? entry) {
    _poolAssignmentId[ability] = entry?.id;
    notifyListeners();
  }

  int pointBuyScoreFor(AbilityScore ability) => _pointBuyScores[ability]!;

  int get pointBuySpent => pointBuyTotalCost(_pointBuyScores);
  int get pointBuyRemaining => pointBuyBudget - pointBuySpent;

  bool setPointBuyScore(AbilityScore ability, int score) {
    if (score < pointBuyMinScore || score > pointBuyMaxScore) return false;
    final next = Map<AbilityScore, int>.from(_pointBuyScores)..[ability] = score;
    if (pointBuyTotalCost(next) > pointBuyBudget) return false;
    _pointBuyScores[ability] = score;
    notifyListeners();
    return true;
  }

  /// Базовые характеристики (до расовых бонусов) для текущего метода.
  /// Для методов на пуле незаполненные слоты временно считаются как 8.
  Map<AbilityScore, int> get baseAbilities {
    if (_abilityMethod == AbilityMethod.pointBuy) {
      return Map.unmodifiable(_pointBuyScores);
    }
    return {
      for (final a in AbilityScore.values)
        a: poolValueFor(a) ?? pointBuyMinScore,
    };
  }

  Map<AbilityScore, int> get finalAbilities {
    final race = selectedRace;
    if (race == null) return baseAbilities;
    return applyRacialBonuses(baseAbilities, race);
  }

  int modifierFor(AbilityScore ability) => abilityModifier(finalAbilities[ability]!);

  bool get canProceedFromAbilities {
    if (_abilityMethod == AbilityMethod.pointBuy) return true;
    return _currentPoolEntries.isNotEmpty &&
        AbilityScore.values.every((a) => _poolAssignmentId[a] != null);
  }

  // --- Шаг 3: Навыки -----------------------------------------------------
  final Set<String> _selectedSkills = {};

  List<String> get backgroundSkillIds => selectedBackground?.skillIds ?? const [];

  int get classSkillChoiceCount => selectedClass?.skillChoiceCount ?? 0;

  List<String> get availableClassSkillIds => selectedClass?.availableSkillIds ?? const [];

  Set<String> get selectedClassSkills => Set.unmodifiable(_selectedSkills);

  bool isSkillFromBackground(String skillId) => backgroundSkillIds.contains(skillId);

  bool isSkillSelected(String skillId) =>
      isSkillFromBackground(skillId) || _selectedSkills.contains(skillId);

  void toggleSkill(String skillId) {
    if (isSkillFromBackground(skillId)) return; // фиксировано предысторией
    if (_selectedSkills.contains(skillId)) {
      _selectedSkills.remove(skillId);
    } else {
      if (_selectedSkills.length >= classSkillChoiceCount) return;
      _selectedSkills.add(skillId);
    }
    notifyListeners();
  }

  /// Итоговый набор владений навыками: выбор класса + предыстория, без дублей.
  Set<String> get skillProficiencies => {..._selectedSkills, ...backgroundSkillIds};

  bool get canProceedFromSkills => _selectedSkills.length == classSkillChoiceCount;

  // --- Шаг 4: Обзор --------------------------------------------------------
  String _biography = '';
  String get biography => _biography;
  void setBiography(String value) {
    _biography = value;
    notifyListeners();
  }

  List<AbilityScore> get savingThrowProficiencies => selectedClass?.savingThrows ?? const [];

  int get maxHp {
    final cls = selectedClass;
    if (cls == null) return 0;
    return maxHpLevel1(hitDie: cls.hitDie, conModifier: modifierFor(AbilityScore.constitution));
  }

  Set<String> get _assignedIds =>
      _poolAssignmentId.values.whereType<String>().toSet();

  CharacterDraft buildDraft() {
    return CharacterDraft(
      name: _name.trim(),
      level: 1,
      raceId: _raceId!,
      classId: _classId!,
      backgroundId: _backgroundId!,
      abilityMethod: _abilityMethod,
      baseAbilities: baseAbilities,
      skillProficiencies: skillProficiencies,
      savingThrowProficiencies: savingThrowProficiencies,
      maxHp: maxHp,
      currentHp: maxHp,
      biography: _biography.trim(),
    );
  }

  // --- Навигация -----------------------------------------------------------
  bool get canProceedFromCurrentStep => switch (_currentStep) {
        WizardStep.basics => canProceedFromBasics,
        WizardStep.abilities => canProceedFromAbilities,
        WizardStep.skills => canProceedFromSkills,
        WizardStep.review => true,
      };

  void nextStep() {
    if (!canProceedFromCurrentStep) return;
    final steps = WizardStep.values;
    final i = steps.indexOf(_currentStep);
    if (i < steps.length - 1) {
      _currentStep = steps[i + 1];
      notifyListeners();
    }
  }

  void previousStep() {
    final steps = WizardStep.values;
    final i = steps.indexOf(_currentStep);
    if (i > 0) {
      _currentStep = steps[i - 1];
      notifyListeners();
    }
  }
}
