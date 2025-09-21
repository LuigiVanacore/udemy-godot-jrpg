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
	var errs := []
	if _data == null: errs.append("SkillData missing")
	if not payload.has("caster_id"): errs.append("Missing caster_id")
	if not payload.has("target_ids"): errs.append("Missing target_ids")
	if errs.size() > 0: return errs

	var units := state_before.get("units", {})
	if not units.has(payload["caster_id"]): errs.append("Caster not found")
	else:
		var caster := units[payload["caster_id"]]
		if int(caster.get("mp", 0)) < int(_data.mp_cost):
			errs.append("Not enough MP")

	var tids := payload["target_ids"]
	if tids.size() == 0: errs.append("No targets selected")
	# (Potresti validare anche che i target rispettino il target_mode)
	return errs

func execute(state_before: Dictionary, payload: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var units := state_before["units"]
	var caster := units[payload["caster_id"]]
	var deltas := []
	var log := []

	# paga MP
	deltas.append({"id": payload["caster_id"], "mp": -int(_data.mp_cost)})

	for tid in payload["target_ids"]:
		if not units.has(tid): continue
		var target := units[tid]
		var scale := float(caster.get(str(_data.scaling_stat), 5))
		var amount := int(round(scale * _data.power))
		if String(_data.effect_kind) == "damage":
			amount = max(1, amount - int(target.get("def", 0)))  # semplice mitigazione
			deltas.append({"id": tid, "hp": -amount})
			log.append("%s usa %s su %s: %d danni" % [str(caster.get("name","?")), _data.label, str(target.get("name","?")), amount])
		else:
			deltas.append({"id": tid, "hp": +amount})
			log.append("%s usa %s su %s: cura %d HP" % [str(caster.get("name","?")), _data.label, str(target.get("name","?")), amount])

	var state_after := ActionResolver.apply_deltas_to_state(state_before, deltas)
	return {"ok": true, "deltas": deltas, "log": log, "state_after": state_after}
