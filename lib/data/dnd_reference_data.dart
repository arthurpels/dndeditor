const dndAbilities = <String>[
  'STR',
  'DEX',
  'CON',
  'INT',
  'WIS',
  'CHA',
];

const dndSkills = <String>[
  'Acrobatics',
  'Animal Handling',
  'Arcana',
  'Athletics',
  'Deception',
  'History',
  'Insight',
  'Intimidation',
  'Investigation',
  'Medicine',
  'Nature',
  'Perception',
  'Performance',
  'Persuasion',
  'Religion',
  'Sleight of Hand',
  'Stealth',
  'Survival',
];

const skillAbilityMap = <String, String>{
  'Athletics': 'STR',
  'Acrobatics': 'DEX',
  'Sleight of Hand': 'DEX',
  'Stealth': 'DEX',
  'Arcana': 'INT',
  'History': 'INT',
  'Investigation': 'INT',
  'Nature': 'INT',
  'Religion': 'INT',
  'Animal Handling': 'WIS',
  'Insight': 'WIS',
  'Medicine': 'WIS',
  'Perception': 'WIS',
  'Survival': 'WIS',
  'Deception': 'CHA',
  'Intimidation': 'CHA',
  'Performance': 'CHA',
  'Persuasion': 'CHA',
};

const raceAbilityBonuses = <String, Map<String, int>>{
  'human': {'STR': 1, 'DEX': 1, 'CON': 1, 'INT': 1, 'WIS': 1, 'CHA': 1},
  'dwarf': {'CON': 2},
  'elf': {'DEX': 2},
  'halfling': {'DEX': 2},
  'dragonborn': {'STR': 2, 'CHA': 1},
  'gnome': {'INT': 2},
  'half-elf': {'CHA': 2},
  'half-orc': {'STR': 2, 'CON': 1},
  'tiefling': {'CHA': 2, 'INT': 1},
};

const raceSpeeds = <String, int>{
  'human': 30,
  'dwarf': 25,
  'elf': 30,
  'halfling': 25,
  'dragonborn': 30,
  'gnome': 25,
  'half-elf': 30,
  'half-orc': 30,
  'tiefling': 30,
};

const classHitDice = <String, int>{
  'barbarian': 12,
  'bard': 8,
  'cleric': 8,
  'druid': 8,
  'fighter': 10,
  'monk': 8,
  'paladin': 10,
  'ranger': 10,
  'rogue': 8,
  'sorcerer': 6,
  'warlock': 8,
  'wizard': 6,
};

const classSavingThrows = <String, Set<String>>{
  'barbarian': {'STR', 'CON'},
  'bard': {'DEX', 'CHA'},
  'cleric': {'WIS', 'CHA'},
  'druid': {'INT', 'WIS'},
  'fighter': {'STR', 'CON'},
  'monk': {'STR', 'DEX'},
  'paladin': {'WIS', 'CHA'},
  'ranger': {'STR', 'DEX'},
  'rogue': {'DEX', 'INT'},
  'sorcerer': {'CON', 'CHA'},
  'warlock': {'WIS', 'CHA'},
  'wizard': {'INT', 'WIS'},
};

const backgroundSkills = <String, Set<String>>{
  'soldier': {'Athletics', 'Intimidation'},
  'acolyte': {'Insight', 'Religion'},
  'criminal': {'Deception', 'Stealth'},
  'sage': {'Arcana', 'History'},
};
