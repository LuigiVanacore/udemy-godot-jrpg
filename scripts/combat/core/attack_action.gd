# res://combat/actions/AttackAction.gd
class_name AttackAction
extends AbstractAction



func id() -> StringName: return &"ATTACK"
func label() -> String: return "Attacca"
func target_mode() -> int: return ActionTypes.TargetMode.SINGLE_ENEMY

func validate(state_before: Dictionary, payload: Dictionary) -> Array:
	var errs: Array = []
	if not payload.has("caster_id"): errs.append("Missing caster_id")
	if not payload.has("target_ids"): errs.append("Missing target_ids")
	if not errs.is_empty(): return errs

	var units: Dictionary = state_before.get("units", {}) as Dictionary
	if not units.has(payload["caster_id"]):
		errs.append("Caster not found")

	var tids: Array = payload["target_ids"] as Array
	if tids.size() != 1:
		errs.append("Attack needs exactly one target")

	if errs.is_empty():
		var tid = tids[0]
		if not units.has(tid):
			errs.append("Target not found")
		else:
			var c: Dictionary = units[payload["caster_id"]] as Dictionary
			var t: Dictionary = units[tid] as Dictionary
			if int(c.get("team", 0)) == int(t.get("team", 0)):
				errs.append("Target must be enemy")
	return errs

func preview(state_before: Dictionary, payload: Dictionary) -> Dictionary:
	var units: Dictionary = state_before["units"] as Dictionary
	var c: Dictionary = units[payload["caster_id"]] as Dictionary
	var t: Dictionary = units[(payload["target_ids"] as Array)[0]] as Dictionary
	var base: int = max(1, int(c.get("atk", 5)) - int(t.get("def", 0)))
	return {"min": max(1, base - 2), "max": base + 2}

func execute(state_before: Dictionary, payload: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var units: Dictionary = state_before["units"] as Dictionary
	var caster: Dictionary = units[payload["caster_id"]] as Dictionary
	var tid = (payload["target_ids"] as Array)[0]
	var target: Dictionary = units[tid] as Dictionary

	var base: int = max(1, int(caster.get("atk", 5)) - int(target.get("def", 0)))
	var variance: int = rng.randi_range(-2, 2)
	var dmg: int = max(1, base + variance)

	var deltas: Array = [ {"id": tid, "hp": -dmg} ]
	var state_after: Dictionary = ActionResolver.apply_deltas_to_state(state_before, deltas)

	return {
		"ok": true,
		"deltas": deltas,
		"log": ["%s colpisce %s per %d danni" % [str(caster.get("name","?")), str(target.get("name","?")), dmg]],
		"state_after": state_after,
	}

