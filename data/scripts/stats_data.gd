class_name StatsData
extends Resource

@export_category("Vitals")
@export var HP      : float = 0.0     # di solito lasci 0: l'HP corrente sta in StatsInstance
@export var HP_MAX  : float = 100.0
@export var MP      : float = 0.0     # idem come HP
@export var MP_MAX  : float = 30.0

@export_category("Offense / Defense")
@export var ATK     : float = 10.0
@export var DEF     : float = 5.0
@export var MATK    : float = 0.0
@export var MDEF    : float = 0.0

@export_category("Accuracy / Dodge / Crit")
@export var ACC        : float = 0.95  # es. 95% base
@export var EVA        : float = 0.05  # es. 5% base
@export var CRIT_RATE  : float = 0.05  # 5% = 0.05
@export var CRIT_DMG   : float = 1.5   # 150% = 1.5

@export_category("Other")
@export var SPEED   : float = 100.0

func get_base(stat: StatsIds.Stat) -> float:
	match stat:
		StatsIds.Stat.HP:         return HP
		StatsIds.Stat.HP_MAX:     return HP_MAX
		StatsIds.Stat.MP:         return MP
		StatsIds.Stat.MP_MAX:     return MP_MAX
		StatsIds.Stat.ATK:        return ATK
		StatsIds.Stat.DEF:        return DEF
		StatsIds.Stat.MATK:       return MATK
		StatsIds.Stat.MDEF:       return MDEF
		StatsIds.Stat.ACC:        return ACC
		StatsIds.Stat.EVA:        return EVA
		StatsIds.Stat.CRIT_RATE:  return CRIT_RATE
		StatsIds.Stat.CRIT_DMG:   return CRIT_DMG
		StatsIds.Stat.SPEED:      return SPEED
		_:                        return 0.0

func set_base(stat: StatsIds.Stat, v: float) -> void:
	match stat:
		StatsIds.Stat.HP:         HP = v
		StatsIds.Stat.HP_MAX:     HP_MAX = v
		StatsIds.Stat.MP:         MP = v
		StatsIds.Stat.MP_MAX:     MP_MAX = v
		StatsIds.Stat.ATK:        ATK = v
		StatsIds.Stat.DEF:        DEF = v
		StatsIds.Stat.MATK:       MATK = v
		StatsIds.Stat.MDEF:       MDEF = v
		StatsIds.Stat.ACC:        ACC = v
		StatsIds.Stat.EVA:        EVA = v
		StatsIds.Stat.CRIT_RATE:  CRIT_RATE = v
		StatsIds.Stat.CRIT_DMG:   CRIT_DMG = v
		StatsIds.Stat.SPEED:      SPEED = v
		_:                        pass
