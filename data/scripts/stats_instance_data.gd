# res://combat/stats/StatsInstance.gd
class_name StatsInstance
extends Resource

signal stat_changed(stat: int, old_value: int, new_value: int)
signal hp_changed(old_value: int, new_value: int)
signal mp_changed(old_value: int, new_value: int)

@export var base: StatsData

var _mods: Array = []                  # Array[StatModifierData] o Dictionary compatibili
var _cache: PackedInt32Array
var _dirty: bool = true

var current_hp: int = 0
var current_mp: int = 0


func _init() -> void:
	_cache = PackedInt32Array()
	_cache.resize(StatsIds.COUNT)


# ---------------------- API PRINCIPALE ----------------------

func init_current_full() -> void:
	_recalc_if_needed()
	current_hp = total(StatsIds.Stat.HP_MAX)
	current_mp = total(StatsIds.Stat.MP_MAX)

func total(stat: int) -> int:
	_recalc_if_needed()
	return _cache[stat]

func change_hp(v: int) -> void:
	_recalc_if_needed()
	var cap := total(StatsIds.Stat.HP_MAX)
	var clamped : int = min(v, cap)
	var old := current_hp
	current_hp -= clamped
	hp_changed.emit(old, current_hp)

func change_mp(v: int) -> void:
	_recalc_if_needed()
	var cap := total(StatsIds.Stat.MP_MAX)
	var clamped : int = min(v, cap)
	var old := current_mp
	current_mp += clamped
	mp_changed.emit(old, current_mp)

func set_base_value(stat: int, value: int) -> void:
	if base == null:
		return
	var before := total(stat)
	if base.has_method("set_value"):
		base.set_value(stat, value)
	_mark_dirty_and_emit_if_changed(stat, before)


# ---------------------- MODIFICATORI ------------------------

func add_modifier(mod) -> void:
	# Accetta StatModifierData o Dictionary:
	#  - Dictionary per MUL/FINAL_MUL: usa "pct_bp" (basis points, 10000=+100%)
	#  - Dictionary per ADD/OVERRIDE: usa "flat" / "override"
	_mods.append(mod)
	_dirty = true

func add_temp_modifier(source: StringName, stat: int, flat: int = 0, pct_bp: int = 0) -> void:
	# Aggiunge rapidamente un paio di mod con "source" uguale (comodo per status)
	if pct_bp != 0:
		var m1 := {
			"stat": stat,
			"op": StatModifierData.Op.MUL,
			"pct_bp": pct_bp,
			"source": source
		}
		_mods.append(m1)
	if flat != 0:
		var m2 := {
			"stat": stat,
			"op": StatModifierData.Op.ADD,
			"flat": flat,
			"source": source
		}
		_mods.append(m2)
	_dirty = true

func clear_modifiers_from_source(source: StringName) -> void:
	if _mods.is_empty():
		return
	var kept := []
	for m in _mods:
		if _get_mod_source(m) != source:
			kept.append(m)
	_mods = kept
	_dirty = true

func clear_modifiers_with_stack_key(stack_key: StringName) -> void:
	if stack_key == &"" or _mods.is_empty():
		return
	var kept := []
	for m in _mods:
		if _get_mod_stack_key(m) != stack_key:
			kept.append(m)
	_mods = kept
	_dirty = true

func clear_all_modifiers() -> void:
	if _mods.is_empty():
		return
	_mods.clear()
	_dirty = true


# ---------------------- RICALCOLO CACHE ----------------------

