class_name StatsData
extends Resource

@export_category("Vitals")
@export var HP      : int = 0     # di solito lasci 0: l'HP corrente sta in StatsInstance
@export var HP_MAX  : int = 100
@export var MP      : int = 0    # idem come HP
@export var MP_MAX  : int = 30

@export_category("Offense / Defense")
@export var ATK     : int = 10
@export var DEF     : int = 5
@export var MATK    : int = 0
@export var MDEF    : int = 0

@export_category("Accuracy / Dodge / Crit")
@export var ACC        : int = 95  # es. 95% base
@export var EVA        : int = 5  # es. 5% base
@export var CRIT_RATE  : int = 5  # 5% = 0.05
@export var CRIT_DMG   : int = 150   # 150% = 1.5

@export_category("Other")
@export var SPEED   : int = 100

func get_base(stat: StatsIds.Stat) -> int:
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
		_:                        return 0

func set_base(stat: StatsIds.Stat, v: int) -> void:
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
