class_name AttackAction
extends AbstractAction

# Parametri base in percentuali INT
var power_pct: int = 100 # 100 = x1.0
var element: int = ElementTypes.Element.PHYSICAL
var damage_kind: int = ActionTypes.DamageKind.PHYSICAL

func id() -> StringName: return &"ATTACK"
func label() -> String: return "Attacca"
func target_mode() -> int: return ActionTypes.TargetMode.SINGLE_ENEMY

func validate() -> String:
	var errs := ""
	if not payload.has("caster"): errs += " Missing caster"
	if not payload.has("target"): errs += " Missing target"
	if not errs.is_empty(): return errs

	
	var targets: Array = payload["target"]
	if targets.is_empty():
		errs += " No targets"
	else:
		var target : Unit = targets[0]
		if not is_instance_of(target, Unit): errs += " Invalid target_id"
	return errs

func execute(rng: RandomNumberGenerator) -> ActionResult:
	var caster: Unit = payload["caster"]
	var target: Unit = (payload["target"] as Array)[0]


	# UnitState ha .stats_state : Dictionary[StringName,int]
	var caster_stats: StatsInstance = caster.get_stats_instance()
	var target_stats: StatsInstance =  target.get_stats_instance()

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
 
 
	var crit : bool  
	var debug_log : String
	var caster_name := caster.get_unit_name()
	var target_name := target.get_unit_name()
	
	# MISS
	if not bool(out.get("hit", false)):
		
		var hit_pct := int(out.get("hit_chance_pct", 0)) 
		debug_log = "%s manca %s (C=%d%%)" % [caster_name, target_name, hit_pct]
		return ActionResult.new(true, false, false, [], debug_log)

	# HIT
 
	crit = bool(out.get("crit", false))
	var dmg := int(out.get("damage", 0)) 
	var actionDelta : ActionDelta = ActionDelta.hp(target, dmg)
	 
	var tags: Array = out.get("tags", [])
	
	var crit_txt : String = " (CRITICO)" if crit else ""
	var tag_txt := "" if tags.is_empty() else " [%s]" % ",".join(tags)
	debug_log = "%s colpisce %s%s per %d danni%s" % [caster_name, target_name, crit_txt, max(dmg, 0), tag_txt]

	return ActionResult.new(true, true, crit, [actionDelta], debug_log)