func _recalc_if_needed() -> void:
	if not _dirty:
		return
	_dirty = false

	# 1) copia base
	for s in range(StatsIds.COUNT):
		var base_v := 0
		if base != null and base.has_method("get_value"):
			base_v = int(base.get_value(s))
		_cache[s] = base_v

	# 2) aggrega mod in INT
	var add := PackedInt32Array()
	var mul_bp := PackedInt32Array()    # somma basis points (10000 = +100%)
	var fmul_bp := PackedInt32Array()   # somma basis points finali
	add.resize(StatsIds.COUNT)
	mul_bp.resize(StatsIds.COUNT)
	fmul_bp.resize(StatsIds.COUNT)

	var overrides := {} # stat:int -> int

	for m in _mods:
		var st := _get_mod_stat(m)
		if st < 0 or st >= StatsIds.COUNT:
			continue
		var op := _get_mod_op(m)

		match op:
			StatModifierData.Op.ADD:
				add[st] += _get_mod_flat(m)
			StatModifierData.Op.MUL:
				mul_bp[st] += _get_mod_pct_bp(m)   # somma basis points
			StatModifierData.Op.FINAL_MUL:
				fmul_bp[st] += _get_mod_final_pct_bp(m)
			StatModifierData.Op.OVERRIDE:
				overrides[st] = _get_mod_override(m)
			_:
				pass

	# 3) applica: ((base * (10000 + mul)) / 10000 + add) * (10000 + fmul) / 10000 → override se c'è
	for s in range(StatsIds.COUNT):
		var before := _cache[s]
		var v := before

		# round-to-nearest: aggiungo 5000 prima della divisione per 10000
		var mul_sum := 10000 + mul_bp[s]
		v = int((v * mul_sum + 5000) / 10000)

		v += add[s]

		var fmul_sum := 10000 + fmul_bp[s]
		v = int((v * fmul_sum + 5000) / 10000)

		if overrides.has(s):
			v = int(overrides[s])

		if v != before:
			_cache[s] = v
			stat_changed.emit(s, before, v)

	# 4) se cambiano i cap, riclampa HP/MP
	var new_max_hp := _cache[StatsIds.Stat.HP_MAX]
	if current_hp > new_max_hp:
		var old_hp := current_hp
		current_hp = new_max_hp
		if current_hp != old_hp:
			hp_changed.emit(old_hp, current_hp)

	var new_max_mp := _cache[StatsIds.Stat.MP_MAX]
	if current_mp > new_max_mp:
		var old_mp := current_mp
		current_mp = new_max_mp
		if current_mp != old_mp:
			mp_changed.emit(old_mp, current_mp)


func _mark_dirty_and_emit_if_changed(stat: int, old_total: int) -> void:
	_dirty = true
	_recalc_if_needed()
	var new_total := _cache[stat]
	if new_total != old_total:
		stat_changed.emit(stat, old_total, new_total)
		if stat == StatsIds.Stat.HP_MAX:
			change_hp(current_hp) # riclampa e segnala se serve
		elif stat == StatsIds.Stat.MP_MAX:
			change_mp(current_mp)


# ---------------------- HELPERS LETTURA MOD ----------------------

func _get_mod_stat(m) -> int:
	if m is StatModifierData:
		return int(m.stat)
	if typeof(m) == TYPE_DICTIONARY:
		return int(m.get("stat", -1))
	return -1

func _get_mod_op(m) -> int:
	if m is StatModifierData:
		return int(m.op)
	if typeof(m) == TYPE_DICTIONARY:
		return int(m.get("op", StatModifierData.Op.ADD))
	return StatModifierData.Op.ADD

func _get_mod_flat(m) -> int:
	# per ADD: somma intera
	if m is StatModifierData:
		return int(m.value)
	if typeof(m) == TYPE_DICTIONARY:
		return int(m.get("flat", 0))
	return 0

func _get_mod_pct_bp(m) -> int:
	# per MUL: basis points (10000 = +100)
	if m is StatModifierData:
		# se in StatModifierData.value hai già i bp, restituiscili; se è fra -1..1 (float), convertilo in bp altrove
		if typeof(m.value) == TYPE_FLOAT:
			return int(round(m.value * 10000.0))
		return int(m.value)
	if typeof(m) == TYPE_DICTIONARY:
		if m.has("pct_bp"):
			return int(m["pct_bp"])
		if m.has("pct"): # pct come frazione (es. 0.2 → 2000 bp)
			var frac : int = m["pct"]
			if typeof(frac) == TYPE_FLOAT:
				return int(round(frac * 10000.0))
			return int(frac) # se già int, assumo bp
	return 0

func _get_mod_final_pct_bp(m) -> int:
	# per FINAL_MUL: basis points
	if m is StatModifierData:
		if typeof(m.value) == TYPE_FLOAT:
			return int(round(m.value * 10000.0))
		return int(m.value)
	if typeof(m) == TYPE_DICTIONARY:
		if m.has("final_pct_bp"):
			return int(m["final_pct_bp"])
		if m.has("final_pct"):
			var frac : int = m["final_pct"]
			if typeof(frac) == TYPE_FLOAT:
				return int(round(frac * 10000.0))
			return int(frac)
	return 0

func _get_mod_override(m) -> int:
	if m is StatModifierData:
		return int(m.value)
	if typeof(m) == TYPE_DICTIONARY:
		if m.has("override"):
			return int(m["override"])
		# fallback: se c'è "flat" usalo
		return int(m.get("flat", 0))
	return 0

func _get_mod_source(m) -> StringName:
	if m is StatModifierData:
		return m.source
	if typeof(m) == TYPE_DICTIONARY:
		return StringName(m.get("source", &""))
	return &""

func _get_mod_stack_key(m) -> StringName:
	if m is StatModifierData:
		return m.stack_key
	if typeof(m) == TYPE_DICTIONARY:
		return StringName(m.get("stack_key", &""))
	return &""
