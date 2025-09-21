# StatsInstance.gd
class_name StatsInstance
extends Resource

signal stat_changed(stat: int, old_value: float, new_value: float)
signal hp_changed(old_value: float, new_value: float)
signal mp_changed(old_value: float, new_value: float)

@export var base: StatsData

var _mods: Array = []                         # Array di StatModifierData (no tipizzazione annidata per sicurezza)
var _cache: PackedFloat32Array                # cache dei totali
var _dirty: bool = true

var current_hp: float = 0.0
var current_mp: float = 0.0

func _init() -> void:
	_cache = PackedFloat32Array()
	_cache.resize(StatsIds.COUNT)

# ---- API PRINCIPALE ----
func init_current_full() -> void:
	_recalc_if_needed()
	current_hp = total(StatsIds.Stat.HP_MAX)
	current_mp = total(StatsIds.Stat.MP_MAX)

func total(stat: StatsIds.Stat) -> float:
	if _dirty:
		_recalc_all()
	return _cache[stat]

func get_base(stat: StatsIds.Stat) -> float:
	return base.get_base(stat) if base != null else 0.0

func set_base(stat: StatsIds.Stat, v: float) -> void:
	if base == null:
		base = StatsData.new()
	base.set_base(stat, v)
	_mark_dirty()

func add_modifier(mod: StatModifierData, replace_same_key := true) -> void:
	if replace_same_key and String(mod.stack_key) != "":
		for i in range(_mods.size()):
			var m: StatModifierData = _mods[i]
			if m.stat == mod.stat and m.stack_key == mod.stack_key:
				_mods[i] = mod
				_mark_dirty()
				return
	_mods.append(mod)
	_mark_dirty()

func remove_modifiers_by_source(source: StringName) -> void:
	var removed := false
	for i in range(_mods.size() - 1, -1, -1):
		var m: StatModifierData = _mods[i]
		if m.source == source:
			_mods.remove_at(i)
			removed = true
	if removed:
		_mark_dirty()

func clear_modifiers() -> void:
	if _mods.size() > 0:
		_mods.clear()
		_mark_dirty()

 

# ---- HP / MP correnti ----
func apply_damage(amount: float) -> float:
	if amount <= 0.0: return 0.0
	var old := current_hp
	current_hp = max(0.0, current_hp - amount)
	if current_hp != old:
		hp_changed.emit(old, current_hp)
	return old - current_hp

func heal(amount: float) -> float:
	if amount <= 0.0: return 0.0
	var old := current_hp
	var max_hp := total(StatsIds.Stat.HP_MAX)
	current_hp = min(max_hp, current_hp + amount)
	if current_hp != old:
		hp_changed.emit(old, current_hp)
	return current_hp - old

func spend_mp(amount: float) -> bool:
	if amount <= 0.0: return true
	if current_mp < amount: return false
	var old := current_mp
	current_mp -= amount
	mp_changed.emit(old, current_mp)
	return true

func restore_mp(amount: float) -> float:
	if amount <= 0.0: return 0.0
	var old := current_mp
	var max_mp := total(StatsIds.Stat.MP_MAX)
	current_mp = min(max_mp, current_mp + amount)
	if current_mp != old:
		mp_changed.emit(old, current_mp)
	return current_mp - old

# ---- INTERNO: calcolo totali ----
func _mark_dirty() -> void:
	_dirty = true

func _recalc_if_needed() -> void:
	if _dirty:
		_recalc_all()

func _recalc_all() -> void:
	var old_vals := _cache.duplicate()

	# 1) base
	for s in StatsIds.COUNT:
		_cache[s] = base.get_base(s) if base != null else 0.0

	# 2) applica modificatori in ordine: ADD -> MUL -> FINAL_MUL -> OVERRIDE
	#    (classico JRPG: additivi, poi moltiplicatori, poi moltiplicatori finali, eventuali override)
	var add := PackedFloat32Array();      add.resize(StatsIds.COUNT)
	var mul := PackedFloat32Array();      mul.resize(StatsIds.COUNT)     # accoglie somme di fattori (1+v) - 1
	var fmul := PackedFloat32Array();     fmul.resize(StatsIds.COUNT)
	var ovrd := Dictionary()  # stat(int) -> float

	for i in _mods.size():
		var m: StatModifierData = _mods[i]
		match m.op:
			StatModifierData.Op.ADD:        add[m.stat] += m.value
			StatModifierData.Op.MUL:        mul[m.stat] += m.value
			StatModifierData.Op.FINAL_MUL:  fmul[m.stat] += m.value
			StatModifierData.Op.OVERRIDE:   ovrd[m.stat] = m.value

	for s in StatsIds.COUNT:
		var v := _cache[s]
		v = v + add[s]
		v = v * (1.0 + mul[s])
		v = v * (1.0 + fmul[s])
		if ovrd.has(s):
			v = float(ovrd[s])

		# Clamp “ragionevoli” per tassi
		if s == StatsIds.Stat.CRIT_RATE:
			v = clamp(v, 0.0, 1.0) # 0%..100%
		if s == StatsIds.Stat.EVA:
			v = max(0.0, v)
		if s == StatsIds.Stat.ACC:
			v = max(0.0, v)

		_cache[s] = v

	_dirty = false

	# Eventi stat_changed (solo per chi ascolta)
	for s in StatsIds.COUNT:
		if !is_equal_approx(old_vals[s], _cache[s]):
			stat_changed.emit(s, old_vals[s], _cache[s])

	# Se i massimali sono cambiati, riallinea HP/MP correnti
	var new_max_hp := _cache[StatsIds.Stat.HP_MAX]
	if current_hp > new_max_hp:
		var old_hp := current_hp
		current_hp = new_max_hp
		if !is_equal_approx(old_hp, current_hp):
			hp_changed.emit(old_hp, current_hp)

	var new_max_mp := _cache[StatsIds.Stat.MP_MAX]
	if current_mp > new_max_mp:
		var old_mp := current_mp
		current_mp = new_max_mp
		if !is_equal_approx(old_mp, current_mp):
			mp_changed.emit(old_mp, current_mp)
