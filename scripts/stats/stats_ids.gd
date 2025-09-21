class_name StatsIds
extends RefCounted

enum Stat {
	HP, HP_MAX,
	MP, MP_MAX,
	ATK, DEF,
	MATK, MDEF,
	ACC, EVA,
	CRIT_RATE, CRIT_DMG,
	SPEED
}

const COUNT := 13

# Solo per debugging/UI (non usarle come chiavi in logica)
const NAMES := [
	"HP","HP_MAX","MP","MP_MAX","ATK","DEF",
	"MATK","MDEF","ACC","EVA","CRIT_RATE","CRIT_DMG","SPEED"
]

static func to_name(id: int) -> StringName:
	return StringName(NAMES[id])

static func from_name(n: StringName) -> int:
	return NAMES.find(String(n))
