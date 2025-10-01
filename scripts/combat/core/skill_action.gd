# SkillAction.gd
class_name SkillAction
extends AbstractAction

var _data: SkillData

func _init(data: SkillData) -> void:
	_data = data

func id() -> StringName: return _data.id
func label() -> String: return _data.label
func target_mode() -> int: return _data.target_mode

func validate(state_before: Dictionary, payload: Dictionary) -> Array:
	var errs: Array = []
	if _data == null: errs.append("SkillData missing")
	if not payload.has("caster_id"): errs.append("Missing caster_id")
	if not payload.has("target_ids"): errs.append("Missing target_ids")
	if not errs.is_empty(): return errs
	if not state_before.has("units"): return ["State missing 'units'"]
	var units: Dictionary = state_before["units"] as Dictionary
	var caster_id: Variant = payload["caster_id"]
	if not units.has(caster_id):
		errs.append("Invalid caster_id")
	else:
		var caster_snap: Dictionary = units.get(caster_id, {}) as Dictionary
		if int(caster_snap.get("mp", 0)) < int(_data.mp_cost):
			errs.append("Not enough MP")
	return errs

func execute(state_before: Dictionary, payload: Dictionary, _rng: RandomNumberGenerator) -> Dictionary:
	var units: Dictionary = state_before["units"] as Dictionary
	var caster_id: Variant = payload["caster_id"]
	var caster: Dictionary = units.get(caster_id, {}) as Dictionary
	var tids: Array = payload["target_ids"]

	var deltas: Array = []
	var _log: Array[String] = []

	# Pay MP cost
	if _data.mp_cost > 0:
		deltas.append({"id": caster_id, "mp": -int(_data.mp_cost)})

	for tid_any in tids:
		if not units.has(tid_any):
			continue
		var target: Dictionary = units.get(tid_any, {}) as Dictionary
		var scale: float = float(caster.get(str(_data.scaling_stat), 5))
		var amount: int = int(round(scale * float(_data.power)))
		if String(_data.effect_kind) == "damage":
			# Simple mitigation: MATK/MDEF vs ATK/DEF based on scaling stat name
			var defence_key := "mdef" if String(_data.scaling_stat) == "matk" else "def"
			amount = max(1, amount - int(target.get(defence_key, 0)))
			deltas.append({"id": tid_any, "hp": -amount})
			_log.append("%s usa %s su %s: %d danni" % [str(caster.get("name","?")), _data.label, str(target.get("name","?")), amount])
		else:
			deltas.append({"id": tid_any, "hp": amount})
			_log.append("%s usa %s su %s: +%d HP" % [str(caster.get("name","?")), _data.label, str(target.get("name","?")), amount])

	return {"ok": true, "deltas": deltas, "log": _log}
