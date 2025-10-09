class_name DamageResolver
extends RefCounted

#static func _has_status(u: StatsInstance, key: StringName) -> bool:
	#var st: Dictionary = u.get("statuses", {})
	#return bool(st.get(key, false))

static func element_pct(target: Dictionary, element: int) -> int:
	# Restituisce la resistenza come int percentuale (può essere negativa)
	var resists: Dictionary = target.get("resists", {})
	return int(resists.get(ElementTypes.to_key(element), 100))

static func _mul_pct(v: int, pct: int) -> int:
	# v * (pct / 100) con arrotondamento
	return int((v * pct + 50) / 100)

static func resolve(caster: StatsInstance, target: StatsInstance, ctx: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var out := {
		"hit": false,
		"crit": false,
		"damage": 0,
		"tags": [],
		"hit_chance_pct": 0,   # int 0..100
		"crit_chance_pct": 0,  # int 0..100
		"roll_bp": 0,          # 1..10000
		"crit_roll_bp": 0,     # 1..10000
		"mults_pct": {},       # {element_pct, combined_pct}
		"breakdown": {}
	}

	# --- HIT (INT + bp) ---
	var acc: int = caster.total(StatsIds.Stat.ACC)
	var eva: int = target.total(StatsIds.Stat.EVA)
	#if _has_status(caster, &"BLIND"):
		#acc -= 30
	#if _has_status(target, &"OFF_GUARD"):
		#eva -= 10

	var base_hit_pct: int = int(ctx.get("base_hit_pct", 85))
	var hit_per_point_bp: int = int(ctx.get("hit_per_point_bp", 50)) # 50 bp = 0.50% per punto
	var hit_bp: int = base_hit_pct * 100 + (acc - eva) * hit_per_point_bp
	hit_bp = clamp(hit_bp, 500, 9800) # 5%..98%
	out["hit_chance_pct"] = int((hit_bp + 50) / 100)

	var roll_bp: int = rng.randi_range(1, 10000)
	out["roll_bp"] = roll_bp
	if roll_bp > hit_bp:
		out["tags"] = ["MISS"]
		return out

	# --- CRIT (INT %) ---
	var crit_rate_pct: int = caster.total(StatsIds.Stat.CRIT_RATE)
	#if _has_status(target, &"OFF_GUARD"):
		#crit_rate_pct += 10
	crit_rate_pct = clamp(crit_rate_pct, 0, 80)
	out["crit_chance_pct"] = crit_rate_pct

	var crit_roll_bp: int = rng.randi_range(1, 10000)
	out["crit_roll_bp"] = crit_roll_bp
	var is_crit: bool = crit_roll_bp <= crit_rate_pct * 100
	out["crit"] = is_crit

	# --- RAW POWER & DEF ---
	var kind: int = int(ctx.get("damage_kind", ActionTypes.DamageKind.PHYSICAL))
	var atk_key := "matk" if kind == ActionTypes.DamageKind.MAGICAL else "atk"
	var def_key := "mdef" if kind == ActionTypes.DamageKind.MAGICAL else "def"

	var atk: int = caster.total(StatsIds.Stat.ATK) \
				  if kind == ActionTypes.DamageKind.MAGICAL \
				  else  caster.total(StatsIds.Stat.MATK)
	var defn: int = target.total(StatsIds.Stat.DEF) \
				  if kind == ActionTypes.DamageKind.MAGICAL \
				  else  caster.total(StatsIds.Stat.MDEF)
	var def_eff: int = defn
	if is_crit:
		var crit_def_pen_pct: int = int(ctx.get("crit_def_pen_pct", 50)) # es. 50 = -50% difesa su crit
		def_eff = _mul_pct(defn, 100 - crit_def_pen_pct)

	var raw: int = int(ctx.get("raw_override", -1))
	if raw < 0:
		var power_pct: int = int(ctx.get("power_pct", 100)) # 100 = x1.0
		raw = _mul_pct(atk, power_pct)
		raw = max(1, raw)

	var def_softcap: int = int(ctx.get("def_softcap", 50))
	var denom: int = def_eff + max(def_softcap, 1)
	var mitigation_pct: int = int((def_eff * 100 + denom / 2) / denom) # arrotondato
	var post_def: int = _mul_pct(raw, 100 - mitigation_pct)
	post_def = max(1, post_def)

	# --- VARIANCE (±variance_pct%) ---
	var variance_pct: int = int(ctx.get("variance_pct", 10))
	var var_delta: int = rng.randi_range(-variance_pct, variance_pct)
	var post_var: int = _mul_pct(post_def, 100 + var_delta)

	# --- ELEMENT & STATUS MULTIPLIERS ---
	var element: int = int(ctx.get("element", ElementTypes.Element.PHYSICAL))
	#var ele_pct: int = element_pct(target, element)
	#var mult_pct: int = ele_pct

	#if _has_status(target, &"PROTECT") and kind == ActionTypes.DamageKind.PHYSICAL:
		#mult_pct = _mul_pct(mult_pct, 75)
	#if _has_status(target, &"SHELL") and kind == ActionTypes.DamageKind.MAGICAL:
		#mult_pct = _mul_pct(mult_pct, 75)
	#if _has_status(target, &"GUARDING"):
		#mult_pct = _mul_pct(mult_pct, 50)
	#if _has_status(target, &"OFF_GUARD"):
		#mult_pct = _mul_pct(mult_pct, 125)

	var final_val: int = post_var
	if is_crit:
		var crit_dmg_pct: int = caster.total(StatsIds.Stat.CRIT_DMG)
		final_val = _mul_pct(final_val, 100 + crit_dmg_pct)
	#final_val = _mul_pct(final_val, mult_pct)

	var dmg: int = abs(final_val)

	# --- TAGS ---
	var tags: Array = []
	#if ele_pct == 0:
		#tags.append("IMMUNE")
		#dmg = 0
	#elif ele_pct < 0:
		#tags.append("ABSORB")
		#dmg = -dmg
	#elif ele_pct > 105:
		#tags.append("WEAKNESS")
	#elif ele_pct < 95:
		#tags.append("RESIST")

	out["hit"] = true
	out["damage"] = dmg
	out["tags"] = tags
	#out["mults_pct"] = {"element_pct": ele_pct, "combined_pct": mult_pct}
	out["breakdown"] = {
		"raw": raw,
		"def_eff": def_eff,
		"mitigation_pct": mitigation_pct,
		"post_def": post_def,
		"post_var": post_var
	}
	return out
