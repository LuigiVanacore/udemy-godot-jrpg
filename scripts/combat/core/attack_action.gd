class_name AttackAction
extends AbstractAction

# Parametri base in percentuali INT
var power_pct: int = 100 # 100 = x1.0
var element: int = ElementTypes.Element.PHYSICAL
var damage_kind: int = ActionTypes.DamageKind.PHYSICAL

func id() -> StringName: return &"ATTACK"
func label() -> String: return "Attacca"
func target_mode() -> int: return ActionTypes.TargetMode.SINGLE_ENEMY

func validate(state_before: Dictionary, payload: Dictionary) -> String:
	var errs := ""
	if not payload.has("caster_id"): errs += " Missing caster_id"
	if not payload.has("target_ids"): errs += " Missing target_ids"
	if not errs.is_empty(): return errs

	var units: Dictionary = state_before # mappa: uid -> UnitState
	var caster_id : int = payload["caster_id"]
	if not units.has(caster_id): errs += " Invalid caster_id"

	var tids: Array = payload["target_ids"]
	if tids.is_empty():
		errs += " No targets"
	else:
		var tid0 : int = tids[0]
		if not units.has(tid0): errs += " Invalid target_id"
	return errs

func execute(state_before: Dictionary, payload: Dictionary, rng: RandomNumberGenerator) -> ActionResult:
	var caster_id: Variant = payload["caster_id"]
	var target_id: Variant = (payload["target_ids"] as Array)[0]

	# --- estrai gli snapshot statistici dal tuo UnitState ---
	var caster_entry = state_before.get(caster_id)
	var target_entry = state_before.get(target_id)
	# UnitState ha .stats_state : Dictionary[StringName,int]
	var caster_stats: Dictionary = (caster_entry.stats_state if typeof(caster_entry) != TYPE_DICTIONARY else caster_entry)
	var target_stats: Dictionary = (target_entry.stats_state if typeof(target_entry) != TYPE_DICTIONARY else target_entry)

	# --- contesto INT-only per il resolver ---
	var ctx: Dictionary = {
		"power_pct": int(payload.get("power_pct", power_pct)), # se nel payload passi power_pct, sovrascrive
		"variance_pct": 10,
		"element": int(payload.get("element", element)),
		"damage_kind": int(payload.get("damage_kind", damage_kind)),
		"base_hit_pct": 85,
		"hit_per_point_bp": 50,   # 0.50% per punto (ACC - EVA)
		"crit_def_pen_pct": 50,   # -50% DEF/MDEF sui crit
		"def_softcap": 50
	}

	var out := DamageResolver.resolve(caster_stats, target_stats, ctx, rng)

	 
	var ok : bool = true
	var hit : bool 
	var crit : bool
	var deltas : Array[ActionDelta] = []
	var debug_log : String
	
	# MISS
	if not bool(out.get("hit", false)):
		var caster_name := String(caster_stats.get("name", str(caster_id)))
		var target_name := String(target_stats.get("name", str(target_id)))
		var hit_pct := int(out.get("hit_chance_pct", 0))
		hit = false
		crit = false
		deltas = []
		debug_log = "%s manca %s (C=%d%%)" % [caster_name, target_name, hit_pct]
		return ActionResult.new(ok, hit, crit, deltas, debug_log)

	# HIT
	hit = true
	crit = bool(out.get("crit", false))
	var dmg := int(out.get("damage", 0)) 

	# Delta HP: positivo cura, negativo danneggia → metto -dmg
	deltas = [ ActionDelta.hp(target_id, -dmg) ]

	var tags: Array = out.get("tags", [])
	var caster_name2 := String(caster_stats.get("name", str(caster_id)))
	var target_name2 := String(target_stats.get("name", str(target_id)))
	var crit_txt : String = " (CRITICO)" if crit else ""
	var tag_txt := "" if tags.is_empty() else " [%s]" % ",".join(tags)
	debug_log = "%s colpisce %s%s per %d danni%s" % [caster_name2, target_name2, crit_txt, max(dmg, 0), tag_txt]

	return ActionResult.new(ok, hit, crit, deltas, debug_log)
